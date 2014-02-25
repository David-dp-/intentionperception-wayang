%%
%% IncrementalParser.ecl, part of the Wayang project of cogsys.ihpc.a-star.edu.sg
%%
%% The original code is by Gazdar & Mellish, Natural Language Processing in Prolog, pp. 200-1.
%% - edge/5 has had its 4th and 5th parameters switched to match the typographic ordering of these two parts of a RHS.
%% - tokenHasCategory/2 is the same as original word/2 but with parameters reversed.
%% - test/1 and start_chart/3 have been merged and changed so they can be used with a token sequence whose length and
%%   components aren't known in advance - it finds out the next token only when testReadToken/1 is called. This change
%%   is intended to make the parser usable in truly dynamic scenarios (albeit, those where neither previously-seen
%%   tokens nor the grammar are allowed to change).
 
:- lib(ic).

:- dynamic( edge/8 ).
:- dynamic( currentSpanEnd/1 ).
:- dynamic( setting/1 ).
:- dynamic( totalIncompleteEdges/1 ).
:- dynamic( totalCompletedEdges/1 ).
:- dynamic( listOfEdgeIdsInQueue/1 ).
:- dynamic( countOfTotalEdgesInQueue/1 ).

%We declare these here (instead of in perceptibilityFilter.pro and 
% KnowledgeBase.ecl where they are asserted) because writeParsingReport/0
% calls them.
:- dynamic( filteredFromPerception/1 ).
:- dynamic( discontinuity/1 ).
:- dynamic( tip/1 ).

initializeParser :-
	retractall( edge(_,_,_,_,_,_,_,_) ),
	( retract( currentSpanEnd(_) ) ; true ),
	resetEdgeIds,
	assert( currentSpanEnd(1) ),
	assert( totalIncompleteEdges(0) ),
	assert( totalCompletedEdges(0) ),
	assert(listOfEdgeIdsInQueue([])),
	assert(countOfTotalEdgesInQueue(0)).
	
processFrame(frame(FrameItems)) :-
	fetchAndIncrementCurrentSpanEnd(CurrentSpanEnd, _NextSpanEnd),
	%condPrintf(traceParser,"Processing frame items: %w\n", [FrameItems]),
	ExpectedFrameItems = [], %for self-documentation of meaning of [] in addEdge/7 call
	%If this is the first frame, call writeLogHeader to initialize the log with the proper header
	(CurrentSpanEnd = 1 ->
		writeLogHeader
	;
		true
	),
	writeInput(CurrentSpanEnd,frame(FrameItems)), 
	%The following addEdge for frame items uses CurrentSpanEnd instead of NextSpanEnd as in 
	%Gazdar & Mellish's algorithm, to permit later effects in rules to be expressed using 
	%higher-level predicates other than frame contents, such as trajectory and intention predicates.
	addEdge(CurrentSpanEnd, CurrentSpanEnd, FrameItems, 1.0, [FrameItems], ExpectedFrameItems, []),
	writeRowCloserString.
			
writeParsingReport :-
	condPrintf(true,"\n    Incomplete edges:\n", []),
	forEachMatchDo(	edge(Id,SpanStart,SpanEnd,LHS,CF,RHS_parsedParts,[ExpectationsHead|ExpectationsTail],ParentIds),
					(condPrintf(true,"\n    + %w CF: %w Span: %w %w\n", [Id,CF,SpanStart,SpanEnd]),
					 condPrintf(true,"      Label: %w\n", [LHS]),
					 condPrintf(true,"      Scenes identified: %w\n", [RHS_parsedParts]),
					 condPrintf(true,"      Scenes   expected: %w\n", [[ExpectationsHead|ExpectationsTail]]),
					 condPrintf(true,"                Parents: %w\n", [ParentIds])
				)),
	
	condPrintf(true,"\n    Completed edges:\n", []),flush(stdout),
	forEachMatchDo(	edge(Id,SpanStart,SpanEnd,LHS,CF,RHS_parsedParts,[],ParentIds),
					(condPrintf(true,"\n    * %w CF: %w Span: %w %w\n", [Id,CF,SpanStart,SpanEnd]),
					 condPrintf(true,"      Label: %w\n", [LHS]),
					 condPrintf(true,"      Scenes identified: %w\n", [RHS_parsedParts]),
					 condPrintf(true,"                Parents: %w\n", [ParentIds])
				)),
				
	condPrintf(true,"\n    Filterings:\n", []),flush(stdout),
	forEachMatchDo(	filteredFromPerception(FilterComment),
					condPrintf(true,"      %w\n", [FilterComment])
				),
								
	condPrintf(true,"\n    Discontinuities:\n", []),flush(stdout),
	forEachMatchDo(	discontinuity(DiscontinuityComment),
					condPrintf(true,"      %w\n", [DiscontinuityComment])
				),
				
	condPrintf(true,"\n    Tips:\n", []),flush(stdout),
	forEachMatchDo(	tip(TipComment),
					condPrintf(true,"      %w\n", [TipComment])
				).


