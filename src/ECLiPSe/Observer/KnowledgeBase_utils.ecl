/*==============================================================================
 *
 *  UTILITY RULES THAT IMPOSE CONSTRAINTS
 *
 *============================================================================*/

% For an explanation of our use of "delay...if...", see
%  file:///C:/Program%20Files/ECLiPSe%206.0/doc/userman/umsroot109.html
%  in your local ECLiPSe 6.0 installation.


%DOC	
% Constrain fig2 (using values from fig1) so that fig2 shows no apparent movement.
%
delay	figureIsStationary(	FigureId,
							observ1(ElapsedTime1,position(X1,Y1),Shape1,Color1),
							observ2(ElapsedTime2,position(X2,Y2),Shape2,Color2),
							StationaryTrajectory )
		if nonground([	ElapsedTime1,X1,Y1,Shape1,Color1,
						ElapsedTime2,X2,Y2,Shape2,Color2 ]).
figureIsStationary(			FigureId,
							observ1(ElapsedTime1,position(X1,Y1),Shape1,Color1),
							observ2(ElapsedTime2,position(X2,Y2),Shape2,Color2),
							StationaryTrajectory ) :-
	figureIs2DCoherentBetweenFrames(
		FigureId,
		observ1(ElapsedTime1,position(X1,Y1),Shape1,Color1),
		observ2(ElapsedTime2,position(X2,Y2),Shape2,Color2) ),
		
	distanceTravelledAcrossFramesIsPerceptible(
		false, %DesiredTruthValue
		FigureId,
		observ1(ElapsedTime1,position(X1,Y1)),
		observ2(ElapsedTime2,position(X2,Y2)) ),
	
	%Define the trajectory
	StationaryTrajectory = stationaryTrajectory(originalPosition(X1, Y1)).
%DOC
%Ideally, when we package up inference results in generateEdgeSummaryForJava/2
% to pass to Java, we'd also be able to add some instructions about how those
% inferences might be displayed in a visualization. And as part of that task,
% when we needed to generate instructions about unbound but constrained vars
% (usually part of a prediction in the RHS_expectedParts part of the Edge
% parameter to generateEdgeSummaryForJava/2), ideally we'd be able to unpack the
% constraints stored in those vars (as delayed goals which indicate, say, the
% subregion where an object is constrained/predicted to be next). Unfortunately,
% the moderators of the EclipseCLP mailing list say the representation of
% delayed goals wouldn't permit such inspection and interpretation, and they
% recommend instead writing special purpose code that associates a viz template
% with the delayable goal. To minimize the risk that the code to implement a
% specific delayable goal might be updated without making corresponding changes
% to the viz template, we have designed the viz templates so they can be listed
% next to the corresponding delayable goal code (in this file); furthermore,
% to keep the pairing as tight as possible, calls to determine the viz appear
% just after calls to the delayable goal code in schema/rule contingency lists.
%

genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime2,LHSWithoutDIWithCFReplaced,CF,		 %Input
					ListToConvertFromSpatialUnitsToPixelsRoundedInInteger,ListToConvertFromTermsToStrings,
					DrawFunctor,
					DrawInstrs 																			 %Output
				   ) :-
	Shape1 = circle(D1), %//TODO account for other possible shapes as well
	delayableDisjunctedCalls([CF], FloatCF is float(CF)), %if CF is a bounded real, convert it to float 
						  								  %before putting it in the draw instrs, since 
						  								  %Java expects a float value for CF. If CF is 
						  								  %already a float, the predicate call will keep 
						  								  %it as it is
	convertListElementsFromSpatialUnitsToPixelsRoundedInInteger(
					ListToConvertFromSpatialUnitsToPixelsRoundedInInteger,
					ListOfPixelsRoundedInInteger1),
	convertListElementsFromSpatialUnitsToPixelsRoundedInInteger([D1],[D1InPixelsRoundedInInteger]),
	convertTermsToStrings(ListToConvertFromTermsToStrings,ListOfStrings),
	convertTermsToStrings([LHSWithoutDIWithCFReplaced],[LHSStringModified]),
	assignGraphicalDisplayFunctor(DrawFunctor,GraphicalDisplayFunctor),
	assignLHSFunctorString(DrawFunctor,LHSFunctorString),
	%ListOfPixelsRoundedInInteger1 might have an element which is itself a list (of (X,Y) positions).
	%This is true for higher level ascriptions. For such an element, we replace the list operator with a functor
	%wrapper called "listOfPositions"
	(foreach(PixelsRoundedInInteger1,ListOfPixelsRoundedInInteger1),
	 foreach(PixelsRoundedInInteger,ListOfPixelsRoundedInInteger) do
		Constraint = 
		(is_list(PixelsRoundedInInteger1) ->
			PixelsRoundedInInteger =.. [listOfPositions|PixelsRoundedInInteger1]
		;
			PixelsRoundedInInteger = PixelsRoundedInInteger1
		),
		delayableDisjunctedCalls(PixelsRoundedInInteger1,Constraint)
	), 
	%Construct graphical display term
	%Create list which would be converted into a graphical display term using =..
	append([GraphicalDisplayFunctor,Color1],ListOfPixelsRoundedInInteger,GraphicalDisplayList1),
	append(GraphicalDisplayList1,[circle(D1InPixelsRoundedInInteger)],GraphicalDisplayList2),
	append(GraphicalDisplayList2,ListOfStrings,GraphicalDisplayList),
	%Create the graphical display term
	GraphicalDisplayTerm =.. GraphicalDisplayList,
	%Create the content of the draw instrs term (without the draw functor)
	%DrawID, ListOfRHSMatchingAncestorDrawIDs and FrameNumber are placeholders for the 
	%actual values,which can only be filled when the edge is asserted.
	DrawInstrs1 =.. [DrawFunctor,"observation",_DrawID,_ListOfRHSMatchingAncestorDrawIDs,FigureId,_FrameNumber,
					 LHSStringModified,LHSFunctorString,ElapsedTime1,ElapsedTime2,FloatCF,GraphicalDisplayTerm],
	%Create the draw instr term
	DrawInstrs = draw(DrawInstrs1).

%DOC
%Assign GraphicalDisplayFunctor for a given DrawFunctor
%
assignGraphicalDisplayFunctor(stationary,graphicalDisplayForStationaryTrajectory).
assignGraphicalDisplayFunctor(linear,graphicalDisplayForLinearTrajectory).
assignGraphicalDisplayFunctor(curved,graphicalDisplayForCurvedTrajectory).
assignGraphicalDisplayFunctor(singleForce,graphicalDisplayForSingleForce).
assignGraphicalDisplayFunctor(combinedForces,graphicalDisplayForCombinedForces).
assignGraphicalDisplayFunctor(intentionToApproachOrAvoid,graphicalDisplayForIntentionToApproachOrAvoid).
assignGraphicalDisplayFunctor(combinedIntentionToApproachAndAvoid,graphicalDisplayForCombinedIntentionToApproachAndAvoid).
assignGraphicalDisplayFunctor(intentionToBeAtPosition,graphicalDisplayForIntentionToBeAtPosition).
assignGraphicalDisplayFunctor(notice,graphicalDisplayForNotice).
assignGraphicalDisplayFunctor(intentionToApproachAugmentedWithIntentionToAvoid,graphicalDisplayForIntentionToApproachAugmentedWithIntentionToAvoid).
assignGraphicalDisplayFunctor(wiggle,graphicalDisplayForWiggle).
assignGraphicalDisplayFunctor(trajectoryFromWiggle,graphicalDisplayForTrajectoryFromWiggle).

%DOC
%Assign LHSFunctorString for a given DrawFunctor
%
assignLHSFunctorString(stationary,"figureHasTrajectory").
assignLHSFunctorString(linear,"figureHasTrajectory").
assignLHSFunctorString(curved,"figureHasTrajectory").
assignLHSFunctorString(singleForce,"exertForceOn").
assignLHSFunctorString(combinedForces,"exertForceOnCombined").
assignLHSFunctorString(intentionToApproachOrAvoid,"intend").
assignLHSFunctorString(combinedIntentionToApproachAndAvoid,"intendCombined").
assignLHSFunctorString(intentionToBeAtPosition,"intend").
assignLHSFunctorString(notice,"notice").
assignLHSFunctorString(intentionToApproachAugmentedWithIntentionToAvoid,"intendAugmented").
assignLHSFunctorString(wiggle,"wiggle").
assignLHSFunctorString(trajectoryFromWiggle,"figureHasTrajectoryFromWiggle").

%DOC
% Convert all elements of the given list from SpatialUnits to Pixels, rounded in integer format.
% Returns the result in a list.
%
convertListElementsFromSpatialUnitsToPixelsRoundedInInteger(SpatialUnitsList,PixelsRoundedInIntegerList) :-
	(foreach(SpatialUnits,SpatialUnitsList),foreach(PixelsRoundedInInteger,PixelsRoundedInIntegerList) do
		Constraint = 
			((%SpatialUnits can itself be a list,
			  %specifically a list of (X,Y) positions
			  is_list(SpatialUnits) ->
		      	(foreach(SpatialUnitsElement,SpatialUnits),foreach(PixelsElementRoundedInInteger,PixelsRoundedInInteger) do
		      		SpatialUnitsElement = position(XInSU,YInSU),
		      		convertSpatialUnitsToPixels(XInSU,XInPixels),
		      		convertSpatialUnitsToPixels(YInSU,YInPixels),
		      		XInPixelsRounded is round(XInPixels),
		      		YInPixelsRounded is round(YInPixels),
		      		XInPixelsRoundedInInteger is integer(XInPixelsRounded),
		      		YInPixelsRoundedInInteger is integer(YInPixelsRounded),
			 		PixelsElementRoundedInInteger = position(XInPixelsRoundedInInteger,YInPixelsRoundedInInteger)
			 	)
			 ;		  				
			 	convertSpatialUnitsToPixels(SpatialUnits,Pixels),
			 	PixelsRounded is round(Pixels),
			 	PixelsRoundedInInteger is integer(PixelsRounded)
			)),
		delayableDisjunctedCalls([SpatialUnits],Constraint)
	).

%DOC
% Convert all terms in the given list to strings. Returns the result in a list.
%
convertTermsToStrings(Terms,Strings) :-
	(foreach(Term,Terms),foreach(String,Strings) do
		delayableDisjunctedCalls([Term],term_string(Term,String))
	).

%DOC
% Update the given draw instruction(s) with the current frame number, draw ID and parent draw IDs,
% which should correspond to the given edge Ids.
updateDrawInstrsWithCurrentFrameNumberAndDrawIdAndRHSMatchingAncestorDrawIds([],_,_,[]).
updateDrawInstrsWithCurrentFrameNumberAndDrawIdAndRHSMatchingAncestorDrawIds([LHSDrawInstr|LHSDrawInstrs],EdgeId,RHSMatchingAncestorEdgeIds,[LHSDrawInstr1|LHSDrawInstrs1]) :-
	 updateSingleDrawInstrWithCurrentFrameNumberAndDrawIdAndRHSMatchingAncestorDrawIds(LHSDrawInstr,EdgeId,RHSMatchingAncestorEdgeIds,LHSDrawInstr1),
	 updateDrawInstrsWithCurrentFrameNumberAndDrawIdAndRHSMatchingAncestorDrawIds(LHSDrawInstrs,EdgeId,RHSMatchingAncestorEdgeIds,LHSDrawInstrs1).
updateDrawInstrsWithCurrentFrameNumberAndDrawIdAndRHSMatchingAncestorDrawIds(LHSDrawInstr,EdgeId,RHSMatchingAncestorEdgeIds,LHSDrawInstr1) :-
	LHSDrawInstr \= [_|_],
	updateSingleDrawInstrWithCurrentFrameNumberAndDrawIdAndRHSMatchingAncestorDrawIds(LHSDrawInstr,EdgeId,RHSMatchingAncestorEdgeIds,LHSDrawInstr1).
	
updateSingleDrawInstrWithCurrentFrameNumberAndDrawIdAndRHSMatchingAncestorDrawIds(LHSDrawInstr,EdgeId,RHSMatchingAncestorEdgeIds,LHSDrawInstr1) :-
	 LHSDrawInstr =.. [DrawFunctor,ToDraw], % draw(...)
	 ToDraw =.. [ToDrawFunctor,EpistemicStatus,_DrawId,_ListOfRHSMatchingAncestorDrawIds,FigureId,_FrameNumber|OtherArgs], % e.g linear(EpistemicStatus,DrawId,ListOfRHSMatchingAncestorDrawIds,FigureId,FrameNumber,...)
	 currentSpanEnd(CurrentSpanEnd),
	 CurrentFrameNumber is CurrentSpanEnd - 1,
	 extractIdNumberFromSingleEdgeId(EdgeId,CurrentDrawId),
	 extractIdNumbersFromEdgeIds(RHSMatchingAncestorEdgeIds,ListOfRHSMatchingAncestorDrawIds1),
	 CurrentListOfRHSMatchingAncestorDrawIds =..[listOfRHSMatchingAncestorDrawIds|ListOfRHSMatchingAncestorDrawIds1],
	 ToDraw1 =.. [ToDrawFunctor,EpistemicStatus,CurrentDrawId,CurrentListOfRHSMatchingAncestorDrawIds,FigureId,CurrentFrameNumber|OtherArgs],
	 LHSDrawInstr1 =.. [DrawFunctor,ToDraw1].
												
%DOC
%Given either a list of edge Ids or a single edge Id, which are atoms, extract the numbers from those edge Ids.
%
extractIdNumbersFromEdgeIds([],[]).
extractIdNumbersFromEdgeIds([EdgeId|EdgeIds],[IdNumber|IdNumbers]) :-
	extractIdNumberFromSingleEdgeId(EdgeId,IdNumber),
	extractIdNumbersFromEdgeIds(EdgeIds,IdNumbers).

