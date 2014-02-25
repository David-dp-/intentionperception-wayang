%%
%% ObserverModel.ecl, part of the Wayang project of cogsys.ihpc.a-star.edu.sg
%%

:- dynamic( maxAllowableErrorInMagnitude/1 ). %asserted by storeSettings/1
:- dynamic( minPerceptibleChangeInPosition/1 ).    %asserted by storeSettings/1
:- dynamic( minPerceptibleArea/1 ).                %asserted by storeSettings/1
:- dynamic( minPerceptibleRGBDifference/1 ).       %asserted by storeSettings/1
:- dynamic( minAreaOverDistanceToAvoidFlicker/1 ). %asserted by storeSettings/1
:- dynamic( maxElapsedTimeToAvoidFlicker/1 ).      %asserted by storeSettings/1
:- dynamic( loggingMethod/1).	%asserted by storeSettings/1
:- dynamic( loggingLevel/1).	%asserted by storeSettings/1

:- dynamic( framesStack/1 ).                            %asserted by inferFromTerm/1
	
:- lib(ic).

%processFrames/0 is the only predicate that is intended to be used by outside callers. It is the entry point.
% Typically, an entry point takes input values as arguments to the predicate, but we don't want to require that
% all the input be known in advance (e.g., this program could conceivably be used in a real-time app that
% manipulates its environment and thereby changes subsequent input). So instead, we receive input via the
% javaToEclipse input queue managed by readTerm/1 (and we return info via the eclipseToJava output queue
% which is managed by writeTerm/1).
%
processFrames :-
	initializeParser,!,
	open("outputLog.csv",write,outputLog), %Open outputLog for writing
	loopThroughFrames,
	writeTerm(sawEndOfFrames,_), %Tells UI it can show "Passed", assuming no test mismatches so far.
	close(outputLog),
	writeParsingReport,
	writeL(['CLP finished upon reading \"endOfFrames\"']).

loopThroughFrames :-
	repeat,
	readTerm(InputTerm),         %def'd in ObserverToWorld; there is a stubbed version in stubsAndUtilsForStandalone.pro
	condPrintf(traceParser,"\n...Ingested term: %w\n",[InputTerm]), %DEBUG
	processTerm(InputTerm),
	InputTerm = endOfFrames. %the exit condition of this repeat loop
	  
%If the term uses settings/1, then its argument should be a list of terms representing settings, and we assert
% each of those arguments (so they can be looked up later by any predicate). Otherwise, the usual case applies
% where the term should use inferred/3 and its first argument represents a frame (the second arg represents
% explanations to be filled in, and the last arg represents an expectation to be filled in). For this case,
% we try to infer an expectation - and if needed, explanations - using inferFromTerm/1.
%
processTerm(Term) :-
	%condPrintf(traceParser,"...processTerm: %w\n",[Term]), %DEBUG
	((Term = settings([SettingsHead|SettingsTail]))
	 -> storeSettings([SettingsHead|SettingsTail])
	  ; inferFromTerm(Term) ),!. %This cut is necessary to avoid having processTerm be called more than once per Term due to the enclosing repeat loop

%DOC
%Recurse through the list of settings to be stored in working memory. For each one, check if the same
% predicate and arity were previously set (almost always a mistake) by trying to retract a test term
% that uses the same predicate and arity (using free vars).
%We wrap each assertion with setting/1 so we can use retractall in test/stubs
%
storeSettings([]).
storeSettings([SettingsHead|SettingsTail]) :-
	functor(SettingsHead, Predicate, Arity),
	length(ListOfFreeVars, Arity),
	OldSetting =.. [Predicate|ListOfFreeVars],
	((retract(setting(OldSetting)),
	  condPrintf(traceParser,"SUSPICIOUS: %w/%w previously was set as %w and is now %w\n", [Predicate,Arity,OldSetting,SettingsHead]) )
	 ; true ),
	assert( setting(SettingsHead) ),
	condPrintf(traceParser,"...Stored setting: %w\n",[SettingsHead]), %DEBUG
	storeSettings(SettingsTail).

%This does nothing. It exists so that the processTerm/1 condition of loopThroughFrames/0 succeeds for the
% "endOfFrames" case, so we can reach the exit condition at the end of loopThroughFrames/0.
%
inferFromTerm(endOfFrames).