%
% The rest of this file encodes a bottom-up chart parser.
%


%DOC
% This predicate serves the same purpose as the following excerpt from Gazdar & Mellish's
% second addEdge/7 clause, where LHS1to2 is already bound:
%  
%	forEachMatchDo(	rule(LHS0to2, [LHS1to2 | RHS_expectedParts0to2]), 
%					addEdge(SpanEnd1, SpanEnd1, LHS0to2, 1.0, [LHS0to2], [LHS1to2 | RHS_expectedParts0to2], ParentIds)),
%
% 1. Find all rules that:
%    a. Have a consequent that represents a causal relation with a confidence factor (CF),
%    b. where the effects of the causation are a series of scenes,
%    c. and the first of those scenes can be matched by items in the current frame.
%    Almost all rules will fit this description.
% 2. For each such rule, find all ways that the current frame items can match the scene.
%    For example, the scene might mention only a timestamp and a figure; if there are 5
%    figures in the current frame, then the scene can be matched 5 ways.
% 3. Using each match of the first scene as a replacement for the generic scene, see
%    which of the matches would actually allow the antecedents of the rule to be supported.
%    Rule antecedents impose most of the constraints on a match, so this query step is
%    the first time in this predicate that we really test if a rule is applicable to the
%    current situation. And ideally, the CF value will depend on this test.
% 4. If a rule's antecedents can be supported with some portion of the current frame, then
%    add an "edge" to the parser's "chart" to represent the fact that we have matched the
%    initial scene of the rule and to store the remaining scenes we should expect to see.
%
addExplanatoryEdges(CurrentSpanEnd, RHSHeadSupport, ParentId) :-
	getSomeRule(Rule1,Label), %We backtrack to this to get relevant rules one-by-one
	once((	copy_term(Rule1,Rule), %To ensure that the constraints we apply later won't interfere with other instantiations of the rule
			locateRHSHead(Rule, RHSHead),
			findAllCovers(RHSHead, RHSHeadSupport, RHSHeadInstantiations),
			condPrintf(traceParser,"\n>>FAC using rule: %w\n      RHSHead %w\n  with ground %w\n  has covers: %w\n", [Label,RHSHead, RHSHeadSupport, RHSHeadInstantiations]),flush(stdout), %//DEBUG
			(foreach(RHSHeadInst, RHSHeadInstantiations),param(Rule,CurrentSpanEnd,ParentId) do
				copy_term(Rule,Rule2), %verifyRule copies bindings into the rule, so start with fresh copy each time
				verifyRule(Rule2, RHSHeadInst, LHS2, CF2, ExpectedFrameItems),
				%The following addEdge uses spanEndForABottomUpRuleEdge as a span end, instead of CurrentSpanEnd as in Gazdar & Mellish's
				%algorithm, to permit later effects in rules to be expressed using higher-level predicates other than frame contents, such
				%as trajectory and intention predicates.
				addEdge(CurrentSpanEnd, spanEndForABottomUpRuleEdge, LHS2, CF2, [], [RHSHeadInst | ExpectedFrameItems], [ParentId])
			)
		)), %once
	fail.
addExplanatoryEdges(_,_,_) :- true. %guaranteed successful exit of fail-loop to find all matching rules


fetchAndIncrementCurrentSpanEnd(CurrentSpanEnd, NextSpanEnd) :-
	retract( currentSpanEnd(CurrentSpanEnd) ),
	NextSpanEnd is CurrentSpanEnd + 1,
	asserta( currentSpanEnd(NextSpanEnd) ).
	
	