extractIdNumberFromSingleEdgeId(EdgeId,IdNumber) :-
	atom_string(EdgeId,EdgeIdString),
	split_string(EdgeIdString,"e","",Substrings),
	append(_,[IdNumberString],Substrings),
	number_string(IdNumber,IdNumberString).

%DOC
%Convert given value from spatial units to pixels
convertSpatialUnitsToPixels(ValueInSpatialUnits,ValueInPixels) :-
	setting(twipsPerSpatialUnit(TwipsPerSpatialUnit)),			
	setting(pixelsPerTwip(PixelsPerTwip)),
	ValueInPixels is ValueInSpatialUnits * TwipsPerSpatialUnit * PixelsPerTwip.

%DOC	
% Constrain fig2 (using values from fig1) so that fig2 shows smooth linear motion.
%
delay	figureMovesLinearly(	FigureId,
	 					observ1(ElapsedTime1,position(X1,Y1),Shape1,Color1),
	 					observ2(ElapsedTime2,position(X2,Y2),Shape2,Color2),
	 					LinearMovingTrajectory )
		if nonground([	ElapsedTime1,X1,Y1,Shape1,Color1,
						ElapsedTime2,X2,Y2,Shape2,Color2 ]).
figureMovesLinearly(	FigureId,
	 					observ1(ElapsedTime1,position(X1,Y1),Shape1,Color1),
	 					observ2(ElapsedTime2,position(X2,Y2),Shape2,Color2),
	 					LinearMovingTrajectory ) :-
	figureIs2DCoherentBetweenFrames(
		FigureId,
		observ1(ElapsedTime1,position(X1,Y1),Shape1,Color1),
		observ2(ElapsedTime2,position(X2,Y2),Shape2,Color2) ),
		
	distanceTravelledAcrossFramesIsPerceptible(
		true, %DesiredTruthValue
		FigureId,
		observ1(ElapsedTime1,position(X1,Y1)),
		observ2(ElapsedTime2,position(X2,Y2)) ),
	
	%Define the trajectory
	XMagn is (X2 - X1)/(ElapsedTime2 - ElapsedTime1),
	YMagn is (Y2 - Y1)/(ElapsedTime2 - ElapsedTime1),
	
	LinearMovingTrajectory
		= linearMovingTrajectory(	lastPosition(X2, Y2),
									magnitude(XMagn, YMagn),
									_Acceleration,   %acceleration is calculated in
													 %trajectory rule
									_PositionList ). 													 

%DOC
% Constrain 3 observed points so that they form a curved trajectory.
% CF value is calculated in the constraint in the following way:
% We start with a predetermined maximum value that corresponds to an
% ideal curve. The value is then multiplied by three factors corresponding
% to the following contributors: angle difference, value of the smaller
% angle and value of the radius. The value of each of these three factors
% is determined by means of a normal distribution centred around the ideal
% value for each of the three factors.
% We use the bell curve formula:
% f(x) = 1 / sqrt(2 * pi * sigma ^ 2) * e ^(-(x - mu)^2 / (2 * sigma ^2)) 
% where sigma is the standard deviation and mu is the mean.
% Note that the result would need to be scaled such that the mean would
% give a factor of 1
%
delay figureMovesCurvilinearly( FigureId,
						observ1(ElapsedTime1,position(X1,Y1),Shape1,Color1),
						observ2(ElapsedTime2,position(X2,Y2),Shape2,Color2),
						observ3(ElapsedTime3,position(X3,Y3),Shape3,Color3),
						CurvedTrajectory,
						CF )
	  if nonground([ ElapsedTime1,X1,Y1,Shape1,Color1,
	  				 ElapsedTime2,X2,Y2,Shape2,Color2,
	  				 ElapsedTime3,X3,Y3,Shape3,Color3 ]).
figureMovesCurvilinearly( FigureId,
						observ1(ElapsedTime1,position(X1,Y1),Shape1,Color1),
						observ2(ElapsedTime2,position(X2,Y2),Shape2,Color2),
						observ3(ElapsedTime3,position(X3,Y3),Shape3,Color3),
						CurvedTrajectory,
						CF ) :-
	figureIs2DCoherentBetweenFrames(
		FigureId,
		observ1(ElapsedTime1,position(X1,Y1),Shape1,Color1),
		observ2(ElapsedTime2,position(X2,Y2),Shape2,Color2) ),
	figureIs2DCoherentBetweenFrames(
		FigureId,
		observ1(ElapsedTime2,position(X2,Y2),Shape2,Color2),
		observ2(ElapsedTime3,position(X3,Y3),Shape3,Color3) ),
	distanceTravelledAcrossFramesIsPerceptible(
		true, %DesiredTruthValue
		FigureId,
		observ1(ElapsedTime1,position(X1,Y1)),
		observ2(ElapsedTime2,position(X2,Y2)) ),
	distanceTravelledAcrossFramesIsPerceptible(
		true, %DesiredTruthValue
		FigureId,
		observ1(ElapsedTime2,position(X2,Y2)),
		observ2(ElapsedTime3,position(X3,Y3)) ),
	circleThroughThreePoints(X1,Y1,X2,Y2,X3,Y3,X4,Y4,Radius),
	angleBetweenTwoVectors(X1,Y1,X2,Y2,X4,Y4,Angle1,Sign1),
	angleBetweenTwoVectors(X2,Y2,X3,Y3,X4,Y4,Angle2,Sign2),
	Sign1 =:= Sign2, %movement must be unidirectional
	AngleDelta is Angle1 - Angle2,
	abs(AngleDelta,AbsAngleDelta),
	ic:min([Angle1,Angle2],MinAngle),
	CurvedTrajectory
		= curvedTrajectory(secondToLastPosition(X2,Y2),
								secondToLastElapsedTime(ElapsedTime2),
								lastPosition(X3,Y3),
		 			 			latestProjectedCircle(X4,Y4,Radius,Sign1),%Sign1 is useful as an indication of 
		 			 													  %where the circle is in relation to
		 			 													  %the curved trajectory
		 			 			magnitude(XMagn,YMagn),
		 			 			acceleration([(XAccel,YAccel,AccelDirection)|_PrevAccelTriplets]),
		 			 			_PositionList,_CircleOfBestFit),
	
	%Calculate magnitude
	XMagn is (X3 - X2) / (ElapsedTime3 - ElapsedTime2),
	YMagn is (Y3 - Y2) / (ElapsedTime3 - ElapsedTime2),
	
	XMagn0 is (X2 - X1) / (ElapsedTime2 - ElapsedTime1),
	YMagn0 is (Y2 - Y1) / (ElapsedTime2 - ElapsedTime1),
	
	%Calculate acceleration
	%Transpose the previous magnitude values (XMagn0,YMagn0) to the direction of
	%the current trajectory (XMagn,YMagn). This seems to be a good approximation 
	%of how human observers would judge acceleration after a change of direction.
	PrevSpeedSquared is XMagn0 ^ 2 + YMagn0 ^ 2,
	sqrt(PrevSpeedSquared, PrevSpeed),
	%Calculate angle of the current trajectory relative to the +ve
	%X-axis, then transpose the previous magnitude values in the
	%direction specified by the angle of the current trajectory.
	angleBetweenTwoVectors(1,0,XMagn,YMagn,0,0,Angle3,Sign),
	(Sign >= 0 ->
		Angle = Angle3
	;
		Angle is 360 - Angle3
	),
	AngleInRads is Angle * pi / 180,
	TransposedXMagn0 is PrevSpeed * cos(AngleInRads),
	TransposedYMagn0 is PrevSpeed * sin(AngleInRads),
	
	calculateAcceleration(TransposedXMagn0,TransposedYMagn0,XMagn,YMagn,ElapsedTime2,
		 				  ElapsedTime3,XAccel,YAccel,AccelDirection),
	
	%Calculate CF
	CF1 is 0.8, %starting value, the max possible CF value.
	
	%Compute the factor contributed by the angle difference.
	%Let mu = 0 (ideally there should be no difference in angle)
	%Let sigma = 10 (beyond a deviation of 30 degrees the factor 
	%would be very low)
	%ADF stands for Angle Difference Factor
	%//TODO put the parameters of the curve in the properties file 
	Mu = 0,
	Sigma = 10,
	bellCurve(mu(Mu),sigma(Sigma),AbsAngleDelta,ADF),
	
	%Compute the factor contributed by the value of the smaller angle.
	%The smaller the angle is, the more accurate the points are at
	%representing a curve. Of course, if the angle is too small,
	%movement might not be perceivable. This is handled already by
	%an earlier constraint. Set a reasonable angle as the ideal.
	%To compute this angle, we find the smallest angle for which
	%a movement is perceivable, given a radius, which we know.
	%That is, we find the apex angle of the isosceles triangle
	%which has the radius as its two equal sides and the minimum
	%perceptible distance as its base.
	%This angle can be found as follows:
	%apex angle = 2 * arcsin(0.5 * min perceivable dist / radius).
	%
	setting(minPerceptibleChangeInPosition(MinPerceptibleChangeInPosition)),
	ApexAngle1 is 2 * asin(0.5 * MinPerceptibleChangeInPosition / Radius),
	ApexAngle is ApexAngle1 / pi * 180, % convert from rad to degrees
	
	%set mu to be the apex angle,
	%set sigma to be 30 (beyond a deviation of 90 degrees the factor
	%would be very low)
	%SAF stands for Smaller Angle Factor
	%//TODO put sigma in the properties file
	Mu2 = ApexAngle,
	Sigma2 = 30,
	bellCurve(mu(Mu2),sigma(Sigma2),MinAngle,SAF),
	
	%Compute the factor contributed by the value of the radius.
	%The smaller the radius is, the more curvy the curve is.
	%set mu to be 0,
	%set sigma to be 80 (beyond a deviation of 240 spatial units / approx
	%120 mms on a 22 inch 1680 x 1050 resolution screen, 
	%the factor would be very low)
	%RF stands for Radius Factor
	%//TODO put the parameters in the properties file
	Mu3 = 0,
	Sigma3 = 80,
	bellCurve(mu(Mu3),sigma(Sigma3),Radius,RF),
	
	CF is CF1 * ADF * SAF * RF.
	
%DOC
%Constrain the acceleration/deceleration profile of a trajectory such that
% the trajectory displays a pattern consistent with intention to be at a 
% position and combined intention to avoid and to approach. The trajectory
% can either be linear / curved / curved with linear follow-up.
% This version of the constraint simply imposes an ordering as follows:
%  Acceleration(optional) - constant speed(optional) - deceleration(optional)
% Obviously, at least one part needs to exist.
% There are no other constraints, such as constraints on values.
%
figureMovesWithConsistentAccelerationProfile(intendAtPositionOrAvoidApproach,
		AccelList) :-
	%The result of the reverse operation is a list of acceleration values that
	%is ordered such that the earliest acceleration pair appears first in the
	%list. This ordering seems more convenient and intuitive to work with.
	reverse(AccelList,RevAccelList),
	
	(foreach(AccelerationTriplet,RevAccelList),foreach(AccelerationDirection,AccelDirectionList) do
		AccelerationTriplet = (_,_,AccelerationDirection)
	),
	listIsInNonAscendingOrder(AccelDirectionList).

%DOC
%Constrain the acceleration/deceleration profile of a trajectory such that
% the trajectory displays a pattern consistent with attractive/repulsive 
% forces and a combination of attractive and repulsive forces. The trajectory
% can either be linear / curved / curved with linear follow-up.
% This version of the constraint constrains the trajectory such that there is
% near constant positive acceleration throughout the movement.
%
figureMovesWithConsistentAccelerationProfile(attractiveRepulsiveOrAttractiveRepulsiveCombined,
		AccelList) :-
	%The result of the reverse operation is a list of acceleration values that
	%is ordered such that the earliest acceleration pair appears first in the
	%list. This ordering seems more convenient and intuitive to work with.
	reverse(AccelList,RevAccelList),
	accelListDisplaysNearConstantPositiveAcceleration(RevAccelList).

%DOC
%Constrain the 2 circles of best fit of 2 curves defining a wiggle to be on opposite sides. Also constrain
%the radii of the circles to be similar.
%
delay figureMovesWithConsistentWigglyPattern(DirectionSign1,DirectionSign2,R1,R2)
	if nonground([DirectionSign1,DirectionSign2,R1,R2]).
figureMovesWithConsistentWigglyPattern(DirectionSign1,DirectionSign2,R1,R2) :-
	%Constrain the defining circles to lie on opposite sides. Also constrain
 	%the sizes of the defining circles to be similar.
 	%//TODO Should we also define an upper limit on the radius of the defining
 	%circles? This is to exclude nearly straight line segments.  
 	DirectionSign1 is -DirectionSign2,
 	(R1 >= R2 ->
 		RRatio is R1 / R2
 	;
 		RRatio is R2 / R1
 	),
	setting(maxAllowableRatioForWiggleDefiningCOBFs(MaxAllowableRatioForWiggleDefiningCOBFs)),
	RRatio =< MaxAllowableRatioForWiggleDefiningCOBFs.
 
%DOC
%Check whether one vector component largely agrees with the same component
% from another vector. For example, one might have a movement vector from
% observations 1 and 2, and a movement vector from observations 2 and 3; this
% pred can be used to check first the X components of those vectors for
% agreement, and then the Y components of those vectors, to ensure the movement
% across the three observations doesn't change direction or speed.
%
delay magnitudesAreWithinErrorRange(Magn1,Magn2) if nonground([Magn1,Magn2]).
magnitudesAreWithinErrorRange(Magn1,Magn2) :-
	MagnDiff1 is (Magn2 - Magn1),
	abs(MagnDiff1, MagnDiff),
	setting(maxAllowableErrorInMagnitude(MaxAllowableErrorInMagnitude)),
	MagnDiff =< MaxAllowableErrorInMagnitude.
	
