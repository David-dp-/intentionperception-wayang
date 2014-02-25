:- lib(ic).
:- compile('KnowledgeBase_trajectory.ecl').

%//TODO Add rules for "collided/propelled/impetus" physical cause-only
%		explanation, which should predict continually straight movement unless
%		a collision occurs.
%//TODO Add rules for repulsion where the target object approaches the repulsor
%		and decelerates, and for attraction where the target object moves away
%		from the attractor and decelerates.


%DOC - Movement due to an attractive or repulsive physical force
%Requirements during timespan (ElapsedTime1 to ElapsedTime2):
%1. If Target is exerting an attractive force, Approacher must be headed on a
%   collision course with Target (where Target is treated as stationary;
%   Approacher doesn't anticipate Target's movement). This includes the general
%   case where Approacher is already in contact with Target.
%   NB: If an Approacher is caught somewhere, this rule won't be able to infer
%    that it's under a force but caught.
%2. If Target is exerting a repulsive force, Approacher must be headed away
%   from Target (again, where Target is treated as stationary).
%   NB: Again, if an Approacher is caught somewhere, this rule won't be able to
%    infer that it's under a force but caught.
%
% If one obj is seen to approach another, and then leave it, at best these
%  rules would recognize the approach span and the repulsed span but not
%  connect those spans. A nonintentional system that behaved that way would
%  have to use something exotic like an electromagnet for the target or
%  approacher, where its polarity switched at the moment the trajectory changed.
%
% Should movement show acceleration or deceleration? (It seems like our
%  perceptual system would expect acc/dec, but this wasn't known to science
%  until Galileo; even Descartes, who defined laws of motion shortly before
%  Galileo, expected a dropped obj to follow a constant speed (due to gravity)
%  so perhaps our builtin expectation is the same and none of us perceive acc
%  natively.) Update: the current rule imposes a (near) constant acceleration constraint. 
%
% Should *target*'s trajectory be affected by presence of exertedUpon obj?
%  Newton's law of action and reaction would say yes.
%

:- addRule(
	exertForceOn_baseStep,
	<=(	cause(	exertForceOn(	TargetId,
								AttractiveOrRepulsive,
								ForceMagnitude,
								ExertedUponId,
								Trajectory1,
								originally(Shape1,Color1),
								ElapsedTime1,ElapsedTime2,
								CF3,
								DrawInstrs ), 
				[figureHasTrajectory(	ExertedUponId,
										Trajectory1,
										ElapsedTime1,ElapsedTime2,
										CF1,
										originally(Shape1,Color1),
										_DrawInstr2,
										base ) %we want to match edges generated by the base rule to avoid duplicates
				]
			),
		[1:compute( Trajectory1 = linearMovingTrajectory(
									lastPosition(X2,Y2),
									_Magnitude,
									acceleration(AccelList),
									_PositionList )),
		 %//TODO Constraint 2 is very strict and the irregularities in animations we use could cause this constraint
		 %       to fail to be fulfilled. Comment out for now.
		 /*2:compute( figureMovesWithConsistentAccelerationProfile(
		 				attractiveRepulsiveOrAttractiveRepulsiveCombined,
						AccelList)
				  ),*/ 
		 3:compute( regularityFromForce(
									ExertedUponId, Shape1,		 		%input
									Trajectory1, ElapsedTime2,
									TargetId, AttractiveOrRepulsive,	%output
									ForceMagnitude, CF2 )),
		 %Generate DrawInstrs
		 4:compute((RuleLHSWithoutDIWithCFReplaced = exertForceOn(TargetId,
																	AttractiveOrRepulsive,
																	ForceMagnitude,
																	ExertedUponId,
																	originally(Shape1,Color1),
																	ElapsedTime1,ElapsedTime2,
																	cv),
					generatePositionList(ExertedUponId,ElapsedTime1,ElapsedTime2,PositionListForDI),
					genDrawInstructions(ExertedUponId,Shape1,Color1,ElapsedTime1,ElapsedTime2,
										RuleLHSWithoutDIWithCFReplaced,CF3,[PositionListForDI],
										[AttractiveOrRepulsive,ForceMagnitude,TargetId],
										singleForce,DrawInstrs)
		 		  )),
		 5:compute( combineConfidenceFactors([CF1,CF2],CF3) )
		])).
	