%//TODO How to use confidence factors correctly when checking if there is already an edge that
%    subsumes the proposed one? And similarly, how to use delayed goals?
%
addEdge(SpanEnd0, SpanEnd1, LHS, _CF1, RHS_parsedParts, RHS_expectedParts, ParentIds) :-
	%edge(SpanEnd0, SpanEnd1, LHS, RHS_parsedParts, RHS_expectedParts),!. %Gazdar & Mellish's for case where syn categories are atoms
	edge(Id2, SpanEnd0, SpanEnd1, LHS2, _CF2, RHS_parsedParts2, RHS_expectedParts2, ParentIds2),
	
	/*
	printf(	"\ninstance?\n %w\n %w\n",
			[ignoringEdgeLabels(SpanEnd0, SpanEnd1, LHS,  CF3, RHS_parsedParts,  RHS_expectedParts),
			 ignoringEdgeLabels(SpanEnd0, SpanEnd1, LHS2, CF4, RHS_parsedParts2, RHS_expectedParts2)
			]),
	*/
	
	instance(	ignoringEdgeLabels(SpanEnd0, SpanEnd1, LHS,  CF3, RHS_parsedParts,  RHS_expectedParts),
				ignoringEdgeLabels(SpanEnd0, SpanEnd1, LHS2, CF4, RHS_parsedParts2, RHS_expectedParts2) ),
	condPrintf(traceParser,">>Proposed edge    %w %w  %w  %w\n    %w\n    %w\n    %w\n", [SpanEnd0, SpanEnd1, CF3, LHS,  RHS_parsedParts,  RHS_expectedParts,  ParentIds]), %//DEBUG
	condPrintf(traceParser,"    subsumed by %w %w %w  %w  %w\n    %w\n    %w\n    %w\n", [Id2, SpanEnd0, SpanEnd1, CF4, LHS2, RHS_parsedParts2, RHS_expectedParts2, ParentIds2]),
	!. %We cut here to avoid re-entering addEdge from either of the extendSpan fns while backtracking in their fail loops

%//TODO It seems CF2 in the first addEdge call should depend on CF1, and CF3 in the second addEdge call should depend on both CF1 and CF2.
%
addEdge(SpanEnd1, SpanEnd2, LHS1to2, CF1, RHS_parsedParts1to2, RHS_expectedParts, ParentIds) :-
	RHS_expectedParts = [], %1st part of an extended head
	newEdgeId(NewId),
	condPrintf( traceParser,
				" >>call assertEdge for completed edge: %w\n\n", [NewId] ),
	statistics(session_time,TimeBeforeAssertEdge),
	assertEdge(NewId, SpanEnd1, SpanEnd2, LHS1to2, CF1, RHS_parsedParts1to2, RHS_expectedParts, ParentIds),
	statistics(session_time,TimeAfterAssertEdge),
	TotalTimeInAssertEdge is TimeAfterAssertEdge - TimeBeforeAssertEdge,
	condPrintf( traceParser,
				" >>finish AssertEdge for completed edge: %w with total time: %w seconds\n", [NewId,TotalTimeInAssertEdge] ),
	condPrintf(traceParser,"\n 2Added %w %w %w  %w\n  LHS: %w\n  PP:  %w\n  XP:  %w\n  Supp: %w\n", [NewId, SpanEnd1, SpanEnd2, CF1, LHS1to2, RHS_parsedParts1to2, RHS_expectedParts, ParentIds]), %//DEBUG
	condPrintf( traceParser,
				" >>call AEE for edge: %w\n\n", [NewId] ),
	statistics(session_time,TimeBeforeAEE),
	addExplanatoryEdges(SpanEnd1, LHS1to2, NewId),
	statistics(session_time,TimeAfterAEE),
	TotalTimeInAEE is TimeAfterAEE - TimeBeforeAEE,
	condPrintf( traceParser,
				" >>finish AEE for edge: %w with total time: %w seconds\n\n", [NewId,TotalTimeInAEE] ),
	condPrintf( traceParser,
				" >>call LEFTward for edge: %w\n\n", [NewId] ),
	statistics(session_time,TimeBeforeLeftward),
	extendSpanLeftwardByMatchingExpectations(SpanEnd1, SpanEnd2, LHS1to2, CF1, RHS_parsedParts1to2, NewId),
	statistics(session_time,TimeAfterLeftward),
	TotalTimeInLeftward is TimeAfterLeftward - TimeBeforeLeftward,
	condPrintf( traceParser,
				" >>finish LEFTward for edge: %w with total time: %w seconds\n\n", [NewId,TotalTimeInLeftward] ),
	!. %We cut here to avoid re-entering addEdge from either of the extendSpan fns while backtracking in their fail loops. 