%DOC
%Similar to magnitudesAreWithinErrorRange/2, but for accelerations.
delay accelerationsAreWithinErrorRange(Accel1,Accel2) if nonground([Accel1,Accel2]).
accelerationsAreWithinErrorRange(Accel1,Accel2) :-
	AccelDiff1 is (Accel2 - Accel1),
	abs(AccelDiff1, AccelDiff),
	setting(maxAllowableErrorInAcceleration(MaxAllowableErrorInAcceleration)),
	AccelDiff =< MaxAllowableErrorInAcceleration.

%DOC
%
delay regularityFromForce(ExertedUponId,Shape1,Trajectory1,ElapsedTime2,	
							TargetId,AttractiveOrRepulsive,ForceMagnitude,	
							CF2 )
		if nonground([Trajectory1,ElapsedTime2]).
regularityFromForce(ExertedUponId,Shape1,Trajectory1,ElapsedTime2,	%input
					TargetId,AttractiveOrRepulsive,					%in/out
					ForceMagnitude, CF2 ) :-						%output
	%The target and the obj being attracted or repulsed must be different objs
	TargetId #\= ExertedUponId,
	%Force magnitude is represented as the magnitude of the observed acceleration.
	%Since acceleration is required to be near constant for attractive/repulsive forces 
	%(see figureMovesWithConsistentAccelerationProfile/2), we just use the first acceleration
	%triplet in the list of acceleration triplets. 
	Trajectory1 = linearMovingTrajectory(_Position1,
										 _Magnitude,
										 acceleration([(XAccel1,YAccel1,_Direction)|_RemainingAccelTriplets]),_),
	ForceMagnitudeSquared is XAccel1 ^ 2 + YAccel1 ^ 2,
	sqrt(ForceMagnitudeSquared,ForceMagnitude),
		 
	%Whereever the target is right now should also be where the approacher is
	% headed. If the target is moving, ignore the movement and treat it as
	% being stationary for the purpose of estimating if the approacher is on an
	% intercept course.
	%Note that the start time of the target's trajectory doesn't have to be the
	% same as the start time of the approacher's trajectory.
	%Note that we can't just post figureHasTrajectory here as a Prolog query,
	% because if it is in working memory, it's embedded in a chart edge (as the
	% result of an abduction), not as a free-standing assertion. Allowing gating
	% conditions (aka contingencies) to tap into the results of previous
	% abductions is one thing that makes Wayang a little more powerful than the
	% incremental feature-grammar parser it's derived from. (Other Wayang
	% features that parsers don't have are: 1) contingencies can use almost any
	% predicate, not just = and !=, 2) contingencies can be delayed until some
	% or all of their vars are bound.)
	%
	findAnyCorroboratingEdge(
		_SpanEnd1,_SpanEnd2,
		[timestamp(ElapsedTime2),
		 figure(TargetId,Position2,Shape2,_Color2)],
		/*figureHasTrajectory(TargetId,
							Trajectory2,
							_ElapsedTime1b,ElapsedTime2,
							CF2,
							originally(Shape2,_Color2),
							_DrawInstructions,_BaseRecursiveOrWiggle ),*/
		CF2, _ParentId, _RHS_parsedParts ),					
	makeNonResistiveStationaryTrajectory(Position2,Trajectory3),
	((onInterceptCourse(Shape1,Trajectory1, Shape2,Trajectory3),
	  AttractiveOrRepulsive = attractive )
	 ;
	 (invertTrajectory(Trajectory1,Trajectory1Inverted),
	  onInterceptCourse(Shape1,Trajectory1Inverted, Shape2,Trajectory3),
	  AttractiveOrRepulsive = repulsive )).

						
/*==============================================================================
 *
 *  UTILITY RULES
 *
 *============================================================================*/

delay euclideanDistance(X1,Y1, X2,Y2, Distance)
	if nonground([X1,Y1,X2,Y2]).
euclideanDistance(X1,Y1, X2,Y2, Distance) :-
	XDiff is (X2 - X1),
	YDiff is (Y2 - Y1),
	^(XDiff,2,XDiffSquared),
	^(YDiff,2,YDiffSquared),
	SquaresSum is (XDiffSquared + YDiffSquared),
	sqrt(SquaresSum,Distance).

delay figureIs2DCoherentBetweenFrames(
					FigureId,
					observ1(ElapsedTime1,position(X1,Y1),Shape1,Color1),
					observ2(ElapsedTime2,position(X2,Y2),Shape2,Color2) )
	if nonground([FigureId,ElapsedTime1,X1,Y1,Shape1,Color1,
				  ElapsedTime2,X2,Y2,Shape2,Color2]).
figureIs2DCoherentBetweenFrames(
					FigureId,
					observ1(ElapsedTime1,position(X1,Y1),Shape1,Color1),
					observ2(ElapsedTime2,position(X2,Y2),Shape2,Color2) ) :-
	%The figure doesn't change shape, size, or color (although it might rotate)
	figureMaintainsAreaBetweenFrames(	FigureId,
										ElapsedTime1,
										Shape1,
										ElapsedTime2,
										Shape2 ),
	!,figureMaintainsShapeBetweenFrames(FigureId,
										ElapsedTime1,
										Shape1,
										ElapsedTime2,
										Shape2 ),
	!,figureMaintainsColorBetweenFrames(FigureId,
										ElapsedTime1,
										Color1,
										ElapsedTime2,
										Color2),
	%There is no flicker due to a large shift relative to figure size
	%Nor is there any flicker due to a slow frame shutter during movement
	!,figureDoesntFlickerAcrossFrames(	FigureId,
										ElapsedTime1,
										X1,Y1,X2,Y2,Shape1,
										ElapsedTime2 ).

figureMaintainsAreaBetweenFrames(	FigureId,
									ElapsedTime1,
									Shape1,
									ElapsedTime2,
									Shape2 ) :-
	ElapsedMsec is ElapsedTime2 - ElapsedTime1,
	((not areaChangeBetweenFrames(Shape1,Shape2,ElapsedMsec))
	 -> true
	 ;  assert( discontinuity(areaChangeBetweenFrames(	FigureId,
	 													ElapsedTime1,
	 													Shape1,
	 													ElapsedTime2,
	 													Shape2 ))),
	    !,fail ).

areaChangeBetweenFrames(Shape1,Shape2,ElapsedMsec) :-
	hasApparentArea(Shape1,Area1), %defined in src/...perceptibilityFilter.pro
	hasApparentArea(Shape2,Area2),
	AreaChange1 is Area2 - Area1,
	abs(AreaChange1,AreaChange),
	AreaChangeSpeed is AreaChange/ElapsedMsec,
	setting(minPerceptibleAreaChangePerMsec(MinPerceptibleAreaChangePerMsec)),
	!,AreaChangeSpeed >= MinPerceptibleAreaChangePerMsec.


figureMaintainsShapeBetweenFrames(	FigureId,
									ElapsedTime1,
									Shape1,
									ElapsedTime2,
									Shape2 ) :-
	((not shapeChangeBetweenFrames(Shape1,Shape2))
	 -> true
	 ;  assert( discontinuity(shapeChangeBetweenFrames(	FigureId,
	 													ElapsedTime1,
	 													Shape1,
	 													ElapsedTime2,
	 													Shape2 ))),
	    !,fail ).
	
shapeChangeBetweenFrames(Shape1,Shape2) :-
	not (	functor(Shape1,ShapeFunctor,Arity),
			functor(Shape2,ShapeFunctor,Arity) ).
	
	
figureMaintainsColorBetweenFrames(	FigureId,
									ElapsedTime1,
									Color1,
									ElapsedTime2,
									Color2) :-
	ElapsedMsec is ElapsedTime2 - ElapsedTime1,
	((not colorChangeBetweenFrames(Color1,Color2,ElapsedMsec))
	 -> true
	    %This might be used to trigger a rule that ascribes a 3rd dimension
	    % and that the figure has rotated or moved toward/from a light source
	 ;  assert( discontinuity(colorChangeBetweenFrames(	FigureId,
									 					ElapsedTime1,
									 					Color1,
									 					ElapsedTime2,
									 					Color2 ))),
	    !,fail ).
	    
colorChangeBetweenFrames(Color1,Color2,ElapsedMsec) :-
	hasRGBDifference(Color1,Color2,Diff), %defd src/...perceptibilityFilter.pro
	DiffPerMsec is Diff/ElapsedMsec,
	setting(minPerceptibleColorChangePerMsec(MinPerceptibleColorChangePerMsec)),
	!,DiffPerMsec >= MinPerceptibleColorChangePerMsec.
	
	
figureDoesntFlickerAcrossFrames(FigureId,
								ElapsedTime1,
								X1,Y1,X2,Y2,Shape,
								ElapsedTime2 ) :-
	euclideanDistance(X1,Y1,X2,Y2,DistanceTravelled),
	((DistanceTravelled > 0) %Avoid division by zero
	 -> (((not flickerDueToDistanceTravelled(Shape,DistanceTravelled))
	 	  -> true
	 	  ;  assert(discontinuity(flickerDueToDistanceTravelled(FigureId,
																ElapsedTime1,
																X1,Y1,X2,Y2,
																Shape,
																ElapsedTime2))),
	 	 	 !,fail ),
		 
		 ((not flickerDueToSlowShutterDuringMovement(ElapsedTime1,ElapsedTime2))
	 	  -> true
	 	  ;  assert(discontinuity(
	 	  				flickerDueToSlowShutterDuringMovement(	FigureId,
																ElapsedTime1,
																ElapsedTime2 ))),
			 !,fail )
		)
	 ; true ). %There can be no movement-flicker if there is no movement
	 
flickerDueToDistanceTravelled(Shape,DistanceTravelled) :-
	hasApparentArea(Shape,Area),
	AreaOverDistance is Area / DistanceTravelled,
	setting(minAreaOverDistanceToAvoidFlicker(MinAreaOverDistanceToAvoidFlicker)),
	!,AreaOverDistance < MinAreaOverDistanceToAvoidFlicker.

flickerDueToSlowShutterDuringMovement(ElapsedTime1,ElapsedTime2) :-
	ElapsedTime is (ElapsedTime2 - ElapsedTime1),
	setting(maxElapsedTimeToAvoidFlicker(MaxElapsedTimeToAvoidFlicker)),
	!,ElapsedTime > MaxElapsedTimeToAvoidFlicker.
	

distanceTravelledAcrossFramesIsPerceptible(
									DesiredTruthValue,
									FigureId,
									observ1(ElapsedTime1,position(X1,Y1)),
									observ2(ElapsedTime2,position(X2,Y2)) ) :-
	euclideanDistance(X1,Y1,X2,Y2,DistanceTravelled),
	setting(minPerceptibleChangeInPosition(MinPerceptibleChangeInPosition)),
	(DesiredTruthValue
	 -> ((DistanceTravelled >= MinPerceptibleChangeInPosition)
		  -> true
			 %We assert a tip rather than a discontinuity because this change is
			 % not perceptible, so no discontinuity rule should be able to act on it.
			 %We don't assert a filteredFromPerception either, because we're now
			 % past the filter and the figure has thus been "seen". This tip is just
			 % to help in debugging if we don't see why a frame transition didn't
			 % trigger a motion trajectory rule (or why it triggered a stationary
			 % trajectory one).
		  ;  assert(tip(distanceTravelledAcrossFramesIsNotPerceptible(
														FigureId,
														observ1(ElapsedTime1,position(X1,Y1)),
														observ2(ElapsedTime2,position(X2,Y2)) ))),
			 !,fail )
	 ;  ((DistanceTravelled < MinPerceptibleChangeInPosition)
		  -> true
			 %We assert a tip rather than a discontinuity because this change is
			 % not perceptible, so no discontinuity rule should be able to act on it.
			 %We don't assert a filteredFromPerception either, because we're now
			 % past the filter and the figure has thus been "seen". This tip is just
			 % to help in debugging if we don't see why a frame transition didn't
			 % trigger a motion trajectory rule (or why it triggered a stationary
			 % trajectory one).
		  ;  assert(tip(distanceTravelledAcrossFramesIsPerceptible(
														FigureId,
														observ1(ElapsedTime1,position(X1,Y1)),
														observ2(ElapsedTime2,position(X2,Y2)) ))),
			 !,fail )
	).
			
%DOC
% Increment CFIn so it approaches 1.0 asymptotically
%  CFIn        : confidence value input ranging [0.0,1.0]
%  GrowthFactor: rate of growth toward asymptote of 1.0; seems most useful in
%                  the range [0.01,0.2] (smaller leads to faster growth).
%  CFOut       : confidence value output ranging (0.0,1.0)
%
incrementConfidenceAsymptotically(CFIn,GrowthFactor,CFOut) :-
	CFOut is 1 - GrowthFactor/(CFIn + GrowthFactor),
	condPrintf(traceParser," >>ICA: %w %w => %w\n", [CFIn,GrowthFactor,CFOut]).
	
	
	
	
/*//FIXME Define the body of this clause

isNear( obj1(Id1,position(X1,Y1),Shape1),
		obj2(Id2,position(X2,Y2),Shape2) ) :- true.
*/




invertTrajectory(	stationaryTrajectory(	OriginalPosition ),
				stationaryTrajectory(	OriginalPosition )).
invertTrajectory(	linearMovingTrajectory(LastPosition,
									magnitude(XMagn,YMagn),
									AccelList, %this won't be used so no need to invert 
									PositionList
									),
				linearMovingTrajectory(LastPosition,
									magnitude(XMagn2,YMagn2),
									AccelList,
									PositionList )) :-
	XMagn2 is -XMagn,
	YMagn2 is -YMagn.
									
