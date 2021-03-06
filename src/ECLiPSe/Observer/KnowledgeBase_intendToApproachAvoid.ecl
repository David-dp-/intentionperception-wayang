:- lib(ic).
:- compile('KnowledgeBase_trajectory.ecl').

%DOC - Movement due to an intention to approach or avoid an object.
%Requirements during timespan (ElapsedTime1 to ElapsedTime2):
%1. If the target object is being approached by the moving object, the approacher must be headed 
%   on a collision course with the target object (where Target is treated as stationary;
%   Approacher doesn't anticipate Target's movement). 
%2. If the target object is being avoided by the moving object, the avoider must be headed away
%   from the target object (again, where Target is treated as stationary).
%

:- addRule(
	intendToApproachAvoid_baseStep,
	<=(	cause(	intend(	FigureId,
						ApproachOrAvoid,
						TargetId,
						Trajectory1,
						originally(Shape1,Color1),
						ElapsedTime1,ElapsedTime2,
						CF,
						DrawInstrs,
						base ),  
				[figureHasTrajectory(	FigureId,
										Trajectory1,
										ElapsedTime1,ElapsedTime2,
										CF1,
										originally(Shape1,Color1),
										_DrawInstr2,
										BaseRecursiveOrWiggle ) 
				]
			),
		[1:compute( Trajectory1 = linearMovingTrajectory(
									lastPosition(X2,Y2),
									_Magnitude,
									acceleration(AccelList),_ )),
		 %//TODO Constraint 2 is very strict and the irregularities in animations we use could cause this constraint
		 %       to fail to be fulfilled. Comment out for now.
		 /*2:compute( figureMovesWithConsistentAccelerationProfile(
		 				intendAtPositionOrAvoidApproach,
						AccelList)
				  ),*/
		 %Constraint 3 ensures that the trajectory isn't generated by the trajectory recursive rule. The reason for this is that we 
		 %don't want longer trajectories to trigger the intention base rule, since longer spans should be handled by the intention 
		 %recursive rule. Without this constraint there would be duplicate ascriptions.
		 3:compute( BaseRecursiveOrWiggle \= recursive 
		 		  ),
		 4:compute( regularityFromForce(
									FigureId, Shape1,		 			%input
									Trajectory1, ElapsedTime2,
									TargetId, AttractiveOrRepulsive,	%output
									_ForceMagnitude, CF2 )),
		 5:compute(( AttractiveOrRepulsive = attractive ->
		 				ApproachOrAvoid = approach
		 		   ;
		 		   		ApproachOrAvoid = avoid
		 		  )),
		 %Since we allow trajectories inferred from wiggles, this rule can cover more than 2 frames, so we guard against duplicates
		 %that can be generated either by a duplicate trajectory generated by a duplicate wiggle, or by the recursive rule.
		 %Check whether there's already an existing edge covering the same time period for the same figure, either with a higher CF value,
		 %of the recursive type, or both (Edges that have higher CFs and/or are generated recursively should take priority.) 
 	 	 %The constraint is satisfied if and only if there's no such edge. 
		 6:compute(( Constraint = findall(CF3,
		 								  (findAnyCorroboratingEdge(_SpanEnd1,_SpanEnd2,
		 											  intend(FigureId,
		 											  		 ApproachOrAvoid,
															 TargetId,
															 _Trajectory2,
															 _Originally2,
		 											  		 ElapsedTime1,ElapsedTime2,
		 											  		 CF3,
		 											  		 _DrawInstrs3,
		 											  		 BaseOrRecursive
		 											  		),
		 											  _CF4,_ParentId1,_RHS_parsedParts1
		 											 ),
		 					 			   (
		 					  				%We don't want to compare bounded reals, float/2 will convert the CFs to float values if the
 	 				  		  				%CFs are indeed bounded reals.
 	 				  		  				FloatCF3 is float(CF3),
 	 				  		  				FloatCF is float(CF),
 	 				  		  				FloatCF3 > FloatCF
 	 				  		 			   ;
 	 				  		  				BaseOrRecursive = recursive
 	 				  		 			   )
 	 				  					  ),
 	 				  					  []
 	 				  	  				 ),
 	 				 delayableDisjunctedCalls([CF],Constraint)
 	 			  )),								  		 
		 %Check whether the moving object wiggles from ElapsedTime1 to ElapsedTime2
		 %Wiggling is an added sign of animacy and should increase the confidence 
		 %for the intention ascription.
		 7:compute((BaseRecursiveOrWiggle = wiggle ->
		 				true %//TODO The only reason this contingency condition is present 
		 					 %  is to allow increasing the CF value for the wiggle case.
		 		   ;
		 		   		true	
		 		  )),
		 %Generate DrawInstrs
		 8:compute((RuleLHSWithoutDIWithCFReplaced = intend(	FigureId,
																ApproachOrAvoid,
																TargetId,
																originally(Shape1,Color1),
																ElapsedTime1,ElapsedTime2,
																cv),
					generatePositionList(FigureId,ElapsedTime1,ElapsedTime2,PositionListForDI),
					genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime2,
										RuleLHSWithoutDIWithCFReplaced,CF,[PositionListForDI],
										[ApproachOrAvoid,TargetId],
										intentionToApproachOrAvoid,DrawInstrs)
		 		  )),
		 9:compute( combineConfidenceFactors([CF1,CF2],CF) )
		])).
	