addEdge(SpanEnd0, SpanEnd1, LHS0to2, CF1, RHS_parsedParts0to1, [LHS1to2 | RHS_expectedParts0to2], ParentIds) :-
	newEdgeId(NewId),
	condPrintf( traceParser,
				" >>call assertEdge for incomplete edge: %w\n\n", [NewId] ),
	statistics(session_time,TimeBeforeAssertEdge),
	assertEdge(NewId, SpanEnd0, SpanEnd1, LHS0to2, CF1, RHS_parsedParts0to1, [LHS1to2 | RHS_expectedParts0to2], ParentIds),
	statistics(session_time,TimeAfterAssertEdge),
	TotalTimeInAssertEdge is TimeAfterAssertEdge - TimeBeforeAssertEdge,
	condPrintf( traceParser,
				" >>finish AssertEdge for incomplete edge: %w with total time: %w seconds\n", [NewId,TotalTimeInAssertEdge] ),
	condPrintf(traceParser,"\n 3Added %w %w %w  %w\n  LHS: %w\n  PP:  %w\n  LC:  %w\n  OXP: %w\n  Supp: %w\n", [NewId, SpanEnd0, SpanEnd1, CF1, LHS0to2, RHS_parsedParts0to1, LHS1to2, RHS_expectedParts0to2, ParentIds]), %//DEBUG
	%//TODO RHS_parsedParts0to1 needs to be passed to extendSpanRightward
	%//The new edge added as a result of extending rightward would have
	%//RHS_parsedParts0to1 as the head of the new edge's parsed parts
	condPrintf( traceParser,
				" >>call RIGHTward for edge: %w\n\n", [NewId] ),
	statistics(session_time,TimeBeforeRightward),
	extendSpanRightwardByMatchingExpectations(SpanEnd0, SpanEnd1, LHS1to2, CF1, LHS0to2, RHS_expectedParts0to2, NewId),
	statistics(session_time,TimeAfterRightward),
	TotalTimeInRightward is TimeAfterRightward - TimeBeforeRightward,
	condPrintf( traceParser,
				" >>finish RIGHTward for edge: %w with total time: %w seconds\n\n", [NewId,TotalTimeInRightward] ),
	!. %We cut here to avoid re-entering addEdge from either of the extendSpan fns while backtracking in their fail loops

assertEdge(	Id,SpanStart,SpanEnd,LHS,CF,
			RHS_parsedParts,RHS_expectedParts,ParentIds) :-
	NewEdge =.. [edge,Id,SpanStart,SpanEnd,LHS,CF,RHS_parsedParts,RHS_expectedParts,ParentIds],
	%Keep draw's out of summaries because they are subject to change, and that makes keeping the test definitions up-to-date difficult.
	extractDrawingInstructions(LHS, LHSDrawInstrs, LHSwoDIs),
	%This seems to be the best place to add the frame number to the draw instructions. Draw instructions are only generated once
	%when the first effect of a rule is matched, but the frame number field can be updated as new edges are generated to extend other
	%edges. The same goes for draw instr ID, which should use the numbering for the corresponding edges, and RHS-matching ancestor draw instr IDs, 
	%which should correspond to the IDs of the completed ancestor edges that match the RHS. These ancestor edges are of interest since they
	%are the edges that enable the completion of the current edge, and for visualization purposes they are perhaps more informative than
	%the actual parent edges.
	%findRHSMatchingAncestorEdges finds RHS-matching completed ancestor edges. If the edge is a bottom-up rule edge,
	%the RHSMatchingAncestorIds list would be empty, since the RHS of such an edge would not have been matched at all.
	%If the edge is a frame edge, ParentIds is empty and RHSMatchingAncestorIds would also be empty. 
	
	%//TODO fix findRHSMatchingAncestorEdges/2 so that it wouldn't fail even though edges are retracted to implement queuing
	%findRHSMatchingAncestorEdges(ParentIds,RHSMatchingAncestorIds),

	%updateDrawInstrsWithCurrentFrameNumberAndDrawIdAndRHSMatchingAncestorDrawIds(LHSDrawInstrs,Id,RHSMatchingAncestorIds,LHSDrawInstrs1),
	
	%//TODO when findRHSMatchingAncestorEdges/2 call updateDrawInstrsWithCurrentFrameNumberAndDrawIdAndRHSMatchingAncestorDrawIds/4
	%with the proper ancestor IDs instead of parent IDs
	updateDrawInstrsWithCurrentFrameNumberAndDrawIdAndRHSMatchingAncestorDrawIds(LHSDrawInstrs,Id,ParentIds,LHSDrawInstrs1),
	
	%Java expects a term so lists need to be represented as a term by putting the list in a functor.
	(LHSDrawInstrs1 = [_|_] -> LHSDrawInstrs2 =.. [listOfDIs|LHSDrawInstrs1] ; LHSDrawInstrs2 = LHSDrawInstrs1),
	generateEdgeSummaryForJava(NewEdge,LHSwoDIs,NewEdgeSummary),
	%Update completed/incomplete edge count
	(RHS_expectedParts = [] ->
		retract(totalCompletedEdges(CurrentTotalCompletedEdges)),
		NewTotalCompletedEdges is CurrentTotalCompletedEdges + 1,
		assert(totalCompletedEdges(NewTotalCompletedEdges)),
		CompletionStatus = completed
	;
		retract(totalIncompleteEdges(CurrentTotalIncompleteEdges)),
		NewTotalIncompleteEdges is CurrentTotalIncompleteEdges + 1,
		assert(totalIncompleteEdges(NewTotalIncompleteEdges)),
		CompletionStatus = incomplete
	),
	%If we are running as part of a test, then verify the edge before asserting it.
	% The calls to writeTerm/1 put a term on the out-queue so TestNG and the visualization can use it.
	%
	verifyNewEdgeSummary(NewEdgeSummary,MissingEdgeSummary),
	([] == MissingEdgeSummary
	 -> (writeTerm(NewEdgeSummary,CompletionStatus),
	     (CompletionStatus = completed ->
	     	asserta(NewEdge)
	     ;
	     	addToIncompleteEdgeQueue(NewEdge)
	     ) 
	    )
	 ;  writeTerm(mismatch(NewEdgeSummary,MissingEdgeSummary),CompletionStatus) ),
	
	%If the span is worth reporting about (i.e. not ending at spanEndForABottomUpRuleEdge),
	%there is any drawing instruction, and it contains no free variables (i.e. it belongs to a completed edge), 
	%pass it to Java to render.
	((SpanEnd \= spanEndForABottomUpRuleEdge,ground(LHSDrawInstrs2))
	 -> (([] == LHSDrawInstrs2) ; writeTerm(LHSDrawInstrs2,CompletionStatus))
	 ;  true ).

