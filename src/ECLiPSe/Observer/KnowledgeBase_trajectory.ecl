:- compile('KnowledgeBase_utils.ecl').

    
/*==============================================================================
 *
 *  CONTINUITY RULES
 *
 *============================================================================*/

 :- addRule(
	stationaryTrajectory_baseStep,
	<=(	cause(	figureHasTrajectory(	FigureId,
									StationaryTrajectory,
									ElapsedTime1,ElapsedTime2,
									CF,
									originally(Shape1,Color1),
									DrawInstrs,
									base ),
				[[	timestamp(ElapsedTime1),
					figure(FigureId,Position1,Shape1,Color1)],
				 [	timestamp(ElapsedTime2),
				 	figure(FigureId,Position2,Shape2,Color2)]
				]
			),
		[%It's convenient to use Position vars everywhere and define their
		 % format only here.
		 1:compute([Position1 = position(X1,Y1),
		 			Position2 = position(X2,Y2) ]),
		 
		 %Similar convenience for trajectory var. Also note that subparts like
		 % X,Y are now constrained to agree with parts elsewhere.
		 2:compute( StationaryTrajectory
		 				= stationaryTrajectory(originalPosition(X1,Y1)) ),
		 
		 %Ensure frames matching RHS are adjacent.
		 3:compute(twoFramesAreAdjacent(ElapsedTime1,ElapsedTime2,FigureId)),									
		 
		 %Instantiates the Id and observ1 vars, and constrains the observ2 vars
	 	 4:compute(( Constraint = 
	 	 			  figureIsStationary(
	 	 				FigureId,
						observ1(ElapsedTime1,Position1,Shape1,Color1),
						observ2(ElapsedTime2,Position2,Shape2,Color2),
						StationaryTrajectory ),
					 call(Constraint)
				  )),
		 %Generate draw instructions
		 5:compute((RuleLHSWithoutDIWithCFReplaced = figureHasTrajectory(FigureId,
		 												   					StationaryTrajectory,
		 												   					ElapsedTime1,ElapsedTime2,
		 												   					cv,
		 												   					originally(Shape1,Color1)),	
		 			genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime2,
		 								RuleLHSWithoutDIWithCFReplaced,CF,[X1,Y1],[X1,Y1],
		 								stationary,DrawInstrs)
		 		  )),			
		 %A slightly higher initial confidence than used for
		 % linear moving trajectory (0.65).
		 6:compute( CF is 0.7 )
		])).
	
/*------------------------------------------------------------------------------
 * LinearMovingTrajectory encodes magnitudes of force (and speed?) in all
 * relevant directions, plus the most recent position. It also encodes acceleration and
 * list of all positions. 
 * It's represented like this: 
 *  linearMovingTrajectory(lastPosition(X,Y), magnitude(XMagn,YMagn), 
 *                         acceleration(AccelTriplets),PositionList)
 * where XMagn is the magnitude component in the positive-X-axis direction, and
 * AccelTriplets is a list of (XAccel,YAccel,AccelDirection) triplets with each triplet 
 * representing the acceleration between two pairs of velocity magnitudes observed 
 * throughout  the trajectory. The triplets closer to the front of the list correspond 
 * to more recent acceleration observations.
 * The amount of acceleration does not always reflect real acceleration. Below a
 * certain threshold relative to the speed, the acceleration is considered
 * imperceptible to observers and the value would be (0,0,0) to reflect this.
 * The ratio that defines the threshold is configurable in Wayang.properties.
 -----------------------------------------------------------------------------*/