extractPositionFromTrajectory(	stationaryTrajectory(
									originalPosition(X,Y) ),
							position(X,Y) ).
extractPositionFromTrajectory(	linearMovingTrajectory(
									lastPosition(X,Y),
									_Magnitude,
									_AccelList,_ ),
							position(X,Y) ).

makeNonResistiveStationaryTrajectory(	position(X,Y),
									stationaryTrajectory(originalPosition(X,Y)) ).

%Even though the linear trajectory representation has acceleration information,
%we ignore the info (treat the movement as having no acceleration) to simplify
%calculations. 
onInterceptCourse(	Obj1Shape,
					linearMovingTrajectory(
									lastPosition(X1,Y1),
									magnitude(XMagn1,YMagn1),
									_AccelerationTriplets,_ ),
					Obj2Shape,
					stationaryTrajectory(
									originalPosition(X2,Y2) )) :-
	estimateRadiusFromShapeArea(Obj1Shape,R1),
	estimateRadiusFromShapeArea(Obj2Shape,R2),
	!, %Avoid "instantiation fault in *(_6853, _6855, _7995)"
	onInterceptCourse1(	posRadiusAndVelocity(X1, Y1, R1, XMagn1,YMagn1),
						posRadiusAndVelocity(X2, Y2, R2, 0.0,0.0),
						_MsecsAtSomeIntercept ).
%Commutativity of linear/stationary
onInterceptCourse(	Obj1Shape,
					stationaryTrajectory(OriginalPosition),
					Obj2Shape,
					linearMovingTrajectory(LastPosition,Magnitude,AccelerationTriplets,PosList) ) :-
	!, %Avoid "instantiation fault in *(_6853, _6855, _7995)"
	onInterceptCourse(	Obj2Shape,
						linearMovingTrajectory(LastPosition,Magnitude,AccelerationTriplets,PosList),
						Obj1Shape,
						stationaryTrajectory(OriginalPosition) ).
%The linear/linear combo.
onInterceptCourse(	Obj1Shape,
					linearMovingTrajectory(
									lastPosition(X1,Y1),
									magnitude(XMagn1,YMagn1),
									_AccelerationTriplets1,_ ),
					Obj2Shape,
					linearMovingTrajectory(
									lastPosition(X2,Y2),
									magnitude(XMagn2,YMagn2),
									_AccelerationTriplets2,_ )) :-
	estimateRadiusFromShapeArea(Obj1Shape,R1),
	estimateRadiusFromShapeArea(Obj2Shape,R2),
	!, %Avoid "instantiation fault in *(_6853, _6855, _7995)"
	onInterceptCourse1(	posRadiusAndVelocity(X1, Y1, R1, XMagn1,YMagn1),
						posRadiusAndVelocity(X2, Y2, R2, XMagn2,YMagn2),
						_MsecsAtSomeIntercept ).
%The stationary/stationary combo. This should fail if the radii don't overlap.
onInterceptCourse(	Obj1Shape,
					stationaryTrajectory(originalPosition(X1,Y1)),
					Obj2Shape,
					stationaryTrajectory(originalPosition(X2,Y2)) ) :-
	estimateRadiusFromShapeArea(Obj1Shape,R1),
	estimateRadiusFromShapeArea(Obj2Shape,R2),
	!, %Avoid "instantiation fault in *(_6853, _6855, _7995)"
	onInterceptCourse1(	posRadiusAndVelocity(X1, Y1, R1, 0.0,0.0),
						posRadiusAndVelocity(X2, Y2, R2, 0.0,0.0),
						_MsecsAtSomeIntercept ).
				
						
%DOC
%To determine if two shapes will collide, we need to know whether their
% boundaries would overlap. But we don't believe people can predict well
% whether, say, two triangles would overlap (especially if one or both are
% rotating). A more plausible (but untested) idea is that people have a rough
% estimate of the area of a shape and imagine a circle having the same area,
% and judge whether two shapes would overlap by estimating whether such
% circle proxies would overlap. So, we provide a way here to estimate a radius
% given an area.
%
estimateRadiusFromShapeArea(circle(D),R) :-
	R is D/2.
%//TODO use major and minor diameters instead of major and minor radii
estimateRadiusFromShapeArea(oval(MajorRadius,_,MinorRadius),R) :-
	RSquared is MajorRadius * MinorRadius,
	sqrt(RSquared,R).
estimateRadiusFromShapeArea(square(SideLength,_),R) :-
	RSquared is SideLength * SideLength / 3.1416,
	sqrt(RSquared,R).
estimateRadiusFromShapeArea(rectangle(MajorSideLength,_,MinorSideLength),R) :-
	RSquared is MajorSideLength * MinorSideLength / 3.1416,
	sqrt(RSquared,R).
estimateRadiusFromShapeArea(triangle(_,_,_,_,_,_,Area),R) :-
	RSquared is Area / 3.1416,
	sqrt(RSquared,R).
estimateRadiusFromShapeArea(polygonSides(_),0.0).
estimateRadiusFromShapeArea(unrecognizedShape,0.0).
 
 
%DOC
%In the special case where the two objects are stationary, we calculate
% the distance between the 2 objects. If the distance is less than or
% equal to the sum of their radii, then they are intercepting each other. 
%Otherwise, the general contraint tested for here is, if object1 continues
% from its current position (X1,Y1) at its current speed and direction 
% (VX1,VY1), and if object2 continues from its current position at its current 
% speed and direction, pick a future time and determine the distance between 
% the objects then; if that distance is less than the sum of their radii 
% (R1 & R2), then they will have intercepted each other at that time. We 
% invert this constraint algebraicly to calculate if there is any such time 
% value. Ideally, we want to know the minimum time value, indicating when 
% the objects would first touch each other.
%This inequality has the future distance between objs on its left side:
% ((X2 + VX2*T)-(X1 + VX1*T))^2 + ((Y2 + VY2*T)-(Y1 + VY1*T))^2 <= (R1+R2)^2
%Then we expand the left side so it becomes a quadratic in terms of T:
% (VX1^2 + VX2^2 + VY1^2 + VY2^2 - 2*VX1*VX2 - 2*VY1*VY2)*T^2 +
% 2*(X1*VX1 - X1*VX2 - X2*VX1 + X2*VX2 +
%    Y1*VY1 - Y1*VY2 - Y2*VY1 + Y2*VY2)*T +
% (X1^2 + X2^2 - 2*X1*X2 +
%  Y1^2 + Y2^2 - 2*Y1*Y2) <= (R1^2 + 2*R1*R2 + R2^2)
%And then plug that into the quadratic formula to solve for T.
%Note that quadratic equations sometimes have only complex, not real, solutions,
% and sometimes there are as many as two solutions. We accept only real-valued
% solutions, and we take the smaller one (the alternative would be to
% use "+ sqrt...").
%
onInterceptCourse1( posRadiusAndVelocity(X1, Y1, R1, 0.0, 0.0),
				    posRadiusAndVelocity(X2, Y2, R2, 0.0, 0.0),
				    0 ) %when two stationary objects intercept,
				    	%it happens after 0 msecs.
	:-
	!,
	( (X2 - X1)^2 + (Y2 - Y1)^2 ) =< ( R1^2 + R2^2 ).
		
onInterceptCourse1(	posRadiusAndVelocity(X1, Y1, R1, VX1, VY1),
					posRadiusAndVelocity(X2, Y2, R2, VX2, VY2),
					MsecsAtSomeIntercept ) %Set via side-effect
	:-
	ground([X1, Y1, R1, VX1, VY1, X2, Y2, R2, VX2, VY2]),
	A is (VX1^2 + VX2^2 + VY1^2 + VY2^2 - 2*VX1*VX2 - 2*VY1*VY2),
	B is 2*(X1*VX1 - X1*VX2 - X2*VX1 + X2*VX2 + Y1*VY1 - Y1*VY2 - Y2*VY1 + Y2*VY2),
	C1 is (X1^2 + X2^2 - 2*X1*X2 + Y1^2 + Y2^2 - 2*Y1*Y2),
	C2 is (R1^2 + 2*R1*R2 + R2^2),
	C is (C1 - C2),
	Discriminant is (B^2 - 4*A*C),
	Discriminant >= 0, %Disallow any complex-number solutions
	DiscriminantSqrt is sqrt(Discriminant),
	MinDiscriminantSqrt is -DiscriminantSqrt,
	%Neg sqrt listed first so we prefer smaller values of MsecsAtSomeIntercept
	DiscriminantSqrtList = [MinDiscriminantSqrt, DiscriminantSqrt], 
	!,
	%Iterate over the 2 choices for the sqrt
	member(DiscriminantSqrtChoice, DiscriminantSqrtList), 
	MsecsAtSomeIntercept is ( (-B + DiscriminantSqrtChoice) / (2*A) ),
	MsecsAtSomeIntercept >= 0, %make sure time is positive
	!.

%DOC
%This predicate finds the intersection (Xint, Yint) between 2 lines, each of
%which is defined by 2 points. 
%The predicate handles parallel & vertical lines properly.
%Lines that are identical are considered not to have an intersection.
% 
findIntersectionOfLines(twoPoints((X1_1,Y1_1),(X2_1,Y2_1)),
						twoPoints((X1_2,Y1_2),(X2_2,Y2_2)),
						intersection(Xint,Yint) ) :-
	%Find gradients
	DeltaX2_1_X1_1 is X2_1 - X1_1,
	(DeltaX2_1_X1_1 $\= 0 ->
		M1 is (Y2_1 - Y1_1) / DeltaX2_1_X1_1
	 ;
	 	M1 = undefined %vertical line
	),
	DeltaX2_2_X1_2 is X2_2 - X1_2,
	(DeltaX2_2_X1_2 $\= 0 ->
		M2 is (Y2_2 - Y1_2) / DeltaX2_2_X1_2
	 ;
	 	M2 = undefined %vertical line
	),
	M1 \= M2, %parallel lines don't intersect
	(M1 = undefined ->
		Xint = X1_1,
		Yint is M2 * (Xint - X1_2) + Y1_2
	 ;
	 	(M2 = undefined ->
	 		Xint = X1_2,
	 		Yint is M1 * (Xint - X1_1) + Y1_1
	 	 ;
	 	 	Xint is (Y1_2 - Y1_1 - M2 * X1_2 + M1 * X1_1) / (M1-M2),
	 	 	Yint is M1 * (Xint - X1_1) + Y1_1
	 	)
	).  
	
%DOC
%This predicate finds the coordinate of the center of the circle on whose
% circumference the 3 points lie. The predicate also finds the radius of
% the circle.
% Given 3 points P1, P2, P3, the center of the circle is the intersection
% between the perpendicular bisector of the line connecting P1 to P2 and
% the perpendicular bisector of the line connecting P2 to P3.
%
circleThroughThreePoints(X1, Y1, X2, Y2, X3, Y3, Xc, Yc, Radius) :-
	%(XPerpBisec1_2_1,YPerpBisec1_2_1) is the first point on the perpendicular
	%bisector of the line connecting P1 to P2. It's simply the midpoint of
	%the line. 
	%
	XPerpBisec1_2_1 is (X1+X2)/2,
	YPerpBisec1_2_1 is (Y1+Y2)/2,
	%(XPerpBisec1_2_2,YPerpBisec1_2_2) is the second point on the perpendicular
	%bisector of the line connecting P1 to P2. It's the point (X1,Y1) rotated
	%90 degrees clockwise/counterclockwise with the midpoint as the center 
	%of rotation.
	%
	DeltaXPerpBisec1_2_1_X1 is XPerpBisec1_2_1 - X1,
	DeltaYPerpBisec1_2_1_Y1 is YPerpBisec1_2_1 - Y1,
	XPerpBisec1_2_2 is XPerpBisec1_2_1 + DeltaYPerpBisec1_2_1_Y1,
	YPerpBisec1_2_2 is YPerpBisec1_2_1 - DeltaXPerpBisec1_2_1_X1, 
		
	%Similarly, we find the 2 points lying on the perpendicular bisector of the
	%line connecting P2 to P3.
	%
	XPerpBisec2_3_1 is (X2+X3)/2,
	YPerpBisec2_3_1 is (Y2+Y3)/2,
	DeltaXPerpBisec2_3_1_X2 is XPerpBisec2_3_1 - X2,
	DeltaYPerpBisec2_3_1_Y2 is YPerpBisec2_3_1 - Y2,
	XPerpBisec2_3_2 is XPerpBisec2_3_1 + DeltaYPerpBisec2_3_1_Y2,
	YPerpBisec2_3_2 is YPerpBisec2_3_1 - DeltaXPerpBisec2_3_1_X2, 
	
	findIntersectionOfLines(twoPoints((XPerpBisec1_2_1,YPerpBisec1_2_1), 
									  (XPerpBisec1_2_2,YPerpBisec1_2_2)),
							twoPoints((XPerpBisec2_3_1,YPerpBisec2_3_1),
									  (XPerpBisec2_3_2,YPerpBisec2_3_2)),
							intersection(Xc,Yc)	),
	euclideanDistance(X1, Y1, Xc, Yc, Radius).
	
%DOC
%This predicate checks whether the angle between two vectors is close to zero
%degrees. The threshold is defined in Wayang.properties.
%
delay angleBetweenTwoVectorsIsCloseToZero(XMagn1,YMagn1,XMagn2,YMagn2)
if nonground([XMagn1,YMagn1,XMagn2,YMagn2]).
angleBetweenTwoVectorsIsCloseToZero(XMagn1,YMagn1,XMagn2,YMagn2) :-
	angleBetweenTwoVectors(XMagn1,YMagn1,XMagn2,YMagn2,0,0,Angle,_Sign),
	setting(maxAllowableErrorInDegrees(MaxAllowableErrorInDegrees)),
	Angle =< MaxAllowableErrorInDegrees.