%DOC	 
% We conflate all of the rule-specific content to a string, because the Java side does nothing more with
% it than display it. And anyway, any variables would be converted to null's if we tried to pass the
% term as-is, since that's how the EXDR embedding for ECLiPSe in Java is designed to work.
%
generateEdgeSummaryForJava(Edge,LHSwoDIs,EdgeSummary) :-
	Edge =.. [edge,Id,SpanStart,SpanEnd,_LHS,CF,RHS_parsedParts,RHS_expectedParts,ParentIds],!,

	(  (LHSwoDIs = [_|_], LHSPredAsString = "list")
	 ; (LHSwoDIs =.. [LHSPred|_LHSArgs], term_string(LHSPred,LHSPredAsString)) ),
	((RHS_expectedParts = []) -> CompletionStatusAsString = "completed" ; CompletionStatusAsString = "incomplete"),
	term_string(Id,IdAsString),
	list_string(ParentIds,ParentIdsAsStringsInList),
	
	%Keep draw's out of summaries because they are subject to change, and that makes keeping the test definitions up-to-date difficult.
	extractDrawingInstructions(RHS_parsedParts, _, RHSPPswoDIs),
	extractDrawingInstructions(RHS_expectedParts, _, RHSEPswoDIs),
	
	(ground(CF) ->
		termToVerifiableString([LHSwoDIs,CF,RHSPPswoDIs,RHSEPswoDIs],LabelAsString)
	 ;
	 	termToVerifiableString([LHSwoDIs,someCF,RHSPPswoDIs,RHSEPswoDIs],LabelAsString)
	),
	EdgeSummary = edgeSummary(IdAsString,ParentIdsAsStringsInList,SpanStart,SpanEnd,LHSPredAsString,CompletionStatusAsString,LabelAsString).

%DOC
% term_string/2 produces run-specific printouts for constrained vars that aren't usable as part of
%  a verification set, so we create something similar to term_string that avoids that problem.
%
termToVerifiableString(Term,String) :-
	sprintf(String,"%w",[Term]).
	
list_string([],[]).
list_string([[HeadHead|HeadTail]|Tail],[[HeadHead1|HeadTail1]|Tail1]) :-
	list_string(HeadHead,HeadHead1),
	list_string(HeadTail,HeadTail1),
	list_string(Tail,Tail1),!.
list_string([Head|Tail],[Head|Tail1]) :-
	(number(Head) ; string(Head)),
	list_string(Tail,Tail1),!.
list_string([Head|Tail],[HeadAsString|Tail1]) :-
	termToVerifiableString(Head,HeadAsString),
	list_string(Tail,Tail1),!.
	 
%DOC
% This is called by the setup method for a particular test. That test has defined a set of completed and
%  incomplete edges that represent a successful run of the test. The edges are stored under the predicate
%  indicated by parameter StoragePredicateForEdges. We retrieve the set of edges and bind it
%  to EdgesForVerification, so we can copy the set into a new fact using canonical
%  predicate edgesForVerification/1. This pred is "canonical" because verifyNewEdge expects there either
%  to be exactly one fact using that pred, in which case it uses the associated set of edges for testing,
%  or if there is no such fact, then verifyNewEdge assumes we are processing outside of any test, so it
%  doesn't try to verify any of the new edges passed into it.
%
populateEdgeSummariesForVerification(StoragePredicateForEdgeSummaries) :-
	EdgeSummariesTerm1 =.. [StoragePredicateForEdgeSummaries, EdgeSummariesForVerification],
	call(EdgeSummariesTerm1),
	retractall(edgeSummariesForVerification(_)),
	EdgeSummariesTerm =.. [edgeSummariesForVerification,EdgeSummariesForVerification],
	assert(EdgeSummariesTerm).