:- addRule(
	linearMovingTrajectory_baseStep,
	<=(	cause(	figureHasTrajectory(FigureId,
									LinearMovingTrajectory,
									ElapsedTime1,ElapsedTime2,
									CF,
									originally(Shape1,Color1),
									DrawInstrs,
									base ),
				[[	timestamp(ElapsedTime1),
					figure(FigureId,Position1,Shape1,Color1)],
				 [	timestamp(ElapsedTime2),
				 	figure(FigureId,Position2,Shape2,Color2)]
				]
			),
		[%It's convenient to use Position vars everywhere and define their
		 % format only here.
		 1:compute([Position1 = position(X1,Y1),
		 			Position2 = position(X2,Y2) ]),
		 
		 %Similar convenience for trajectory var. Also note that subparts like
		 % X,Y are now constrained to agree with parts elsewhere.
		 2:compute( LinearMovingTrajectory =
		 			linearMovingTrajectory(
						lastPosition(X2,Y2),
						magnitude(XMagn,YMagn),
						acceleration([(XAccel,YAccel,AccelDirection)]),
						[(X1,Y1),(X2,Y2)] )),
		 
		 %Ensure frames matching RHS are adjacent.
		 %Constraint 3 is unnecessary since the parser already ensures this
		 /*3:compute(twoFramesAreAdjacent(ElapsedTime1,ElapsedTime2,FigureId)),*/
		 									
		 %Find a previous trajectory ascription from which we can obtain the previous
		 %magnitude. The previous trajectory can either be linear or stationary. It
		 %is also possible that there is no previous trajectory, since it is the start
		 %of the animation, in which case the object should be considered stationary
		 %prior to the current ascription.
		 %Note that findAnyCorroboratingEdge should not be used to find relevant previous
		 %completed linear / stationary trajectory edge, since such an edge would not yet
		 %be created at this stage. Instead, find the frame edge for the frame before 
		 %the frame for ElapsedTime1 and apply linear / stationary constraints on
		 %the two frame contents. Also note that we don't need to consider curved
		 %trajectories since the last pair of observations in a curved trajectory is
		 %also a linear trajectory. 
		 4:compute((
		            (findPreviousFrameElapsedTime(ElapsedTime1,FigureId,ElapsedTime0),
		 			 LHS = [timestamp(ElapsedTime0),
		 			        figure(FigureId,Position0,Shape0,Color0)],
		 			 findAnyCorroboratingEdgeWithCut(_SpanEnd1,_SpanEnd2,LHS,_CF1,
		 			 						  _ParentId,_RHS_ParsedParts),
		 			 (
		 			  (  						   			  
		 			   PrevLinearMovingTrajectory = 
		 					linearMovingTrajectory(
		 						lastPosition(X1,Y1),
		 						magnitude(PrevXMagn,PrevYMagn),
		 						_PrevAcceleration,
		 						_PrevPositionList ),
		 			   figureMovesLinearly(
	 	 						FigureId,
		 						observ1(ElapsedTime0,Position0,Shape0,Color0),
		 						observ2(ElapsedTime1,Position1,Shape1,Color1),
		 						PrevLinearMovingTrajectory )						   
		 			  
		 			  )	
		 		     ;
		 		      (
		 		       Position0 = position(X0,Y0), 
		 		       PrevStationaryTrajectory =
		 		    		stationaryTrajectory(originalPosition(X0,Y0)),
		 			   figureIsStationary(
	 	 				FigureId,
						observ1(ElapsedTime0,Position0,Shape0,Color0),
						observ2(ElapsedTime1,Position1,Shape1,Color1),
						PrevStationaryTrajectory ),
		 			   PrevXMagn = 0.0,
		 			   PrevYMagn = 0.0
		 			  )
		 			 )
		 			)
		 		   ;
		 			( %No previous trajectory, consider stationary.
		 			  PrevXMagn = 0.0,
		 			  PrevYMagn = 0.0
		 			)
		 		  )),
		  
		 %Transpose the previous magnitude values to the direction of the current
		 %trajectory. This seems to be a good approximation of how human observers
		 %would judge acceleration after a change of direction. 
		 5:compute(( PrevSpeedSquared is PrevXMagn ^ 2 + PrevYMagn ^ 2,
		 			 sqrt(PrevSpeedSquared, PrevSpeed),
		 			 %Use delayableDisjunctedCalls/2 to ensure the calls are only
		 			 %done when all the required arguments are ground.
		 			 %delayableDisjunctedCalls/2 was originally written for calls
		 			 %in which there are disjuncts, but will work just as well with
		 			 %other calls.
		 			 %Calculate angle of the current trajectory relative to the +ve
		 			 %X-axis, then transpose the previous magnitude values in the
		 			 %direction specified by the angle of the current trajectory. 
		 			 Constraint =
		 				 (angleBetweenTwoVectors(1,0,XMagn,YMagn,0,0,Angle1,Sign),
		 				  (Sign >= 0 ->
		 				 	 Angle = Angle1
		 				  ;
		 				 	 Angle is 360 - Angle1
		 				  ),
		 				  AngleInRads is Angle * pi / 180,
		 				  TransposedPrevXMagn is PrevSpeed * cos(AngleInRads),
		 				  TransposedPrevYMagn is PrevSpeed * sin(AngleInRads)
		 				 ),
		 			 delayableDisjunctedCalls([XMagn,YMagn],Constraint)  
		 		  )),
		 
		 %Instantiates the Id and observ1 vars, and constrains the observ2 vars
	 	 6:compute( figureMovesLinearly(
	 	 						FigureId,
		 						observ1(ElapsedTime1,Position1,Shape1,Color1),
		 						observ2(ElapsedTime2,Position2,Shape2,Color2),
		 						LinearMovingTrajectory )),
		 
		 %Calculate acceleration
		 7:compute( calculateAcceleration(TransposedPrevXMagn,TransposedPrevYMagn,XMagn,
		 								  YMagn,ElapsedTime1,ElapsedTime2,XAccel,YAccel,AccelDirection) 
		          ),
		 
		 %Generate draw instructions
		 8:compute((RuleLHSWithoutDIWithCFReplaced = figureHasTrajectory(FigureId,
														   					LinearMovingTrajectory,
														   					ElapsedTime1,ElapsedTime2,
														   					cv,
														   					originally(Shape1,Color1)),
		 			genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime2,
		 								RuleLHSWithoutDIWithCFReplaced,CF,[X2,Y2],
		 								[X2,Y2,XMagn,YMagn],linear,DrawInstrs)
		 		  )),
		 						
		 %Any base-step rule for stationary trajectory should probably use a
		 % higher confidence than whatever value is used here.
		 9:compute( CF is 0.65 )
		])).