%DOC
%This predicate finds the angle between two vectors and the sign of 
% that angle. The angle is in degrees. If the sign is 1, the angle is
% counter-clockwise. If the sign is -1, the angle is clockwise.
% The 1st vector is the vector from (X3,Y3) to (X1,Y1).
% The 2nd vector is the vector from (X3,Y3) to (X2,Y2).
% To find the angle, use the following formula:
%  Angle = arccos( (Vector1.Vector2)/|Vector1||Vector2| )
% To find the sign, use the following formula:
%  Sign = sign( arcsin( (Vector1 x Vector2)/|Vector1||Vector2| ) )		 
%
angleBetweenTwoVectors(X1,Y1,X2,Y2,X3,Y3,Angle,Sign) :-
	euclideanDistance(X1,Y1,X3,Y3,Magnitude1), %magnitude of vector1
	euclideanDistance(X2,Y2,X3,Y3,Magnitude2), %magnitude of vector2
	%neither of the two vectors should have a magnitude of 0
	Magnitude1 \= 0.0,
	Magnitude2 \= 0.0,
	dotProduct(X1,Y1,X2,Y2,X3,Y3,DotProductResult),
	Cosine is DotProductResult / (Magnitude1 * Magnitude2),
	%handle rounding off problems, e.g 1.00001 & -1.0001
	(Cosine > 1.0 ->
	 acos(1.0,Angle1)
	;
	 (Cosine < -1.0 ->
	  acos(-1.0,Angle1)
	 ;	
	  acos(Cosine,Angle1)
	 )
	),  
	Angle is Angle1 / pi * 180, % convert from rad to degrees
	crossProduct(X1,Y1,X2,Y2,X3,Y3,CrossProductResult),
	Sine is CrossProductResult / (Magnitude1 * Magnitude2),
	%handle rounding off problems, e.g 1.00001 & -1.0001
	(Sine > 1.0 ->
	 asin(1.0,AngleWithSign)
	;
	 (Sine < -1.0 ->
	  asin(-1.0,AngleWithSign)
	 ;	
	  asin(Sine,AngleWithSign)
	 )
	),  
	sgn(AngleWithSign,Sign).

%DOC
%This predicate finds the dot product of two vectors.
% The 1st vector is the vector from (X3,Y3) to (X1,Y1).
% The 2nd vector is the vector from (X3,Y3) to (X2,Y2).
% Use the following formula:
%  DotProductResult = (X1-X3)*(X2-X3)+(Y1-Y3)*(Y2-Y3).
%
dotProduct(X1,Y1,X2,Y2,X3,Y3,DotProductResult) :-
	DotProductResult is (X1-X3)*(X2-X3)+(Y1-Y3)*(Y2-Y3).

%DOC
%This predicate finds the cross product of two vectors.
% The 1st vector is the vector from (X3,Y3) to (X1,Y1).
% The 2nd vector is the vector from (X3,Y3) to (X2,Y2).
% Use the following formula:
%  CrossProductResult = (X1-X3)*(Y2-Y3)-(X2-X3)*(Y1-Y3).
%
crossProduct(X1,Y1,X2,Y2,X3,Y3,CrossProductResult) :-
	CrossProductResult is (X1-X3)*(Y2-Y3)-(X2-X3)*(Y1-Y3).

%DOC
%Given three points we check whether the points lie on
%a straight line, and are ordered along that line.
%
delay collinearOrdered( (X1,Y1),(X2,Y2),(X3,Y3) )
	if nonground([X1,Y1,X2,Y2,X3,Y3]).
collinearOrdered( (X1,Y1),(X1,Y1),(_X2,_Y2) ) :- !.
collinearOrdered( (X1,Y1),(X2,Y2),(X3,Y3) ) :-
	
	%Compare vector P1P2 with vector P1P3.
	
	%Check that P1 \= P3.
	(X1 $\= X3,! ; Y1 $\= Y3),
	%Check that P1 \= P2.
	(X1 $\= X2,! ; Y1 $\= Y2),
	
	%Angle should be sufficiently small within a predefined
	%margin of error.
	angleBetweenTwoVectors(X2,Y2,X3,Y3,X1,Y1,Angle,_Sign),
	setting(maxAllowableErrorInDegrees(MaxAllowableErrorInDegrees)),
	Angle $=< MaxAllowableErrorInDegrees,
	
	%Constrain |P1P3| >= |P1P2| to maintain order.
	%If the constraint above doesn't hold, check whether or not
	%distance between P2 & P3 is perceptible. 
	%This is to be consistent with the allowable error
	%for stationary trajectory. 
	euclideanDistance(X1,Y1,X2,Y2,DistanceP1P2),
	euclideanDistance(X1,Y1,X3,Y3,DistanceP1P3),
	DistanceDelta is DistanceP1P3 - DistanceP1P2,
	(DistanceDelta $>= 0,! 
	 ; 
	 euclideanDistance(X2,Y2,X3,Y3,DistanceP2P3),
	 setting(minPerceptibleChangeInPosition(MinPerceptibleChangeInPosition)),
	 DistanceP2P3 $< MinPerceptibleChangeInPosition
	).
	
	/*
	%The commented out section is an alternative solution that
	%has flaws/limitations.
	
	%Treat the points as the ends of vectors that begin at
	%the point of origin.
	%Compare the sign of the angle between the
	%first vector & second vector with the sign of the angle
	%between second & third vector. The signs should be the same
	%unless one or both of them is zero, which means one or
	%both pairs of points are the same.
	%If the signs differ, the order is not preserved.
	%
	
	angleBetweenTwoVectors(X1,Y1,X2,Y2,0,0,_Angle1,Sign1),
	anglebetweenTwoVectors(X2,Y2,X3,Y3,0,0,_Angle2,Sign2),
	SignProduct is Sign1 * Sign2,
	SignProduct $>= 0,
	
	%The gradient of the line connecting the first point to
	%the second point should be close in value to the gradient
	%of the line connecting the second point to the third point
	%(within a predetermined margin of error)
	%
	XDiff21 is X2-X1,
	XDiff32 is X3-X2,
	
	Gradient1 is (Y2-Y1) / (X2-X1),
	Gradient2 is (Y3-Y2) / (X3-X2),
	%For gradient we use the same error range for speed.
	%This might change.
	magnitudesAreWithinErrorRange(Gradient1,Gradient2).
	*/ 
	
%DOC
%Given mu and sigma parameters, as well as the independent variable
%X, calculate Y, the result of applying the bell curve function to
%X. The result is scaled such that the mean (the peak of the curve)
%gives a value of 1.
delay bellCurve(mu(Mu),sigma(Sigma),X,Y)
	if nonground([Mu,Sigma,X]).
bellCurve(mu(Mu),sigma(Sigma),X,Y) :-
	ScaleFactor is 1 / (2 * pi * Sigma ^ 2) ^ 0.5,
	Y1 is 1 / (2 * pi * Sigma ^ 2) ^ 0.5 * e ^ 
		(-1 * (X - Mu) ^ 2 / (2 * Sigma ^ 2)),
	Y is 1 / ScaleFactor * Y1.
	
%DOC
%The predicate checks whether, given three points and a fourth point,
%the fourth point lies within the boundary formed by the circle on whose
%circumference the first three points lie.
%This predicate is used to check whether, given three points which are
%part of a curved trajectory, the fourth point lies below the trajectory.
%The fourth point lying within the boundary formed by the circle is analogous
%to the fourth point lying below the trajectory.
%There are two scenarios where the check will fail:
%1)The first three points do not form a circle/curved trajectory, in which
%  case the call to circleThroughThreePoints/9 fails.
%2)The fourth point lies outside the circle.
%This check is useful, for example, when evaluating the fourth point as the
%position of a potential repulsor in the combined forces scenario.
%This predicate is no longer used to check the position of repulsors/threat objects.
%It has been replaced by positionLiesWithinCircle/4
%The predicate is not currently used.
%
fourthPointLiesWithinCircleFormedFromFirstThreePoints(
		(X1,Y1),(X2,Y2),(X3,Y3),(X4,Y4) ) :-
	circleThroughThreePoints(X1, Y1, X2, Y2, X3, Y3, Xc, Yc, R),
	%the following test checks whether (X4,Y4) satisfies the test below:
	%(X-Xc)^2 + (Y-Yc)^2 < R^2   
	(X4-Xc)^2 + (Y4-Yc)^2 $< R^2.
	
%DOC
%The predicate checks whether the position lies within the circle.
%  
positionLiesWithinCircle((X1,Y1),Xc,Yc,Rc) :-
	(X1-Xc)^2 + (Y1-Yc)^2 < Rc^2. 
 
%DOC
%The predicate indicates whether (X3,Y3) lies on one side of the line or
%the other side. There are 2 possible values: 'greater' and 'less', which
%correspond to the value of the inequation when (X3,Y3) is plugged into the
%line equation. The context in which this predicate is used precludes the
%possibility that (X3,Y3) lies on the line.
%
pointLiesOnWhichSideOfTheLine(twoPointsOfTheLine((X1,Y1),(X2,Y2)),
		(X3,Y3),Side) :-
	DeltaX is X2 - X1,
	DeltaY is Y2 - Y1,
	(DeltaX $\= 0 ->
		(DeltaY $\= 0 ->
			%normal line (non-horizontal, non-vertical)
			(Y3 - Y1 $> DeltaY / DeltaX * (X3 - X1) ->
				Side = greater
			 ;
				Side = less
			) 
		 ;
		 	%horizontal line
		 	(Y3 $> Y1 ->
		 		Side = greater
		 	 ;
		 	 	Side = less
		 	)
		)
	 ;
	 	%vertical line
	 	(X3 $> X1 ->
	 		Side = greater
	 	 ;
	 	 	Side = less
	 	)
	).
	
%DOC
%The predicate indicates whether (X3,Y3) lies on the correct side of the
%line, based on the value assigned to Side. There are 2 possible 
%assigned values: 'greater' and 'less'. The assigned value needs to
%correspond to the value of the inequation when (X3,Y3) is plugged into the
%line equation. The context in which this predicate is used precludes the
%possibility that (X3,Y3) lies on the line.
%
pointLiesOnCorrectSideOfTheLine(twoPointsOfTheLine((X1,Y1),(X2,Y2)),
		(X3,Y3),Side) :-
	DeltaX is X2 - X1,
	DeltaY is Y2 - Y1,
	(DeltaX $\= 0 ->
		(DeltaY $\= 0 ->
			%normal line (non-horizontal, non-vertical)
			(Side = greater ->
				Y3 - Y1 $> DeltaY / DeltaX * (X3 - X1)
			 ;
				Y3 - Y1 $< DeltaY / DeltaX * (X3 - X1)
			) 
		 ;
		 	%horizontal line
		 	(Side = greater ->
		 		Y3 $> Y1
		 	 ;
		 	 	Y3 $< Y1
		 	)
		)
	 ;
	 	%vertical line
	 	(Side = greater ->	
	 		X3 $> X1
	 	 ;
	 	 	X3 $< X1
	 	)
	).

%DOC
% Find line of best fit using linear regression. The algorithm is based on
%  http://mathworld.wolfram.com/LeastSquaresFitting.html
% The predicate takes a list of (X,Y) coordinates of the positions for which
% the line of best fit is calculated, and outputs parameters of the line of best 
% fit: M, C, where the line equation is Y = MX + C. The predicate also outputs
% the value of the sum of squares of vertical deviations, RSquared, which is our error
% measure. These vertical deviations are deviations between actual Y coordinates and 
% predicted Y coordinates calculated using the line equation. 
% The value of RSquared is useful as a measure of the accuracy of the line of best
% fit.
%
delay findLineOfBestFit(PositionList,M,C,RSquared)
	if nonground(PositionList).
findLineOfBestFit(PositionList, %input
				  M,C,RSquared  %output
				 ) :-
	%Separate X and Y coordinates into two lists
	(foreach(Position,PositionList),foreach(XPosition,XPositionList),foreach(YPosition,YPositionList) do
		Position = (XPosition,YPosition)
	),
	
	%Calculate various values that are needed in the calculations of M and C
	%Total number of positions
	length(PositionList,N),
	%Sum of X coordinates
	(foreach(XPosition,XPositionList),fromto(0,In,Out,XSum) do
		Out is In + XPosition
	),
	%Sum of Y coordinates
	(foreach(YPosition,YPositionList),fromto(0,In,Out,YSum) do
		Out is In + YPosition
	),
	%Sum of squares of X coordinates
	(foreach(XPosition,XPositionList),fromto(0,In,Out,XSquaredSum) do
		Out is In + XPosition ^ 2
	),
	%Dot product of XPositionList and YPositionList
	(foreach(XPosition,XPositionList),foreach(YPosition,YPositionList),fromto(0,In,Out,XYDotProduct) do
		Out is In + XPosition * YPosition
	),
	%Mean of X coordinates
	XMean is XSum / N,
	%Mean of Y coordinates
	YMean is YSum / N,
	
	%calculate C. For the formula, see eq. 13 in http://mathworld.wolfram.com/LeastSquaresFitting.html
	C is (YMean * XSquaredSum - XMean * XYDotProduct) / (XSquaredSum - N * XMean ^ 2),
	
	%calculate M. For the formula, see eq. 15 in http://mathworld.wolfram.com/LeastSquaresFitting.html
	M is (XYDotProduct - N * XMean * YMean) / (XSquaredSum - N * XMean ^ 2),
	
	%calculate RSquared. For the formula, see eq. 1 in http://mathworld.wolfram.com/LeastSquaresFitting.html
	(foreach(XPosition,XPositionList),foreach(YPosition,YPositionList),fromto(0,In,Out,RSquared),param(M,C) do
		PredictedYPosition is M * XPosition + C,
		Deviation is YPosition - PredictedYPosition,
		Out is In + Deviation ^ 2
	).