verifyNewEdgeSummary(NewEdgeSummary,MissingEdgeSummary) :-
	NewEdgeSummary = edgeSummary(IdAsString,_,_,_,_,_,_),
			
	(edgeSummariesForVerification(EdgeSummariesForVerification)
	 -> findSummaryWithId(IdAsString,EdgeSummariesForVerification,SummaryWithSameId),
	    ((NewEdgeSummary = SummaryWithSameId)
	     -> MissingEdgeSummary = []
	     ;  MissingEdgeSummary = SummaryWithSameId )
	 ;  MissingEdgeSummary = [] ). %No summaries have been set, so we must be running outside of any test. In that case, this method should act as a NO-OP.

findSummaryWithId(_IdAsString,[],[]).
findSummaryWithId(IdAsString,[SummariesHead|_],SummaryWithSameId) :-
	SummariesHead = edgeSummary(IdAsString,_,_,_,_,_,_), %(extended head of Prolog rule)
	SummaryWithSameId = SummariesHead.                   %(extended head of Prolog rule)
findSummaryWithId(IdAsString,[_|SummariesTail],SummaryWithSameId) :-
	findSummaryWithId(IdAsString,SummariesTail,SummaryWithSameId).

			
forEachMatchDo(Pattern, Action) :- call(Pattern), once(Action), fail.
forEachMatchDo(_,_) :- true.

	 
%DOC
% This predicate replaces the 2nd call to forEachMatchDo in the 2nd clause of addEdge/7:
%
%   forEachMatchDo(	edge(Id, SpanEnd0, SpanEnd1, LHS0to2, CF3, RHS_parsedParts0to1, [LHS1to2 | RHS_expectedParts0to2], _ParentIds), 
%					addEdge(SpanEnd0, SpanEnd2, LHS0to2, CF3, [RHS_parsedParts1to2 | RHS_parsedParts0to1], RHS_expectedParts0to2, [Id]) )
%
% The reason we had to replace that code is that it assumed rules would be comprised of atomic LHS' and RHS parts.
%
extendSpanLeftwardByMatchingExpectations(SpanEnd1, SpanEnd2, LHS, CF1, RHS_parsedParts1to2, ParentId1) :-
	condPrintf(traceParser,"\n>>LEFTward %w %w %w %w\n   LHS: %w\n   PP:  %w\n", [ParentId1, SpanEnd1, SpanEnd2, CF1, LHS, RHS_parsedParts1to2]),
	SpanEnd0b ~= spanEndForABottomUpRuleEdge, %we don't want the edge spawned by the bottom up rule to be extended again, since it has already been extended
					  						  %during the rightward expansion
	SpanEnd0 #=< SpanEnd0b, %SpanEnd0 could well be equal to SpanEnd0b
	%the end of the first edge & the start of the second edge being matched can either be equal or separated by 1 frame distance
	(SpanEnd1 < SpanEnd2, %Both are integers
	 SpanEnd0b = SpanEnd1
	;
	 SpanEnd1 == SpanEnd2, %Both are integers
	 SpanEnd0b is SpanEnd1 - 1
	),
	
	edge(ParentId2, SpanEnd0, SpanEnd0b, LHS0to2, CF2, RHS_parsedParts0to1, [LHS1to2 | RHS_expectedParts0to2], _GrandparentIds),
	%//TODO apply copy_term to edge, then create new cover test that binds 1st arg only using 2nd arg; then use this partially-bound edge below
	covers(LHS1to2,LHS),
	condPrintf(traceParser," >>L:Found for %w, %w %w %w  %w\n    LHS: %w\n    PP: %w\n    LC: %w\n    XP: %w\n", [ParentId1, ParentId2, SpanEnd0, SpanEnd1, CF2, LHS0to2, RHS_parsedParts0to1, LHS1to2, RHS_expectedParts0to2]),
	combineConfidenceFactors([CF1,CF2],CF),
	%//TODO simplify the parsed parts section of an edge. LHS0to2 should not 
	%be included, as it is not something that is directly observed. 
	addEdge(SpanEnd0, SpanEnd2, LHS0to2, CF, [LHS0to2|[RHS_parsedParts0to1|[RHS_parsedParts1to2]]], RHS_expectedParts0to2, [ParentId1,ParentId2]),
	condPrintf(traceParser," >>L:end %w %w %w  %w  %w\n\n", [ParentId1, SpanEnd0, SpanEnd2, CF, LHS0to2]),flush(stdout), %//DEBUG
	fail.