:- addRule(
	exertForceOn_recursiveStep,
	<=(	cause(	exertForceOn(	TargetId,
								AttractiveOrRepulsive,
								ForceMagnitude,
								ExertedUponId,
								Trajectory3,
								originally(Shape1,Color1),
								ElapsedTime1,ElapsedTime3,
								CF4,
								DrawInstrs ),
				[exertForceOn(	TargetId,
								AttractiveOrRepulsive,
								ForceMagnitude1,
								ExertedUponId,
								Trajectory1,
								originally(Shape1,Color1),
								ElapsedTime1,ElapsedTime2,
								CF1,
								_DrawInstrs1 ),
				 figureHasTrajectory(	ExertedUponId,
										Trajectory3,
										ElapsedTime2,ElapsedTime3,
										CF2,
										originally(Shape1,Color1),
										_DrawInstrs2,
										base ) %we want to match edges generated by the base rule to avoid duplicates
				]
			),
		[1:compute( Trajectory1 = linearMovingTrajectory(
									lastPosition(X2,Y2),
									_Magnitude,
									acceleration(AccelList1),
									_PositionList1 )),
		
		 2:compute( Trajectory3 = linearMovingTrajectory(
		 							lastPosition(X3,Y3),
		 							Magnitude3,
		 							acceleration(AccelList2),
		 							_PositionList2 )),
		 %//TODO Constraint 3 is very strict and the irregularities in animations we use could cause this constraint
		 %       to fail to be fulfilled. Comment out for now.
		 /*3:compute(( Constraint1 = 
		 				(append(AccelList2,AccelList1,CombinedAccelList),
		 			 	 figureMovesWithConsistentAccelerationProfile(
		 					attractiveRepulsiveOrAttractiveRepulsiveCombined,
							CombinedAccelList)
						),
					 delayableDisjunctedCalls(AccelList2,Constraint1)
		 		  )),*/
		 %TargetId and AttractiveOrRepulsive are now part of the input
		 % constraints, due to their role in the exertForceOn/6 child; 
		 % in the base step rule, these vars are unbound going in and 
		 % thus a part of output when they're bound as a side-effect.
		 % Note that ForceMagnitude is not required to be equal to 
		 % ForceMagnitude1, because there might be a minute difference
		 % as a result of slightly different accelerations. 
		 4:compute((Constraint
		 				= regularityFromForce(	ExertedUponId,			%input
												Shape1,
												Trajectory3,
												ElapsedTime3,TargetId,
												AttractiveOrRepulsive,
												ForceMagnitude,			%output
												CF3 ),					
					call(Constraint),
					RuleLHSWithoutDIWithCFReplaced = exertForceOn(TargetId,
																	AttractiveOrRepulsive,
																	ForceMagnitude,
																	ExertedUponId,
																	originally(Shape1,Color1),
																	ElapsedTime1,ElapsedTime3,
																	cv),
					generatePositionList(ExertedUponId,ElapsedTime1,ElapsedTime3,PositionListForDI),
					genDrawInstructions(ExertedUponId,Shape1,Color1,ElapsedTime1,ElapsedTime3,
										RuleLHSWithoutDIWithCFReplaced,CF4,[PositionListForDI],
										[AttractiveOrRepulsive,ForceMagnitude,TargetId],
										singleForce,DrawInstrs)
				  )),
		 %Check that the exerted upon object does not wiggle from ElapsedTime1 to ElapsedTime2
		 %Wiggling would suggest a different cause for the movement
		 %Only check when ElapsedTime3 is bound, since by then we're sure that if there is a wiggle
		 %edge it would have been generated
		 5:compute((LHS1 = wiggle(ExertedUponId,
		 							ElapsedTime1,ElapsedTime2,
		 							_LatestProjectedCircle,
		 							_COBFRc,
		 							_WigglePositionList,
 	 				   				_TrajectoryOfBestFit,
 	 				   				_Originally,
 	 				   				_CF5,
 	 				   				_DrawInstrs3
 	 				   			 ),
 	 				delayableDisjunctedCalls([ElapsedTime3],
 	 										 findall(LHS1,
 	 												 findAnyCorroboratingEdgeWithCut(_SpanEnd1,_SpanEnd2,LHS1,_CF6,_ParentId1,_RHS_parsedParts1),
 	 												 []
 	 					   							)
 	 					   					)
		 		  )),
		 6:compute( combineConfidenceFactors([CF1,CF2,CF3],CF4) )
		])).
  	