%DOC
% Find circle of best fit using circular regression. The algorithm is based on 
% LeastSquaresCircle.pdf which can be found in DropBox 
% (CSC shared\Intention Perception\AnalysesOfAnimations).
% The predicate takes a list of (X,Y) coordinates of the positions for which
% the circle of best fit is calculated, and outputs parameters of the circle of
% best fit: Xc, Yc, and Rc, where the circle of best fit is centered at (Xc,Yc)
% with a radius of Rc.
% Let a circle be represented as
%   X^2 + Y^2 + 2AX + 2BY + C = 0, 
% then the center of the circle is (-A,-B) and the radius R = sqrt(A^2+B^2-C).
% The predicate also outputs an error measure, ErrorMeasure, which is calculated
% in a formula similar to the circle representation. The error formula is:
%   ErrorMeasure = sum(i=1..n)(Xi^2 + Yi^2 + 2AXi + 2BYi + C)^2   
% The more error there is, the bigger the value of this error measure is.
%
delay findCircleOfBestFit(PositionList,Xc,Yc,Rc,ErrorMeasure)
	if nonground(PositionList).
findCircleOfBestFit(PositionList, 			%Input
					Xc,Yc,Rc,ErrorMeasure	%Output
				   ) :-
	%Calculate various values that are needed in subsequent calculations
	%Total number of positions
	length(PositionList,N),
	%Sum of X coordinates
	(foreach((XPosition,_),PositionList),fromto(0,In,Out,XSum) do
		Out is In + XPosition
	),
	%Sum of Y coordinates
	(foreach((_,YPosition),PositionList),fromto(0,In,Out,YSum) do
		Out is In + YPosition
	),
	%Sum of squares of X coordinates
	(foreach((XPosition,_),PositionList),fromto(0,In,Out,XSquaredSum) do
		Out is In + XPosition ^ 2
	),
	%Sum of squares of Y coordinates
	(foreach((_,YPosition),PositionList),fromto(0,In,Out,YSquaredSum) do
		Out is In + YPosition ^ 2
	),
	%Dot product of X and Y coordinates
	(foreach((XPosition,YPosition),PositionList),fromto(0,In,Out,XYDotProduct) do
		Out is In + XPosition * YPosition
	),
	%Sums of the following three addends/terms: (Xi^2+Yi^2), (Xi^2+Yi^2)*Xi, (Xi^2+Yi^2)*Yi
	(foreach((XPosition,YPosition),PositionList),fromto(0,In1,Out1,XSquaredPlusYSquaredSum), 
	 fromto(0,In2,Out2,XCubedPlusYSquaredTimesXSum),fromto(0,In3,Out3,XSquaredTimesYPlusYCubedSum) do
		XSquaredPlusYSquared is XPosition ^ 2 + YPosition ^ 2,
		Out1 is In1 + XSquaredPlusYSquared,
		Out2 is In2 + XSquaredPlusYSquared * XPosition,
		Out3 is In3 + XSquaredPlusYSquared * YPosition
	),
	%Given a circle representation of X^2 + Y^2 + 2AX + 2BY + C = 0, we need to solve a system
	%of three equations with three variables: A, B & C. The three equations are as detailed in
	%LeastSquaresCircle.pdf, in section 1, Approximation without constraints.
	%We assign the coefficients and constants in the equations.
	CoefficientOfAInEquation1 is 2 * XSquaredSum,
	FloatCoefficientOfAInEquation1 is float(CoefficientOfAInEquation1),
	CoefficientOfBInEquation1 is 2 * XYDotProduct,
	FloatCoefficientOfBInEquation1 is float(CoefficientOfBInEquation1),
	CoefficientOfCInEquation1 is XSum,
	FloatCoefficientOfCInEquation1 is float(CoefficientOfCInEquation1),
	ConstantInEquation1 is XCubedPlusYSquaredTimesXSum,
	FloatConstantInEquation1 is float(ConstantInEquation1),
	CoefficientOfAInEquation2 is 2 * XYDotProduct,
	FloatCoefficientOfAInEquation2 is float(CoefficientOfAInEquation2),
	CoefficientOfBInEquation2 is 2 * YSquaredSum,
	FloatCoefficientOfBInEquation2 is float(CoefficientOfBInEquation2),
	CoefficientOfCInEquation2 is YSum,
	FloatCoefficientOfCInEquation2 is float(CoefficientOfCInEquation2),
	ConstantInEquation2 is XSquaredTimesYPlusYCubedSum,
	FloatConstantInEquation2 is float(ConstantInEquation2),
	CoefficientOfAInEquation3 is 2 * XSum,
	FloatCoefficientOfAInEquation3 is float(CoefficientOfAInEquation3),
	CoefficientOfBInEquation3 is 2 * YSum,
	FloatCoefficientOfBInEquation3 is float(CoefficientOfBInEquation3),
	CoefficientOfCInEquation3 is N,
	FloatCoefficientOfCInEquation3 is float(CoefficientOfCInEquation3),
	ConstantInEquation3 is XSquaredPlusYSquaredSum,
	FloatConstantInEquation3 is float(ConstantInEquation3),
	%Solve for A,B,C
	solveSystemOfThreeEquationsWithThreeVariables(
		 (FloatCoefficientOfAInEquation1,FloatCoefficientOfBInEquation1,FloatCoefficientOfCInEquation1,FloatConstantInEquation1),
		 (FloatCoefficientOfAInEquation2,FloatCoefficientOfBInEquation2,FloatCoefficientOfCInEquation2,FloatConstantInEquation2),
		 (FloatCoefficientOfAInEquation3,FloatCoefficientOfBInEquation3,FloatCoefficientOfCInEquation3,FloatConstantInEquation3),
		 A,B,C
		),
	%Calculate Xc,Yc & Rc
	Xc is -A,
	Yc is -B,
	Rc is sqrt(A^2+B^2-C),
	%Calculate ErrorMeasure
	(foreach((XPosition,YPosition),PositionList),fromto(0,In,Out,ErrorMeasure),param(A,B,C) do
		Out is In + (XPosition^2 + YPosition^2 + 2 * A * XPosition + 2 * B * YPosition + C) ^ 2
	).

%DOC
%The predicate solves a system of three equations with three variables.
%The equations are of the form:
%  CoefficientOfA * A + CoefficientOfB * B + CoefficientOfC * C + Constant = 0
%Note the limitation that the predicate might not work properly if CoefficientOfAInEquation1 is equal to 0.0.
%The current caller of this predicate, findCircleOfBestFit/5, is unlikely to pass a value of 0.0 for this variable.
% 
solveSystemOfThreeEquationsWithThreeVariables(
		 (CoefficientOfAInEquation1,CoefficientOfBInEquation1,CoefficientOfCInEquation1,ConstantInEquation1),	%Inputs
	 	 (CoefficientOfAInEquation2,CoefficientOfBInEquation2,CoefficientOfCInEquation2,ConstantInEquation2),
	 	 (CoefficientOfAInEquation3,CoefficientOfBInEquation3,CoefficientOfCInEquation3,ConstantInEquation3),
	 	 A,B,C																									%Outputs
		) :-
	%Combine equation 1 with equation 2 to give equation 4 in which A is eliminated
	combineTwoEquationsWithThreeVariablesToGiveNewEquationWithTwoVariables(
		 (CoefficientOfAInEquation1,CoefficientOfBInEquation1,CoefficientOfCInEquation1,ConstantInEquation1),
	 	 (CoefficientOfAInEquation2,CoefficientOfBInEquation2,CoefficientOfCInEquation2,ConstantInEquation2),
	 	 (CoefficientOfBInEquation4,CoefficientOfCInEquation4,ConstantInEquation4)
	 	),
	%Combine equation 1 with equation 3 to give equation 5 in which A is eliminated
	combineTwoEquationsWithThreeVariablesToGiveNewEquationWithTwoVariables(
		 (CoefficientOfAInEquation1,CoefficientOfBInEquation1,CoefficientOfCInEquation1,ConstantInEquation1),
	 	 (CoefficientOfAInEquation3,CoefficientOfBInEquation3,CoefficientOfCInEquation3,ConstantInEquation3),
	 	 (CoefficientOfBInEquation5,CoefficientOfCInEquation5,ConstantInEquation5)
	 	),
	%Solve for B & C by combining equation 4 and equation 5
	solveSystemOfTwoEquationsWithTwoVariables(
		 (CoefficientOfBInEquation4,CoefficientOfCInEquation4,ConstantInEquation4),
		 (CoefficientOfBInEquation5,CoefficientOfCInEquation5,ConstantInEquation5),
		 B,C
		),
	%Solve for A by replacing B & C in equation 1 with the solutions found for B & C
	A is (- ConstantInEquation1 - CoefficientOfBInEquation1 * B - CoefficientOfCInEquation1 * C) / CoefficientOfAInEquation1.
	 	
%DOC
%The predicate combines two equations with three variables to give a new equation with one of the variables
%eliminated. 
%
combineTwoEquationsWithThreeVariablesToGiveNewEquationWithTwoVariables(
		 (CoefficientOfAInEquation1,CoefficientOfBInEquation1,CoefficientOfCInEquation1,ConstantInEquation1), %Inputs
		 (CoefficientOfAInEquation2,CoefficientOfBInEquation2,CoefficientOfCInEquation2,ConstantInEquation2),
		 (CoefficientOfBInNewEquation,CoefficientOfCInNewEquation,ConstantInNewEquation)					  %Output
		) :-
	%Combine equation 1 with equation 2 to give a new equation in which A is eliminated
	CoefficientOfBInNewEquation1 is CoefficientOfBInEquation1 * CoefficientOfAInEquation2 
	 					- CoefficientOfBInEquation2 * CoefficientOfAInEquation1,
	CoefficientOfCInNewEquation1 is CoefficientOfCInEquation1 * CoefficientOfAInEquation2
	 					- CoefficientOfCInEquation2 * CoefficientOfAInEquation1,
	ConstantInNewEquation1 is ConstantInEquation1 * CoefficientOfAInEquation2
	 					- ConstantInEquation2 * CoefficientOfAInEquation1,
	(CoefficientOfBInNewEquation1 = -0.0 ->
		CoefficientOfBInNewEquation = 0.0
	;
		CoefficientOfBInNewEquation = CoefficientOfBInNewEquation1
	),
	(CoefficientOfCInNewEquation1 = -0.0 ->
		CoefficientOfCInNewEquation = 0.0
	;
		CoefficientOfCInNewEquation = CoefficientOfCInNewEquation1
	),
	(ConstantInNewEquation1 = -0.0 ->
		ConstantInNewEquation = 0.0
	;
		ConstantInNewEquation = ConstantInNewEquation1
	).
	
%DOC
%The predicate solves a system of two equations with two variables.
%The equations are of the form:
%  CoefficientOfA * A + CoefficientOfB * B + Constant = 0
%
solveSystemOfTwoEquationsWithTwoVariables(
		 (0.0,0.0,_ConstantInEquation1), 											   %Inputs
		 (_CoefficientOfAInEquation2,_CoefficientOfBInEquation2,_ConstantInEquation2),
		 _A,_B																		   %Outputs
		) :-
	!,
	fail.
solveSystemOfTwoEquationsWithTwoVariables(
		 (_CoefficientOfAInEquation1,_CoefficientOfBInEquation1,_ConstantInEquation1), %Inputs
		 (0.0,0.0,_ConstantInEquation2),
		 _A,_B																		   %Outputs
		) :-
	!,
	fail.
solveSystemOfTwoEquationsWithTwoVariables(
		 (_CoefficientOfAInEquation1,0.0,_ConstantInEquation1), %Inputs
		 (_CoefficientOfAInEquation2,0.0,_ConstantInEquation2),
		 _A,_B												    %Outputs
		) :-
	!,
	fail.
solveSystemOfTwoEquationsWithTwoVariables(
		 (0.0,_CoefficientOfBInEquation1,_ConstantInEquation1), %Inputs
		 (0.0,_CoefficientOfBInEquation2,_ConstantInEquation2),
		 _A,_B												    %Outputs
		) :-
	!,
	fail.
solveSystemOfTwoEquationsWithTwoVariables(
		 (CoefficientOfAInEquation1,0.0,ConstantInEquation1), %Inputs
		 (0.0,CoefficientOfBInEquation2,ConstantInEquation2),
		 A,B												  %Outputs
		) :-
	A is -ConstantInEquation1 / CoefficientOfAInEquation1,
	B is -ConstantInEquation2 / CoefficientOfBInEquation2,
	!.
solveSystemOfTwoEquationsWithTwoVariables(
		 (0.0,CoefficientOfBInEquation1,ConstantInEquation1), %Inputs
		 (CoefficientOfAInEquation2,0.0,ConstantInEquation2),
		 A,B												  %Outputs
		) :-
	A is -ConstantInEquation2 / CoefficientOfAInEquation2,
	B is -ConstantInEquation1 / CoefficientOfBInEquation1,
	!.
solveSystemOfTwoEquationsWithTwoVariables(
		 (CoefficientOfAInEquation1,0.0,ConstantInEquation1), 					    %Inputs
		 (CoefficientOfAInEquation2,CoefficientOfBInEquation2,ConstantInEquation2),
		 A,B																		%Outputs
		) :-
	A is -ConstantInEquation1 / CoefficientOfAInEquation1,
	B is (-ConstantInEquation2 - CoefficientOfAInEquation2 * A) / CoefficientOfBInEquation2,
	!.
solveSystemOfTwoEquationsWithTwoVariables(
		 (0.0,CoefficientOfBInEquation1,ConstantInEquation1), 					    %Inputs
		 (CoefficientOfAInEquation2,CoefficientOfBInEquation2,ConstantInEquation2),
		 A,B																		%Outputs
		) :-
	B is -ConstantInEquation1 / CoefficientOfBInEquation1,
	A is (-ConstantInEquation2 - CoefficientOfBInEquation2 * B) / CoefficientOfAInEquation2,
	!.