extendSpanLeftwardByMatchingExpectations(_,_,_,_,_,_). %exit condition of the always-successful fail-loop.


%DOC
% This predicate replaces the call to forEachMatchDo in the 3rd clause of addEdge/7:
%
%	forEachMatchDo(	edge(Id, SpanEnd1, SpanEnd2, LHS1to2, CF2, RHS_parsedParts1to2, [], _ParentIds), 
%					addEdge(SpanEnd0, SpanEnd2, LHS0to2, CF2, [RHS_parsedParts1to2 | RHS_parsedParts0to1], RHS_expectedParts0to2, [Id]) )
%
%//TODO Incorporate the previous parsed parts that have been observed prior
%to extending rightward.
extendSpanRightwardByMatchingExpectations(SpanEnd0, SpanEnd1, LHS, CF1, LHS0to2, RHS_expectedParts0to2, ParentId1) :-
	condPrintf(traceParser,"\n>>RIGHTward %w %w %w %w\n   LHS:   %w\n   LHS02: %w\n   XP02:  %w\n", [ParentId1, SpanEnd0, SpanEnd1, CF1, LHS, LHS0to2, RHS_expectedParts0to2]),
	%the end of the first edge & the start of the second edge being matched can either be equal or separated by 1 frame distance
	(SpanEnd1 == spanEndForABottomUpRuleEdge ->
	 	SpanEnd1b = SpanEnd0 %SpanEnd1b gets bound to the value SpanEnd0 is bound to. Both are integers
	 ;
	 	( SpanEnd1b #< SpanEnd2, %Neither of SpanEnd1b or SpanEnd2 is bound. Both should be integers
	 	  SpanEnd1b = SpanEnd1
		 ;
	 	  SpanEnd1b = SpanEnd2, %Neither of SpanEnd1b or SpanEnd2 is bound. Both should be integers
	 	  SpanEnd1b is SpanEnd1 + 1
		)
	),
	%Use findAnyCorroboratingEdgeWithCut/6 instead of findAnyCorroboratingEdge/6 since there doesn't seem to be a need to
	%ever try to match more than once
	findAnyCorroboratingEdgeWithCut(	SpanEnd1b,SpanEnd2,LHS,					%input
										_CF2,ParentId2,RHS_parsedParts1to2),	%output
	%We don't include CF2 in the combination, because it was factored into CF1 during leftward expansion.
	combineConfidenceFactors([CF1],CF),
	%//20110520-DP: I don't prepend RHS_expectedParts0to2 to the parsed parts
	%   for purely cosmetic reasons -- the format of the parsed parts doesn't
	%   affect control flow
	addEdge(SpanEnd0, SpanEnd2, LHS0to2, CF, RHS_parsedParts1to2, RHS_expectedParts0to2, [ParentId1, ParentId2]),
	condPrintf(traceParser," >>R:end %w %w %w\n   LHS:   %w\n   LHS02: %w\n   XP02:  %w\n", [ParentId1, SpanEnd0, SpanEnd1, LHS, LHS0to2, RHS_expectedParts0to2]),flush(stdout), %//DEBUG
	fail.
extendSpanRightwardByMatchingExpectations(_,_,_,_,_,_,_). %exit condition of the always-successful fail-loop.


%DOC
%Search for a completed edge whose LHS is a more instantiated subset of LHS1,
% indicating that LHS is conceivably true within the given span (while
% requiring that no backchaining be used to determine that).
%This is used by extendSpanRightwardByMatchingExpectations/7 and in some
% kb rules in their gating conditions.
%
findAnyCorroboratingEdge(	SpanEnd1, SpanEnd2, LHS1,					%input
							CF, ParentId, RHS_parsedParts ) :-			%output
	condPrintf( traceParser,
				" >>FACE:find for LHS: %w\n\n", [LHS1] ),
	statistics(session_time,TimeBefore),
	edge(	ParentId, SpanEnd1, SpanEnd2, LHS2,
			CF, RHS_parsedParts, [], _GrandparentIds ),
	covers(LHS1, LHS2),
	statistics(session_time,TimeAfter),
	TotalTime is TimeAfter - TimeBefore,
	condPrintf(	traceParser,
				" >>FACE:Found in %w seconds, %w %w %w  %w\n   LHS: %w\n   PP: %w\n\n",
				[TotalTime,ParentId, SpanEnd1, SpanEnd2, CF, LHS2, RHS_parsedParts] ).