:- addRule(
	intendToApproachAvoid_recursiveStep,
	<=(	cause(	intend(	FigureId,
						ApproachOrAvoid,
						TargetId,
						Trajectory3,
						originally(Shape1,Color1),
						ElapsedTime1,ElapsedTime3,
						CF4,
						DrawInstrs,
						recursive ), 
				[intend( FigureId,
						 ApproachOrAvoid,
						 TargetId,
						 Trajectory1,
						 originally(Shape1,Color1),
						 ElapsedTime1,ElapsedTime2,
						 CF1,
						 _DrawInstrs1,
						 BaseOrRecursive ),
				 figureHasTrajectory(	FigureId,
										Trajectory3,
										ElapsedTime2,ElapsedTime3,
										CF2,
										originally(Shape1,Color1),
										_DrawInstrs2,
										BaseRecursiveOrWiggle ) 
				]
			),
		[1:compute( Trajectory1 = linearMovingTrajectory(
									lastPosition(X2,Y2),
									_Magnitude,
									acceleration(AccelList1),_ )),
		
		 2:compute( Trajectory3 = linearMovingTrajectory(
		 							lastPosition(X3,Y3),
		 							Magnitude3,
		 							acceleration(AccelList2),_ )),
		 %Constraint 3 ensures that the linear trajectory (2nd effect) isn't generated by the trajectory recursive rule. 
		 %The reason for this is that we don't want longer trajectories to trigger the intention recursive rule, 
		 %since there should already be an intention edge with a longer intention component and a shorter 
		 %(i.e. base-rule generated) trajectory component covering the same span from ElapsedTime1 to ElapsedTime3. 
		 %Without this constraint there would be duplicate ascriptions.
		 3:compute(delayableDisjunctedCalls([BaseRecursiveOrWiggle],BaseRecursiveOrWiggle \= recursive)
		 		  ),
		 %//TODO Constraint 4 is very strict and the irregularities in animations we use could cause this constraint
		 %       to fail to be fulfilled. Comment out for now.
		 /*4:compute(( Constraint1 = 
		 				(append(AccelList2,AccelList1,CombinedAccelList),
		 			 	 figureMovesWithConsistentAccelerationProfile(
		 					intendAtPositionOrAvoidApproach,
							CombinedAccelList)
						),
					 delayableDisjunctedCalls(AccelList2,Constraint1)
		 		  )),*/
		 %TargetId and AttractiveOrRepulsive are now part of the input
		 % constraints, due to their role in the exertForceOn/6 child; 
		 % in the base step rule, these vars are unbound going in and 
		 % thus a part of output when they're bound as a side-effect.
		 5:compute(((ApproachOrAvoid = approach ->
		 				AttractiveOrRepulsive = attractive
		 			;
		 				AttractiveOrRepulsive = repulsive
		 			),
		 			Constraint
		 				= regularityFromForce(	FigureId,			%input
												Shape1,
												Trajectory3,
												ElapsedTime3,TargetId,
												AttractiveOrRepulsive,
												_ForceMagnitude,			%output
												CF3 ),					
					call(Constraint)
				  )),
		 %Check whether the moving object wiggles from ElapsedTime2 to ElapsedTime3
		 %Wiggling is an added sign of animacy and should increase the confidence 
		 %for the intention ascription.
		 6:compute((Constraint4 = (BaseRecursiveOrWiggle = wiggle ->
		 							true %//TODO The only reason this contingency condition is present 
		 								 %  is to allow increasing the CF value for the wiggle case.
		 		   				  ;
		 		   					true
		 		   				  ),
		 		   	delayableDisjunctedCalls([BaseRecursiveOrWiggle],Constraint4)
		 		  )),
		 7:compute( combineConfidenceFactors([CF1,CF2,CF3],CF4) ),
		 %Constraint 3 only guards against duplicates caused by trajectories generated by the recursive trajectory rule.
		 %Allowing wiggles could generate more duplicates. We attempt to reduce those duplicates in the following constraints.
		 %Constraint 8 checks whether at least one of the following is true: 1)there exists a duplicate of the component  
		 %intention covering ElapsedTime1 to ElapsedTime2 with a higher CF value, where the component intention and the duplicate 
		 %are of the same type 2)the component intention is of the base type, and there exists a duplicate of the recursive type.
		 %The constraint is satisfied if and only if a duplicate does not exist with either of the conditions satisified.
		 8:compute((Constraint2 = (findall(CF7,
		 								   (findAnyCorroboratingEdge(_SpanEnd3,_SpanEnd4,
		 															 intend(FigureId,
																			ApproachOrAvoid,
																			TargetId,
																			_Trajectory4,
																			_Originally2,
																			ElapsedTime1,ElapsedTime2,
																			CF7,
																			_DrawInstrs3,
																			BaseOrRecursive2
																		   ),
																	 _CF8,_ParentId2,_RHS_parsedParts2
																	),
											(
											 %We don't want to compare bounded reals, float/2 will convert the CFs to float values if the
 	 				  						 %CFs are indeed bounded reals.
 	 				  						 FloatCF7 is float(CF7),
 	 				  						 FloatCF1 is float(CF1),
 	 				  						 FloatCF7 > FloatCF1,
 	 				  						 BaseOrRecursive = BaseOrRecursive2
 	 				  						;
 	 				  						 BaseOrRecursive = base,
 	 				  						 BaseOrRecursive2 = recursive
 	 				  						)
 	 				  					   ),
 	 				  					   []
 	 				  					  )
 	 				  			  ),
 	 				%Delay if the second effect has not been matched, i.e. Trajectory3 is not yet bound.
 	 	 			%This will ensure all duplicates have already been generated.
 	 				delayableDisjunctedCalls([Trajectory3],Constraint2)
 	 			  )),
 	 	 %Constraint 9 checks whether there exists a duplicate of the high level intention covering ElapsedTime1 to ElapsedTime3 that satisfies 2 conditions:
 	 	 %1)it has a higher CF value. 2)it is of the recursive type. The constraint is satisfied if and only if there's no such duplicate. 
 	 	 %While constraint 8 guards against duplicates caused by duplicates of the intention component covering the same time period (ElapsedTime1 to ElapsedTime2),
 	 	 %constraint 9 guards against duplicates of the recursive type formed by an intention component covering a different time period (ElapsedTime1 to ElapsedTime2b, 
 	 	 %where ElapsedTime2b \= ElapsedTime2.) 
 	 	 9:compute((Constraint3 = (findall(CF9,
 	 	 								   (findAnyCorroboratingEdge(_SpanEnd5,_SpanEnd6,
 	 	 								   							 intend(FigureId,
 	 	 								   								    ApproachOrAvoid,
 	 	 								   								    TargetId,
 	 	 								   								    _Trajectory5,
 	 	 								   								    _Originally3,
 	 	 								   								    ElapsedTime1,ElapsedTime3,
 	 	 								   								    CF9,
 	 	 								   								    _DrawInstrs4,
 	 	 								   								    BaseOrRecursive3
 	 	 								   								   ),
 	 	 								   							 _CF10,_ParentId3,_RHS_parsedParts3
 	 	 								   						    ),
 	 	 								   	%We don't want to compare bounded reals, float/2 will convert the CFs to float values if the
 	 				  						%CFs are indeed bounded reals.
 	 				  						FloatCF9 is float(CF9),
 	 				  						FloatCF4 is float(CF4),
 	 				  						FloatCF9 > FloatCF4,
 	 				  						BaseOrRecursive3 = recursive
 	 				  					   ),
 	 				  					   []
 	 				  					  )
 	 				  			  ),
 	 				delayableDisjunctedCalls([CF4],Constraint3) 	
 	 	 		  )),
 	 	 %Generate draw instrs
 	 	 10:compute((RuleLHSWithoutDIWithCFReplaced = intend(	FigureId,
																ApproachOrAvoid,
																TargetId,
																originally(Shape1,Color1),
																ElapsedTime1,ElapsedTime3,
																cv),
					 generatePositionList(FigureId,ElapsedTime1,ElapsedTime3,PositionListForDI),
					 genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime3,
										 RuleLHSWithoutDIWithCFReplaced,CF4,[PositionListForDI],
										 [ApproachOrAvoid,TargetId],
										 intentionToApproachOrAvoid,DrawInstrs)
 	 	 		   ))   
		])).
  	