solveSystemOfTwoEquationsWithTwoVariables(
		 (CoefficientOfAInEquation1,CoefficientOfBInEquation1,ConstantInEquation1), %Inputs
		 (CoefficientOfAInEquation2,0.0,ConstantInEquation2),
		 A,B																		%Outputs
		) :-
	A is -ConstantInEquation2 / CoefficientOfAInEquation2,
	B is (-ConstantInEquation1 - CoefficientOfAInEquation1 * A) / CoefficientOfBInEquation1,
	!.
solveSystemOfTwoEquationsWithTwoVariables(
		 (CoefficientOfAInEquation1,CoefficientOfBInEquation1,ConstantInEquation1), %Inputs
		 (0.0,CoefficientOfBInEquation2,ConstantInEquation2),
		 A,B																		%Outputs
		) :-
	B is -ConstantInEquation2 / CoefficientOfBInEquation2,
	A is (-ConstantInEquation1 - CoefficientOfBInEquation1 * B) / CoefficientOfAInEquation1,
	!.
solveSystemOfTwoEquationsWithTwoVariables(
		 (CoefficientOfAInEquation1,CoefficientOfBInEquation1,ConstantInEquation1), %Inputs
	 	 (CoefficientOfAInEquation2,CoefficientOfBInEquation2,ConstantInEquation2),
	 	 A,B																		%Outputs
		) :-
	%Check that the two equations do not correspond to parallel lines, which have no
	%intersection
	CoefficientRatio1 is CoefficientOfAInEquation1 / CoefficientOfBInEquation1,
	CoefficientRatio2 is CoefficientOfAInEquation2 / CoefficientOfBInEquation2,
	CoefficientRatio1 \= CoefficientRatio2,
	
	%Combine equation 1 with equation 2 to solve for A
	CoefficientOfAInNewEquation is CoefficientOfBInEquation2 * CoefficientOfAInEquation1
						- CoefficientOfBInEquation1 * CoefficientOfAInEquation2,
	ConstantInNewEquation is CoefficientOfBInEquation2 * ConstantInEquation1
						- CoefficientOfBInEquation1 * ConstantInEquation2,
	A is -ConstantInNewEquation / CoefficientOfAInNewEquation,
	%Solve for B by replacing A in equation 1 with the solution found for A
	B is (-ConstantInEquation1 - CoefficientOfAInEquation1 * A) / CoefficientOfBInEquation1.
	
%DOC
%The various predicates are used to calculate errors relative to a circle(calculateErrorMeasure, calculateErrorMeasure2,
%calculateErrorMeasure3 & calculateErrorMeasure4) or a line(calculateErrorMeasure5), according to the various error functions.
%These predicates can be used to test various circles/lines and will be useful mainly for debugging.
%calculateErrorMeasure4 & calculateErrorMeasure5 are also useful for generating error measures that are more easily comparable,
%since in both of them the error measure is the sum of the actual errors, instead of what we have in findCircleOfBestFit, 
%findLineOfBestFit, calculateErrorMeasure, calculateErrorMeasure2 and calculateErrorMeasure3.
%
calculateErrorMeasure(PositionList,Xc,Yc,Rc,ErrorMeasure) :-
	A is -Xc,
	B is -Yc,
	C is A^2 + B^2 - Rc^2,
	%Calculate ErrorMeasure
	(foreach((XPosition,YPosition),PositionList),fromto(0,In,Out,ErrorMeasure),param(A,B,C) do
		Out is In + (XPosition^2 + YPosition^2 + 2 * A * XPosition + 2 * B * YPosition + C) ^ 2
	).

calculateErrorMeasure2(PositionList,Xc,Yc,Rc,ErrorMeasure) :-
	A is -Xc,
	B is -Yc,
	%Calculate ErrorMeasure
	(foreach((XPosition,YPosition),PositionList),fromto(0,In,Out,ErrorMeasure), param(A,B,Rc) do
		Out is In + ((XPosition+A)^2 + (YPosition+B)^2 - Rc^2) ^ 2	
	).

calculateErrorMeasure3(PositionList,Xc,Yc,Rc,ErrorMeasure) :-
	A is -Xc,
	B is -Yc,
	%Calculate ErrorMeasure
	(foreach((XPosition,YPosition),PositionList),fromto(0,In,Out,ErrorMeasure), param(A,B,Rc) do
		Out is In + (sqrt((XPosition+A)^2 + (YPosition+B)^2) - Rc) ^ 2	
	).
	
delay calculateErrorMeasure4(PositionList,Xc,Yc,Rc,ErrorMeasure)
		if nonground([PositionList,Xc,Yc,Rc]).
calculateErrorMeasure4(PositionList,Xc,Yc,Rc,ErrorMeasure) :-
	A is -Xc,
	B is -Yc,
	%Calculate ErrorMeasure
	(foreach((XPosition,YPosition),PositionList),fromto(0,In,Out,ErrorMeasure), param(A,B,Rc) do
		IndividualPerpendicularError is sqrt((XPosition+A)^2 + (YPosition+B)^2) - Rc,
		AbsIndividualPerpendicularError is abs(IndividualPerpendicularError),
		Out is In + AbsIndividualPerpendicularError
	).

delay calculateErrorMeasure5(PositionList,M,C,ErrorMeasure)
		if nonground([PositionList,M,C]).
calculateErrorMeasure5(PositionList,M,C,ErrorMeasure) :-
	%calculate ErrorMeasure
	(foreach((XPosition,YPosition),PositionList),fromto(0,In,Out,ErrorMeasure),param(M,C) do
		PredictedYPosition is M * XPosition + C,
		IndividualVerticalError is YPosition - PredictedYPosition,
		AbsIndividualVerticalError is abs(IndividualVerticalError),
		%To find the (absolute) perpendicular error, use the following formula:
		%absolute perpendicular error = absolute vertical error / sqrt(1 + M^2)
		AbsIndividualPerpendicularError is AbsIndividualVerticalError / sqrt(1 + M^2), 
		Out is In + AbsIndividualPerpendicularError
	).
				
%DOC
%Given a list of positions, find a trajectory of best fit based on either a line of best fit or
%a circle of best fit. If none of them gives a sufficiently accurate fit, the trajectory of best
%fit will be undefined. Other than the list of positions that will be fitted to, the predicate also
%takes as inputs the latest magnitude pair, elapsed times of the 2 latest positions, and a list of
%acceleration triplets related to the list of positions. These inputs will be used in the construction
%of the trajectory of best fit.
%
delay findTrajectoryOfBestFit(PositionList,(LatestXMagn,LatestYMagn),SecondToLastElapsedTime,
							  LastElapsedTime,AccelTriplets,TrajectoryOfBestFit)
	if nonground([PositionList,LatestXMagn,LatestYMagn,
				  SecondToLastElapsedTime,LastElapsedTime,AccelTriplets]).
findTrajectoryOfBestFit(PositionList,(LatestXMagn,LatestYMagn),					%Inputs
						SecondToLastElapsedTime,LastElapsedTime,AccelTriplets, 
						TrajectoryOfBestFit									    %Output
					   ) :-
	PositionList = [(FirstXPosition,FirstYPosition)|_],
	append(_,[(LastXPosition,LastYPosition)],PositionList),
	length(PositionList,NumberOfPositions),
	LatestSpeedSquared is LatestXMagn ^ 2 + LatestYMagn ^ 2,
	LatestSpeed is sqrt(LatestSpeedSquared),
	%Use PositionList to calculate line/circle of best fit 
	(
	 %If the line of best fit is sufficiently accurate (i.e. error is smaller than a predetermined limit)
	 %use the line of best fit. Note that for comparison we use an error measure calculated using calculateErrorMeasure5/4,
	 %since this gives an error measure that is the sum of the actual perpendicular errors, which is easier to compare.
	 (findLineOfBestFit(PositionList,M,C,_RSquared),
	  calculateErrorMeasure5(PositionList,M,C,ErrorMeasure),
	  setting(maxAllowableErrorForLineOfBestFitPerPositionOnAverage(MaxAllowableErrorForLineOfBestFitPerPositionOnAverage)),
	  %Multiply the number of positions by the max allowable error, since the error limit is per position (on average)
	  MaxAllowableErrorForLineOfBestFit is NumberOfPositions * MaxAllowableErrorForLineOfBestFitPerPositionOnAverage,
	  ErrorMeasure =< MaxAllowableErrorForLineOfBestFit,
	  %Construct a trajectory of best fit in the form of a linear trajectory
	  %Project the latest magnitude (LatestXMagn,LatestYMagn) to the direction of the line of best fit to give the magnitude
	  %of the linear trajectory of best fit
	  %M is the tangent of the trajectory of best fit, so we find the angle and then the projected X and Y magnitudes
	  AngleOfLineOfBestFit is atan(M),
	  ProjectedXMagn is LatestSpeed * cos(AngleOfLineOfBestFit),
	  ProjectedYMagn is LatestSpeed * sin(AngleOfLineOfBestFit),
	  %The projected magnitudes might be pointing the wrong (opposite) way. To find out the correct signs for the
	  %projected X and Y magnitudes, project a new position that would result from a linear trajectory with the given
	  %projected magnitudes running for a unit time (1 ms), starting at the first position. If the distance between the projected position
	  %and the last position is smaller than the distance between the first position and the last position, the signs are correct. Otherwise,
	  %invert the signs.
	  ProjectedSecondXPosition is FirstXPosition + ProjectedXMagn,
	  ProjectedSecondYPosition is FirstYPosition + ProjectedYMagn,
	  euclideanDistance(ProjectedSecondXPosition,ProjectedSecondYPosition,LastXPosition,LastYPosition,DistanceProjectedSecondAndLast),
	  euclideanDistance(FirstXPosition,FirstYPosition,LastXPosition,LastYPosition,DistanceFirstAndLast),
	  (DistanceProjectedSecondAndLast < DistanceFirstAndLast ->
	  	ProjectedXMagnWithCorrectSign = ProjectedXMagn,
	  	ProjectedYMagnWithCorrectSign = ProjectedYMagn
	  ;
	  	ProjectedXMagnWithCorrectSign is -ProjectedXMagn,
	  	ProjectedYMagnWithCorrectSign is -ProjectedYMagn
	  ),
	  TrajectoryOfBestFit = linearMovingTrajectory(	lastPosition(LastXPosition,LastYPosition),
													magnitude(ProjectedXMagnWithCorrectSign,ProjectedYMagnWithCorrectSign),
													acceleration(AccelTriplets),
													[(LastXPosition,LastYPosition)]),
	  !
	 )
	;
	 %Otherwise try to fit to a circle, and if the circle of best fit is sufficiently accurate (i.e. error is smaller than
	 %a predetermined limit) use the circle of best fit. Note that for comparison we use an error measure calculated using 
	 %calculateErrorMeasure4/5, since this gives an error measure that is the sum of the actual perpendicular errors, 
	 %which is easier to compare.
	 (findCircleOfBestFit(PositionList,Xc,Yc,Rc,_ErrorMeasure1),
	  calculateErrorMeasure4(PositionList,Xc,Yc,Rc,ErrorMeasure),
	  setting(maxAllowableErrorForCircleOfBestFitPerPositionOnAverage(MaxAllowableErrorForCircleOfBestFitPerPositionOnAverage)),
	  %Multiply the number of positions by the max allowable error, since the error limit is per position (on average)
	  MaxAllowableErrorForCircleOfBestFit is NumberOfPositions * MaxAllowableErrorForCircleOfBestFitPerPositionOnAverage,
	  ErrorMeasure =< MaxAllowableErrorForCircleOfBestFit,
	  %Shift the circle of best fit such that the last position in the position list lies on the shifted circle of best fit
	  %We will use the shifted circle of best fit to construct the trajectory of best fit
	  shiftCircle(Xc,Yc,Rc,LastXPosition,LastYPosition,ShiftedXc,ShiftedYc),
	  %Construct a trajectory of best fit in the form of a curved trajectory
	  %The curved trajectory of best fit will look like the following:
	  %  curvedTrajectory(secondToLastPosition(ProjectedSecondLastXPosition,ProjectedSecondLastYPosition),
	  %                   secondToLastElapsedTime(SecondToLastElapsedTime),lastPosition(LastXPosition,LastYPosition),
	  %                   latestProjectedCircle(ShiftedXc,ShiftedYc,Rc,DirectionSign),magnitude(ProjectedXMagnWithCorrectSign,ProjectedYMagnWithCorrectSign),
	  %                   acceleration(AccelTriplets),CTOBFPositionList,CTOBFCircleOfBestFit)
	  %Calculate DirectionSign of the shifted circle of best fit, with (FirstXPosition,FirstYPosition) as the starting point and 
	  %(LastXPosition,LastYPosition) as the end point.
	  angleBetweenTwoVectors(FirstXPosition,FirstYPosition,LastXPosition,LastYPosition,ShiftedXc,ShiftedYc,_SomeAngle,DirectionSign),
	  
	  %The steps below are needed for finding the projected second to last position
	  
	  %Step 1: calculate the chord length between the last position and the projected second to last position. This chord length is equal to the
	  %distance that would be covered given a speed that is last observed (LatestSpeed) and a time period of (LastElapsedTime -
	  %SecondToLastElapsedTime)
	  ChordLength is LatestSpeed * (LastElapsedTime - SecondToLastElapsedTime),
	  
	  %Step 2: the angle that we're finding below is the angle between the vector starting at (ShiftedXc,ShiftedYc) and ending at the last position 
	  %and  the vector starting at (ShiftedXc,ShiftedYc) and ending at the projected 2nd to last position.
	  %The below formula is derived from http://en.wikipedia.org/wiki/Chord_(geometry)
	  AngleLastAndSecondToLastPosInRads is acos(1 - ChordLength^2/(2*Rc^2)),
	  %AngleLastAndSecondToLastPosInRads should run in the opposite direction of the angle between the vector starting at (ShiftedXc,ShiftedYc) and ending at
	  %(FirstXPosition,FirstYPosition) and the vector starting at (ShiftedXc,ShiftedYc) and ending at (LastXPosition,LastYPosition).
	  AngleLastAndSecondToLastPosInRadsWithCorrectSign is -DirectionSign * AngleLastAndSecondToLastPosInRads,
	  
	  %Step 3: find the angle between the vector that starts at (ShiftedXc,ShiftedYc) and is parallel to the positive X-axis, and the vector starting at  
	  %(ShiftedXc,ShiftedYc) and ending at (LastXPosition,LastYPosition).
	  ShiftedXcPlus1 is ShiftedXc + 1,
	  angleBetweenTwoVectors(ShiftedXcPlus1,ShiftedYc,LastXPosition,LastYPosition,ShiftedXc,ShiftedYc,AngleXAxisAndLastPosInDegrees,DirectionSign2),
	  AngleXAxisAndLastPosInRads is AngleXAxisAndLastPosInDegrees * pi / 180, %convert from degrees to rads
	  AngleXAxisAndLastPosInRadsWithCorrectSign is DirectionSign2 * AngleXAxisAndLastPosInRads,
	  
	  %Step 4: combine AngleXAxisAndLastPosInRadsWithCorrectSign with AngleLastAndSecondToLastPosInRadsWithCorrectSign to give the angle between the vector
	  %that starts at (ShiftedXc,ShiftedYc) and is parallel to the positive X-axis, and the vector starting at (ShiftedXc,ShiftedYc) and ending at the 
	  %projected 2nd to last position.
	  AngleXAxisAndSecondToLastPosInRadsWithCorrectSign is AngleXAxisAndLastPosInRadsWithCorrectSign + AngleLastAndSecondToLastPosInRadsWithCorrectSign,
	  
	  %Step 5: use AngleXAxisAndSecondToLastPosInRadsWithCorrectSign to project the second to last position.
	  ProjectedSecondLastXPosition is ShiftedXc + Rc * cos(AngleXAxisAndSecondToLastPosInRadsWithCorrectSign),
	  ProjectedSecondLastYPosition is ShiftedYc + Rc * sin(AngleXAxisAndSecondToLastPosInRadsWithCorrectSign),
	  
	  %Now find the projected X and Y magnitudes (speed)
	  ProjectedXMagnWithCorrectSign is (LastXPosition - ProjectedSecondLastXPosition) / (LastElapsedTime - SecondToLastElapsedTime),
	  ProjectedYMagnWithCorrectSign is (LastYPosition - ProjectedSecondLastYPosition) / (LastElapsedTime - SecondToLastElapsedTime),
	  
	  %Just include the projected second to last position and the last position in CTOBFPositionList
	  CTOBFPositionList = [(ProjectedSecondLastXPosition,ProjectedSecondLastYPosition),(LastXPosition,LastYPosition)],
	  
	  %Use the shifted circle of best fit as the curved trajectory's circle of best fit
	  %ErrorMeasure for this would be 0.0 since the curve is derived from the same circle of best fit
	  CTOBFCircleOfBestFit = circleOfBestFit(ShiftedXc,ShiftedYc,Rc,0.0), 
	  
	  TrajectoryOfBestFit = curvedTrajectory(secondToLastPosition(ProjectedSecondLastXPosition,ProjectedSecondLastYPosition),
	                     					 secondToLastElapsedTime(SecondToLastElapsedTime),lastPosition(LastXPosition,LastYPosition),
	                     					 latestProjectedCircle(ShiftedXc,ShiftedYc,Rc,DirectionSign),
	                     					 magnitude(ProjectedXMagnWithCorrectSign,ProjectedYMagnWithCorrectSign),
	                     					 acceleration(AccelTriplets),CTOBFPositionList,CTOBFCircleOfBestFit),
	  !
	 )
	;
	 %Otherwise if there is no good fit, the trajectory of best fit is undefined
	 (TrajectoryOfBestFit = undefined
	 )	
	).	