/*------------------------------------------------------------------------------
 * It's possible to use the same recursive rule for both stationary and linear
 *  moving trajectoryes by using a disjunct in one of the conditions.
 -----------------------------------------------------------------------------*/		
:- addRule(
	trajectory_recursiveStep,
	<=(	cause(	figureHasTrajectory(FigureId,
									Trajectory2,
									ElapsedTime1,ElapsedTime3,
									CF3,
									originally(Shape1,Color1),
									DrawInstrs,
									recursive ),
			[%We list figureHasTrajectory first in the list of effects for
			 % recursive-step rules, before the effect that would match an
			 % input frame, so that recursive-step rules fire less often, and
			 % thus we use less space to store fewer chart parser inferences.
			 figureHasTrajectory(	FigureId,
									Trajectory1,
									ElapsedTime1,ElapsedTime2,
									CF2,
									originally(Shape1,Color1),
									_DrawInstrs1,
									BaseRecursiveOrWiggle ),
								
			 [timestamp(ElapsedTime3),
			  figure(FigureId,Position3,Shape3,Color3) ]
			]
		),
	[%Constrains the observ2 vars
	 % Note that fig2's position must be given as position(X3,Y3) instead of
	 %  as a var, because when we match against the delay head, CLP uses
	 %  pattern-matching instead of unification, so we couldn't bind a var
	 %  and matching would fail for all cases.
	 1:compute( Position3 = position(X3,Y3) ),
	 %We shouldn't extend a trajectory that is inferred from a wiggle. So BaseRecursiveOrWiggle
	 %should not be of type wiggle.
	 2:compute(BaseRecursiveOrWiggle \= wiggle),
	 %Ensure the frame for ElapsedTime2 is adjacent to the frame for ElapsedTime3
	 %Constraint 3 is unnecessary since the parser already ensures this
	 /*3:compute(twoFramesAreAdjacent(ElapsedTime2,ElapsedTime3,FigureId)),*/
	 %If the trajectory from time1 to time2 was stationary, then constrain the
	 % trajectory for time2 to time3 to also be stationary; similarly, if it was
	 % linearMoving during the first span, constrain the second span to have a
	 % trajectory of the same type.
	 %Note that although Trajectory1 and Trajectory2 have the same 
	 % originalPosition, that doesnt mean there has been no movement at all;
	 % instead, it means that any movement has been within the "margin of
	 % variance" permitted for stationary trajectories.
	 4:compute(((	Trajectory1 =
						stationaryTrajectory(	originalPosition(X2,Y2) ),
					Trajectory2 =
						stationaryTrajectory(	originalPosition(X2,Y2) ),
						
					Constraint =
						figureIsStationary(
							FigureId,
							observ1(ElapsedTime2,position(X2,Y2),Shape1,Color1),
							observ2(ElapsedTime3,Position3,      Shape3,Color3),
							Trajectory1 ),
					call(Constraint),
					RuleLHSWithoutDIWithCFReplaced = figureHasTrajectory(FigureId,
														   Trajectory2,
														   ElapsedTime1,ElapsedTime3,
														   cv,
													       originally(Shape1,Color1)),
					genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime3,
										RuleLHSWithoutDIWithCFReplaced,CF3,[X2,Y2],[X2,Y2],
										stationary,DrawInstrs),
					
					%Confidence in stationary trajectory seems like it would
					% start higher than the initial confidence of linear
					% trajectory but then grow more slowly. (Larger growth
					% factors cause slower growth, FYI.)
					ConfidenceGrowthFactor = 0.15
				)
				;
				(	Trajectory1 =
						linearMovingTrajectory(	lastPosition(X2,Y2),
												magnitude(XMagn1,YMagn1),
												acceleration(PrevAccelTriplets),
												PrevPositionList ),
					Trajectory2 =
						linearMovingTrajectory(	lastPosition(X3,Y3),
												magnitude(XMagn2,YMagn2),
												acceleration([(XAccel2,YAccel2,AccelDirection2)|PrevAccelTriplets]),
												PositionList ),
					Position3 = position(X3,Y3),
					delayableDisjunctedCalls([X3,Y3],append(PrevPositionList,[(X3,Y3)],PositionList)),
						
					Constraint =
						figureMovesLinearly(
							FigureId,
							observ1(ElapsedTime2,position(X2,Y2),Shape1,Color1),
							observ2(ElapsedTime3,Position3,      Shape3,Color3),
							Trajectory2 ),
					call(Constraint),
			
					RuleLHSWithoutDIWithCFReplaced = figureHasTrajectory(FigureId,Trajectory2,
																			ElapsedTime1,ElapsedTime3,
																			cv,
																			originally(Shape1,Color1)
														   				),
					genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime3,
										RuleLHSWithoutDIWithCFReplaced,CF3,[X3,Y3],
										[X3,Y3,XMagn2,YMagn2],linear,DrawInstrs),
	 						
					%Require that the movement vector from the previous two
					% observations mostly agrees with the vector from the second
					% and new observations. Previously we compared the XMagns & YMagns separately and checked
					% that they are nearly identical. With the introduction of acceleration/deceleration, this
					% no longer works. We instead measure the angle between the two vectors and constrain them
					% to be close to 0 degrees.
					% magnitudesAreWithinErrorRange(XMagn1,XMagn2),
					% magnitudesAreWithinErrorRange(YMagn1,YMagn2),
					angleBetweenTwoVectorsIsCloseToZero(XMagn1,YMagn1,XMagn2,YMagn2),
					
					%Calculate acceleration
					calculateAcceleration(XMagn1,YMagn1,XMagn2,
		 								  YMagn2,ElapsedTime2,ElapsedTime3,XAccel2,YAccel2,AccelDirection2),
					
					ConfidenceGrowthFactor = 0.1
				))),
	 						
	 5:compute( incrementConfidenceAsymptotically(	CF2,ConfidenceGrowthFactor,
	 												CF3 ))
	])).