%Pass the parser the current frame description (as if it were an incoming word) and initialize
% the stack of frames (i.e., the list of frame descriptors we've gotten so far as input). We push
% the current frame info only after the parser has finished with it, since the parser needs to be
% able to assume that the previous frame descriptor is at the top of this stack.
%
inferFromTerm(FrameTerm1) :-
	perceptibilityFilter(FrameTerm1,FrameTerm),
	processFrame(FrameTerm),
	pushOntoStack(FrameTerm, framesStack).

getSomeRule(Rule,RuleLabel) :-
	rule(	RuleLabel,
			<=(	cause(LHS, [RHSHead | RHSTail]),
				AnteList )),
	Rule = rule(RuleLabel,
				<=(cause(LHS, [RHSHead | RHSTail]),
				   AnteList )).
				
locateRHSHead(Rule, RHSHead) :-
	Rule = rule(_RuleLabel,
				<=(	cause(_LHS, [RHSHead | _RHSTail]),
					_AnteList )).
							
verifyRule( Rule, RHSHeadInst,						%data in
			LHS2, CF, ExpectedFrameItems) :-		%data out
	Rule = rule(_RuleLabel,
				<=(	cause(LHS, [RHSHead | RHSTail]),
					AnteList )),
	condPrintf(traceParser,">>RHSHead:     %w\n", [RHSHead]),
	condPrintf(traceParser,"  RHSHeadInst: %w\n", [RHSHeadInst]),
	RHSHead = RHSHeadInst, %Distribute candidate binds into copy of rule
		  
	condPrintf(traceParser,"<<queryAnteList %w\n", [AnteList]),
	queryAnteList(	AnteList,
					true,			%'true' means "allow backchaining"
					_AnteTrace ),
	condPrintf(traceParser,"  ...succeeded\n", []),
	LHS2 = LHS,
	lhsHasConfidenceFactor(LHS,CF), %Dig into LHS to see what CF should be bound to
	ExpectedFrameItems = RHSTail.

lhsHasConfidenceFactor(	figureHasTrajectory(
							_Id, _Trajectory,
							_ElapsedTime1, _ElapsedTime2,
							CF,
							_OriginalShapeAndColor, _DrawInstrs, _BaseRecursiveOrWiggle ),
						CF ).
lhsHasConfidenceFactor(	exertForceOn(
							_Id, _AttractiveOrRepulsive, _ForceMagnitude,
							_ExertedUponId, _LinearMovingTrajectory,
							_OriginalShapeAndColor,
							_ElapsedTime1, _ElapsedTime2,
							CF,
							_DrawInstrs ),
						CF ).
lhsHasConfidenceFactor( exertForceOn(
							_Id, _AttractiveOrRepulsive, _ForceMagnitude,
							_ExertedUponId, _CurvedTrajectory,
							_LinearSegmentInformation,
							_OriginalShapeAndColor,
							_ElapsedTime1, _ElapsedTime2,
							CF,
							_DrawInstrs ),
						CF ).
lhsHasConfidenceFactor( dummyTrigger1( 
							_ElapsedTime1,_ElapsedTime2,
   							CF,_DrawInstrs ),
   						CF ).
lhsHasConfidenceFactor( dummyTrigger2( 
							_ElapsedTime1,_ElapsedTime2,
   							CF,_DrawInstrs ),
   						CF ).
lhsHasConfidenceFactor( dummyTrigger3( 
							_ElapsedTime1,_ElapsedTime2,
   							CF,_DrawInstrs ),
   						CF ).
lhsHasConfidenceFactor( intend(Id,
							   atPosition(Id,position(_X2,_Y2),
					   			  		  ElapsedTime2
					   			         ),
					   		   _SomeTrajectory,
							   _ElapsedTime1,ElapsedTime2,
							   CF,_DrawInstrs, _BaseOrRecursive ),
						CF ).
lhsHasConfidenceFactor( intend(_Id,_AvoidOrApproach,
						_ApproachedOrThreatObjId,
						_CurvedTrajectory,_LinearSegmentInfo,
						originally(_Shape,_Color),
						_ElapsedTime1,_ElapsedTime2,
						CF,_DrawInstrs ),
						CF ).
lhsHasConfidenceFactor(	intend(
							_Id, _AvoidOrApproach,
							_ApproachedOrThreatObjId, 
							_LinearMovingTrajectory,
							originally(_Shape,_Color),
							_ElapsedTime1,_ElapsedTime2,
							CF,
							_DrawInstrs,
							_BaseOrRecursive ),
						CF ).
lhsHasConfidenceFactor( intend(
							_Id, AvoidOrApproach,
							_ApproachedOrThreatObjId,
							_ElapsedTime1,_ElapsedTime2,
							CF,
							_DrawInstrs ),
						CF ) :-
	(AvoidOrApproach = avoid,
	 !
	;
	 AvoidOrApproach = approach
	).
lhsHasConfidenceFactor( intentionChanged(
							_Id,_Intention1,
							_ElapsedTime2, _Intention2,
							_ElapsedTime1, _ElapsedTime3,
							CF,_DrawInstrs ),
						CF ).
lhsHasConfidenceFactor( wiggle(
							_FigureId,
 	 				   		_ElapsedTime1,_ElapsedTime3,
 	 				   		_LatestProjectedCircle,
 	 				   		_COBFRc,
 	 				   		_WigglePositionList,
 	 				   		_TrajectoryOfBestFit,
 	 				   		_Originally,
 	 				   		CF,_DrawInstrs ),
 	 				    CF ).
lhsHasConfidenceFactor( notice(
							_FigureId,
							_NoticedFigureId,
   					  		_ElapsedTime1,_ElapsedTime2,
   					  		CF,
   					  		_DrawInstrs ),
   					  	CF ).
lhsHasConfidenceFactor( augmented(LHSElements),CF ) :-
	lhsHasConfidenceFactor(LHSElements,CF).
lhsHasConfidenceFactor( conjunction(LHSElements),CF ) :-
	lhsHasConfidenceFactor(LHSElements,CF).
 	 				    
%This particular clause of lhsHasConfidenceFactor handles LHS with multiple triggers.
%It currently assumes all triggers are assigned the same confidence factor.
%Under this assumption, it can simply extract the first trigger's confidence factor.
%
lhsHasConfidenceFactor([LHSHead|_LHSTail],CF) :-
	lhsHasConfidenceFactor(LHSHead,CF).
 												
extractDrawingInstructions(	[],
							[],
							[] ).
extractDrawingInstructions(	[timestamp(T)|Tail],
							[],
							[timestamp(T)|Tail] ).
extractDrawingInstructions(	[H|T],
							DIs,
							HTwoDIs )
	:- 	extractDrawingInstructions(H, HDIs, HwoDIs),
		extractDrawingInstructions(T, TDIs, TwoDIs),
		makeIntoListWoNullMembers(HDIs, TDIs, DIs),
		makeIntoListWoNullMembers(HwoDIs, TwoDIs, HTwoDIs).
extractDrawingInstructions(	figureHasTrajectory(
								Id, Trajectory,
								ElapsedTime1, ElapsedTime2,
								CF,
								OriginalShapeAndColor, DrawInstrs, BaseRecursiveOrWiggle ),
							DrawInstrs,
							figureHasTrajectory(
								Id, Trajectory,
								ElapsedTime1, ElapsedTime2,
								CF,
								OriginalShapeAndColor, BaseRecursiveOrWiggle )).
extractDrawingInstructions(	figureHasTrajectory( %DIs already removed; not sure how this happens
								Id, Trajectory,
								ElapsedTime1, ElapsedTime2,
								CF,
								OriginalShapeAndColor, BaseRecursiveOrWiggle ),
							[],
							figureHasTrajectory(
								Id, Trajectory,
								ElapsedTime1, ElapsedTime2,
								CF,
								OriginalShapeAndColor, BaseRecursiveOrWiggle )).
extractDrawingInstructions(	exertForceOn(
								Id, AttractiveOrRepulsive, ForceMagnitude,
								ExertedUponId, LinearMovingTrajectory,
								OriginalShapeAndColor,
								ElapsedTime1, ElapsedTime2,
								CF,
								DrawInstrs ),
							DrawInstrs,
							exertForceOn(
								Id, AttractiveOrRepulsive, ForceMagnitude,
								ExertedUponId, LinearMovingTrajectory,
								OriginalShapeAndColor,
								ElapsedTime1, ElapsedTime2,
								CF )).
extractDrawingInstructions(	exertForceOn( %DIs already removed; not sure if this is ever used
								Id, AttractiveOrRepulsive, ForceMagnitude,
								ExertedUponId, LinearMovingTrajectory,
								OriginalShapeAndColor,
								ElapsedTime1, ElapsedTime2,
								CF ),
							[],
							exertForceOn(
								Id, AttractiveOrRepulsive, ForceMagnitude,
								ExertedUponId, LinearMovingTrajectory,
								OriginalShapeAndColor,
								ElapsedTime1, ElapsedTime2,
								CF )).
extractDrawingInstructions(	exertForceOn(
								Id, AttractiveOrRepulsive, ForceMagnitude,
								ExertedUponId, CurvedTrajectory,
								LinearSegmentInformation,
								OriginalShapeAndColor,
								ElapsedTime1, ElapsedTime2,
								CF,
								DrawInstrs ),
							DrawInstrs,
							exertForceOn(
								Id, AttractiveOrRepulsive, ForceMagnitude,
								ExertedUponId, CurvedTrajectory,
								LinearSegmentInformation,
								OriginalShapeAndColor,
								ElapsedTime1, ElapsedTime2,
								CF )).
extractDrawingInstructions( dummyTrigger1( ElapsedTime1,ElapsedTime2,
   								CF,DrawInstrs),
   							DrawInstrs,
   							dummyTrigger1( ElapsedTime1,ElapsedTime2,
   								CF) ).
extractDrawingInstructions( dummyTrigger2( ElapsedTime1,ElapsedTime2,
   								CF,DrawInstrs),
   							DrawInstrs,
   							dummyTrigger2( ElapsedTime1,ElapsedTime2,
   								CF) ).   								
extractDrawingInstructions( dummyTrigger3( ElapsedTime1,ElapsedTime2,
   								CF,DrawInstrs),
   							DrawInstrs,
   							dummyTrigger3( ElapsedTime1,ElapsedTime2,
   								CF) ).
extractDrawingInstructions( intend(Id,atPosition(Id,position(X2,Y2),
					   			  		         ElapsedTime2
					   			         		),
					   			   SomeTrajectory, 
								   ElapsedTime1,ElapsedTime2,
								   CF,DrawInstrs,BaseOrRecursive),
							DrawInstrs,
							intend(Id,atPosition(Id,position(X2,Y2),
												 ElapsedTime2
												),
									SomeTrajectory,
									ElapsedTime1,ElapsedTime2,
									CF,BaseOrRecursive) ).
extractDrawingInstructions( intend(Id,AvoidApproach,
									ApproachedOrThreatObjId,
									CurvedTrajectory,LinearSegmentInfo,
									originally(Shape,Color),
									ElapsedTime1,ElapsedTime2,
									CF,DrawInstrs),
							DrawInstrs,
							intend(Id,AvoidApproach,
									ApproachedOrThreatObjId,
									CurvedTrajectory,LinearSegmentInfo,
									originally(Shape,Color),
									ElapsedTime1,ElapsedTime2,
									CF) ).
extractDrawingInstructions(	intend(
								Id, AvoidOrApproach,
								ApproachedOrThreatObjId, 
								LinearMovingTrajectory,
								originally(Shape,Color),
								ElapsedTime1, ElapsedTime2,
								CF,DrawInstrs,BaseOrRecursive ),
							DrawInstrs,
							intend(
								Id, AvoidOrApproach,
								ApproachedOrThreatObjId, 
								LinearMovingTrajectory,
								originally(Shape,Color),
								ElapsedTime1, ElapsedTime2,
								CF,BaseOrRecursive) ).
extractDrawingInstructions( intend(
								Id, AvoidOrApproach,
								ApproachedOrThreatObjId,
								ElapsedTime1,ElapsedTime2,
								CF,
								DrawInstrs),
							DrawInstrs,
							intend(
								Id, AvoidOrApproach,
								ApproachedOrThreatObjId,
								ElapsedTime1,ElapsedTime2,
								CF) ) :-
	(AvoidOrApproach = avoid,
	 !
	;
	 AvoidOrApproach = approach
	).															
extractDrawingInstructions( intentionChanged( FigureId,
								 Intention1, ElapsedTime2, Intention2,
								 ElapsedTime1, ElapsedTime3,
								 CF,
								 DrawInstrs),
							DrawInstrs,
							intentionChanged( FigureId,
								 Intention1, ElapsedTime2, Intention2,
								 ElapsedTime1, ElapsedTime3,
								 CF ) ).
extractDrawingInstructions( wiggle(FigureId,
 	 				   			ElapsedTime1,ElapsedTime3,
 	 				   			latestProjectedCircle(Xc2,Yc2,R2,DirectionSign2),
 	 				 			COBFRc,
 	 				   			WigglePositionList,
 	 				   			TrajectoryOfBestFit,
 	 				   			Originally,
 	 				   			CF,
 	 				   			DrawInstrs),
 	 				   		DrawInstrs,
 	 				   		wiggle(FigureId,
 	 				   			ElapsedTime1,ElapsedTime3,
 	 				   			latestProjectedCircle(Xc2,Yc2,R2,DirectionSign2),
 	 				   			COBFRc,
 	 				   			WigglePositionList,
 	 				   			TrajectoryOfBestFit,
 	 				   			Originally,
 	 				   			CF ) ).
extractDrawingInstructions( notice(
									FigureId,
									NoticedFigureId,
   					  				ElapsedTime1,ElapsedTime2,
   					  				CF,
   					  				DrawInstrs ),
   					  		DrawInstrs,
   					  		notice(
   					  				FigureId,
									NoticedFigureId,
   					  				ElapsedTime1,ElapsedTime2,
   					  				CF ) ).
extractDrawingInstructions(augmented(LHSElements),DIs,augmented(LHSElementsWoDIs)) :-
	extractDrawingInstructions(LHSElements,DIs,LHSElementsWoDIs).
extractDrawingInstructions(conjunction(LHSElements),DIs,conjunction(LHSElementsWoDIs)) :-
	extractDrawingInstructions(LHSElements,DIs,LHSElementsWoDIs).

extractDrawingInstructions(	Debug,
							[],
							Debug )
	:- writeL(['Need extractDrawingInstructions/3 for: ',Debug]).
	
%This clause is commented out because it causes an unwanted binding to DI in the following scenario,
%in which DI is a yet to be bound drawing instruction: makeIntoListWoNullMembers(DI,[],DIs)
%makeIntoListWoNullMembers([],	[],		[]).
%This clause is commented out because a DI could be equal to [], and this clause won't include such a DI.
%Update: actually we do want to exclude DIs that are equal to [], but this clause could cause an unwanted binding.
%So we exclude [] DIs in a different clause below.
%makeIntoListWoNullMembers([],	[H|T],	[H|T]).
%This clause is commented out because a DI could be equal to [], and this clause won't include such a DI.
%Update: actually we do want to exclude DIs that are equal to [], but this clause could cause an unwanted binding.
%So we exclude [] DIs in a different clause below.
%makeIntoListWoNullMembers([],	B,		[B]). %Probably not used by Wayang
makeIntoListWoNullMembers(A,	[],		List) :-
	(A \== [] -> %check will exclude [] DIs without possibly binding unbound DIs.
		List = [A]
	;
		List = []
	).	 
makeIntoListWoNullMembers(A,	[H|T],	List) :-
	(A \== [] -> %check will exclude [] DIs without possibly binding unbound DIs.
		List = [A|[H|T]]
	;
		List = [H|T]
	).
makeIntoListWoNullMembers(A,	B,		[A,B]). %Probably not used by Wayang

figureCounter(frame([]),0).
figureCounter(frame([FrameHead|FrameBody]),TotalFigures) :-
	figureCounter(frame(FrameBody),TotalFigures1),
	(FrameHead = figure(_,_,_,_) ->
		TotalFigures is TotalFigures1 + 1
	;
		TotalFigures is TotalFigures1
	).