%DOC
%Given a circle with (Xc,Yc) as the center and Rc as the radius, shift the circle such that (XPosition,YPosition)
%lies on the circle. The shift should be done along the line that connects (Xc,Yc) to (XPosition,YPosition), that
%is, the line that connects (Xc,Yc) to (ShiftedXc,ShiftedYc) would coincide with the line that connects (Xc,Yc) to
%(XPosition,YPosition).
% 
shiftCircle(Xc,Yc,Rc,XPosition,YPosition, %Input
			ShiftedXc,ShiftedYc			  %Output
		   ) :-
	XcPlus1 is Xc + 1,
	%Find angle between vector that starts at (Xc,Yc) and is parallel to the X-axis, and the vector that starts at (Xc,Yc) and ends at
	%(XPosition,YPosition).
	angleBetweenTwoVectors(XcPlus1,Yc,XPosition,YPosition,Xc,Yc,AngleXAxisAndPositionInDegrees,Direction1),
	AngleXAxisAndPositionInRads is AngleXAxisAndPositionInDegrees * pi / 180, %convert from degrees to rads
	AngleXAxisAndPositionInRadsWithCorrectSign is Direction1 * AngleXAxisAndPositionInRads,
	
	%Find intersection between line starting at (Xc,Yc) and ending at (XPosition,YPosition) and the circle centred at (Xc,Yc)
	XIntersect is Xc + Rc * cos(AngleXAxisAndPositionInRadsWithCorrectSign),
	YIntersect is Yc + Rc * sin(AngleXAxisAndPositionInRadsWithCorrectSign),
	
	XDiff is XPosition - XIntersect,
	YDiff is YPosition - YIntersect,
	
	ShiftedXc is Xc + XDiff,
	ShiftedYc is Yc + YDiff.

%DOC
%Given two ElapsedTimes belonging to two frames about a certain figure, check whether there are any
%intervening frames that also contains that figure.
%ElapsedTime1 must be less than ElapsedTime2.
%
delay twoFramesAreAdjacent(ElapsedTime1,ElapsedTime2,FigureId)
	if nonground([ElapsedTime1,ElapsedTime2,FigureId]).
twoFramesAreAdjacent(ElapsedTime1,ElapsedTime2,FigureId) :-
	ElapsedTime1 < ElapsedTime2,
	not ((findAnyCorroboratingEdge(_SpanEnd1,_SpanEnd2,
								   [timestamp(ElapsedTime1b),figure(FigureId,_,_,_)],
								   _CF,_ParentId,_RHS_ParsedParts
								  ),
		  ElapsedTime1b > ElapsedTime1,
		  ElapsedTime1b < ElapsedTime2
		)).
		
%DOC
%Given an ElapsedTime and a FigureId, find the ElapsedTime of the previous frame that also contains the FigureId,
%if there is any.
delay findPreviousFrameElapsedTime(ElapsedTime,FigureId,PrevElapsedTime)
	if nonground([ElapsedTime,FigureId]).
findPreviousFrameElapsedTime(ElapsedTime,FigureId,PrevElapsedTime) :-
	findAnyCorroboratingEdge(_SpanEnd1,_SpanEnd2,
							 [timestamp(PrevElapsedTime),figure(FigureId,_,_,_)],
							 _CF,_ParentId,_RHS_ParsedParts
							),
	twoFramesAreAdjacent(PrevElapsedTime,ElapsedTime,FigureId),
	!.
				
%DOC
% Calculate acceleration given the inputs. The amount of acceleration 
% does not always reflect real acceleration. Below a certain threshold 
% relative to the speed, the acceleration is considered imperceptible to 
% observers and the value of the triplet (XAccel,YAccel,AccelDirection) 
% would be (0,0,0) to reflect this. The ratio that defines the threshold 
% is configurable in Wayang.properties. AccelDirection defines whether
% there is an acceleration(1), a constant speed(0), or a deceleration(-1). 
% Note that the two velocity magnitude pairs should be parallel. The caller
% should ensure this.
delay calculateAcceleration(XMagn1,YMagn1,XMagn2,YMagn2,ElapsedTime1,ElapsedTime2,
								XAccel,YAccel,AccelDirection)
	if nonground([XMagn1,YMagn1,XMagn2,YMagn2,ElapsedTime1,ElapsedTime2]).
calculateAcceleration(XMagn1,YMagn1,XMagn2,YMagn2,ElapsedTime1,ElapsedTime2, %input
						XAccel,YAccel,AccelDirection 						 %output
					 ) :-
	ActualXAccel is (XMagn2 - XMagn1)/(ElapsedTime2 - ElapsedTime1),
	ActualYAccel is (YMagn2 - YMagn1)/(ElapsedTime2 - ElapsedTime1),
	ActualAccelMagnSquared is ActualXAccel ^ 2 + ActualYAccel ^ 2,
	sqrt(ActualAccelMagnSquared,ActualAccelMagn),
	Speed2Squared is XMagn2 ^ 2 + YMagn2 ^ 2,
	sqrt(Speed2Squared,Speed2),
	Speed1Squared is XMagn1 ^ 2 + YMagn1 ^ 2,
	sqrt(Speed1Squared,Speed1),
	SpeedDiff is Speed2 - Speed1,
	(SpeedDiff > 0 ->
		ActualAccelDirection = 1
	;
		(SpeedDiff < 0 ->
			ActualAccelDirection = -1
		;
			ActualAccelDirection = 0
		)
	),
	setting(minPerceptibleAccelerationOverSpeedRatio(MinPerceptibleAccelerationOverSpeedRatio)),
	%Compare acceleration magnitude with Speed1
	AccelerationOverSpeedRatio is ActualAccelMagn / Speed1,
	%If the ratio is below the threshold, acceleration is considered imperceptible and
	%should be given a value of (0,0)
	%//TODO: it seems that the duration of the trajectory also influences the noticeability, so this ratio alone might not be enough
	%//TODO: (cot'd) the duration could be taken into account at higher level ascriptions such as intention / force ascriptions. 
	(AccelerationOverSpeedRatio < MinPerceptibleAccelerationOverSpeedRatio ->
		XAccel = 0,
		YAccel = 0,
		AccelDirection = 0
	;
		XAccel = ActualXAccel,
		YAccel = ActualYAccel,
		AccelDirection = ActualAccelDirection
	).  

%DOC
%Checks that the acceleration triplets in the list shows near constant positive acceleration.
%
accelListDisplaysNearConstantPositiveAcceleration([]).
accelListDisplaysNearConstantPositiveAcceleration([(_,_,1)]).
accelListDisplaysNearConstantPositiveAcceleration([(XAccel1,YAccel1,1),(XAccel2,YAccel2,1)|RemainingAccelTriplets]) :-
	accelerationsAreWithinErrorRange(XAccel1,XAccel2),
	accelerationsAreWithinErrorRange(YAccel1,YAccel2),
	accelListDisplaysNearConstantPositiveAcceleration([(XAccel2,YAccel2,1)|RemainingAccelTriplets]).

%DOC
%Predicate checks that list element n >= list element n + 1 for all n's.
%No check is made that elements are orderable. 
listIsInNonAscendingOrder([]).
listIsInNonAscendingOrder([_]).
listIsInNonAscendingOrder([X,Y|Xs]) :-
	X >= Y,
	listIsInNonAscendingOrder([Y|Xs]).
	
%DOC
%Predicate generates a position list for a given figure, start and end elapsed time.
%
delay generatePositionList(FigureId,StartElapsedTime,EndElapsedTime,PositionList)
	if nonground([FigureId,StartElapsedTime,EndElapsedTime]).
generatePositionList(FigureId,StartElapsedTime,EndElapsedTime, %Input
					 PositionList							   %Output
					) :-
	findall(position(X,Y),
			(findAnyCorroboratingEdge(_SpanEnd1,_SpanEnd2,
									  [timestamp(ElapsedTime),
									   figure(FigureId,position(X,Y),_Shape,_Color)],
									  _CF,_ParentId,_RHS_ParsedParts
									 ),
			 ElapsedTime =< EndElapsedTime,
			 ElapsedTime >= StartElapsedTime
			),
			PositionList1
		   ),
	%Since edges are asserted using asserta, the latest frame edges are topmost.
	%So we need to reverse the position list
	reverse(PositionList1,PositionList).
										
%DOC
%A call to the built-in ic:min predicate with an added delayability
delay delayableMin(ListOfMinCandidates,Min)
	if nonground(ListOfMinCandidates).
delayableMin(ListOfMinCandidates,Min) :-
	ic:min(ListOfMinCandidates,Min). 
	
%DOC
%A call to the built-in instance/2 predicate with an added delayability.
%The call is surrounded with a not/1, i.e. the predicate succeeds if
%the instance check fails.
delay delayableNotInstance(Instance,Term)
	if nonground([Instance,Term]).
delayableNotInstance(Instance,Term) :-
	not (instance(Instance,Term)).
	
%DOC
%This predicate allows a call in which there is a choice (;) between two or more 
%groups of predicate calls to be delayed if any of the specified arguments are
%not yet ground. This is useful when we want to avoid committing to a disjunct
%too early. If one or more groups contain a delayable call, the delayable call
%might succeed too early because it's delayed, only to fail later when the
%required arguments become ground. As the failure occurs at a different part of
%the execution tree, the alternative choicepoint cannot be revisited.
%This predicate allows us to delay the entire call to the different choicepoints,
%hence allowing the choicepoints to be evaluated only when the required arguments
%are already ground.
delay delayableDisjunctedCalls(ArgumentList,DisjunctedCalls)
	if nonground(ArgumentList).
delayableDisjunctedCalls(_ArgumentList,DisjunctedCalls) :-
	call(DisjunctedCalls).