%DOC
%Just like findAnyCorroboratingEdge/6, but with an added cut such that only 1
%edge is explored			
findAnyCorroboratingEdgeWithCut(	SpanEnd1, SpanEnd2, LHS1,					%input
									CF, ParentId, RHS_parsedParts ) :-			%output
	condPrintf( traceParser,
				" >>FACEWC:find for LHS: %w\n\n", [LHS1] ),
	statistics(session_time,TimeBefore),
	edge(	ParentId, SpanEnd1, SpanEnd2, LHS2,
			CF, RHS_parsedParts, [], _GrandparentIds ),
	covers(LHS1, LHS2),
	!,
	statistics(session_time,TimeAfter),
	TotalTime is TimeAfter - TimeBefore,
	condPrintf(	traceParser,
				" >>FACEWC:Found in %w seconds, %w %w %w  %w\n   LHS: %w\n   PP: %w\n\n",
				[TotalTime,ParentId, SpanEnd1, SpanEnd2, CF, LHS2, RHS_parsedParts] ).

%DOC
%Build a list consisting of completed ancestor edges that are responsible for (partially)
%matching the RHS of the (in)complete edge whose parents are given as input.  
%
%An edge with just 1 parent is a bottom-up rule edge. The RHS of such an edge has not been matched at all,
%so there is no edge in the output list. 
findRHSMatchingAncestorEdges([_ParentId],[]).
%An edge with no parent is a frame edge. Output list should be empty.
findRHSMatchingAncestorEdges([],[]).
findRHSMatchingAncestorEdges([ParentId1,ParentId2],RHSMatchingAncestorIds) :-
	edge(ParentId1,_SpanEnd1,_SpanEnd2,_LHS1,_CF1,_RHS_parsedParts1,RHS_expectedParts1,GrandParentIds1),
	edge(ParentId2,_SpanEnd3,_SpanEnd4,_LHS2,_CF2,_RHS_parsedParts2,_RHS_expectedParts2,GrandParentIds2),
	%If ParentId1 corresponds to a completed edge, ParentId2 doesn't, and vice versa
	(RHS_expectedParts1 = [] ->
		CompletedParentId = ParentId1,
		IncompleteGrandParentIds = GrandParentIds2
	;
		CompletedParentId = ParentId2,
		IncompleteGrandParentIds = GrandParentIds1
	),
	findRHSMatchingAncestorEdges(IncompleteGrandParentIds,RHSMatchingAncestorIds1),
	append(RHSMatchingAncestorIds1,[CompletedParentId],RHSMatchingAncestorIds).

%DOC
%Add new (incomplete) edge to queue. Use retract & assert with list of edge ids and
%variable which tracks total number of edges in queue in order to manage the queue.
%If queue is full, remove edge with smallest id from queue (by retracting).
%
addToIncompleteEdgeQueue(NewEdge) :-
	NewEdge =.. [edge,Id,_,_,_,_,_,_,_],
	countOfTotalEdgesInQueue(CountOfTotalEdgesInQueue),
	listOfEdgeIdsInQueue(ListOfEdgeIdsInQueue),
	setting(maxIncompleteEdgeQueueSize(MaxIncompleteEdgeQueueSize)),
	(CountOfTotalEdgesInQueue < MaxIncompleteEdgeQueueSize ->
		retract(countOfTotalEdgesInQueue(_)),
		NewCountOfTotalEdgesInQueue is CountOfTotalEdgesInQueue + 1,
		assert(countOfTotalEdgesInQueue(NewCountOfTotalEdgesInQueue)),
		printf("total edges in queue = %w\n",[NewCountOfTotalEdgesInQueue]),
		append([Id],ListOfEdgeIdsInQueue,NewListOfEdgeIdsInQueue),
		retract(listOfEdgeIdsInQueue(_)),
		assert(listOfEdgeIdsInQueue(NewListOfEdgeIdsInQueue)),
		asserta(NewEdge)
	;
		append(RemainingEdgeIds,[SmallestEdgeIdInQueue],ListOfEdgeIdsInQueue),
		append([Id],RemainingEdgeIds,NewListOfEdgeIdsInQueue),
		retract(listOfEdgeIdsInQueue(_)),
		assert(listOfEdgeIdsInQueue(NewListOfEdgeIdsInQueue)),
		printf("queue full, total edges in queue = %w\n",[CountOfTotalEdgesInQueue]),
		printf("queue full, replaced edge = %w\n",[SmallestEdgeIdInQueue]),
		retract(edge(SmallestEdgeIdInQueue,_,_,_,_,_,_,_)),
		asserta(NewEdge)
	).

%DOC
%combineConfidenceFactors need to be delayed when not all input CFs are bound.
%This could happen if input CFs come from yet unobserved effects.
delay   combineConfidenceFactors(CFs,CF)
		if nonground(CFs). 
combineConfidenceFactors([],1.0).
combineConfidenceFactors([CF1|CFs],CF) :-
	combineConfidenceFactors(CFs,CF2),
	CF is CF1 * CF2.