/*------------------------------------------------------------------------------
 * The rule below generates linear trajectories from wiggles whose outlines fit
 * accurately enough to lines of best fit. 
 -----------------------------------------------------------------------------*/

 :- addRule(
	linearMovingTrajectory_fromWiggle,
	<=(	cause( figureHasTrajectory(FigureId,
								   LinearMovingTrajectory,
								   ElapsedTime1,ElapsedTime2,
								   CF,
								   originally(Shape1,Color1),
								   DrawInstrs,
								   wiggle ),
			  [wiggle(FigureId,
 	 				  ElapsedTime1,ElapsedTime2,
 	 				  _LatestProjectedCircle,
 	 				  _COBFRc,
 	 				  WigglePositionList,
 	 				  TrajectoryOfBestFit,
 	 				  originally(Shape1,Color1),
 	 				  CF,
 	 				  _DrawInstrs1
 	 				 )
			  ]
		),
	[%The wiggle's trajectory of best fit needs to be linear 
	 1:compute(TrajectoryOfBestFit = 
					linearMovingTrajectory(lastPosition(X1,Y1),
										   magnitude(XMagn,YMagn),
										   acceleration(AccelTriplets),
										   PositionList)
			  ),
	 %To reduce duplicates, check whether a linear trajectory edge of type base/recursive 
	 %for the same figure covering the same time period already exists. If such an
	 %edge exists, do not create an edge.
	 2:compute((findall(CF2,
	 					(findAnyCorroboratingEdge(_SpanEnd1,_SpanEnd2,
	 											  figureHasTrajectory(FigureId,
	 											  					  linearMovingTrajectory(_LastPos2,
	 											  					  						 _Magnitude2,
	 											  					  						 _Accel2,
	 											  					  						 _PositionList2
	 											  					  						),
	 											  					  ElapsedTime1,ElapsedTime2,
	 											  					  CF2,
	 											  					  _Originally2,
	 											  					  _DrawInstrs2,
	 											  					  BaseRecursiveOrWiggle2
	 											  					 ),
	 											  _CF3,_ParentId,_RHS_parsedParts
	 											 ),
	 					 (BaseRecursiveOrWiggle2 = recursive
	 					 ;
	 					  BaseRecursiveOrWiggle2 = base
	 					 )
	 					),
	 					[]
	 				   )
	 		  )), 
	 %Use the linear trajectory of best fit as the linear trajectory
	 3:compute(LinearMovingTrajectory = TrajectoryOfBestFit
	 		  ),
	 %Generate DrawInstrs
	 4:compute((RuleLHSWithoutDIWithCFReplaced = figureHasTrajectory(FigureId,
														   				LinearMovingTrajectory,
														   				ElapsedTime1,ElapsedTime2,
														   				cv,
														   				originally(Shape1,Color1)),
				generatePositionList(FigureId,ElapsedTime1,ElapsedTime2,PositionListForDI),
				genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime2,
									RuleLHSWithoutDIWithCFReplaced,CF,[PositionListForDI],
									[linear,X1,Y1,XMagn,YMagn],trajectoryFromWiggle,DrawInstrs)
	 		  ))	
	])).