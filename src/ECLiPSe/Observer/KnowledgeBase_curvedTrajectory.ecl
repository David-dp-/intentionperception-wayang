:- compile('KnowledgeBase_trajectory.ecl').

/*------------------------------------------------------------------------------
 * CurvedTrajectory encodes the last 2 points that define the curve and the
 * center of the circle on whose circumference the last 3 points lie. It also 
 * has elapsed time information for the second observation, which is needed 
 * for recursive step calculations.
 * In addition, it stores a list of all the points in the curve, as well as the circle
 * of best fit for these points. These points and the circle of best fit (COBF) are used by the
 * wiggle rules. Note that the error measure for the circle of best fit (COBFErrorMeasure)
 * is calculated using calculateErrorMeasure4/5, even though the circle of best fit itself was generated
 * using the original error function which is the same as the one found in calculateErrorMeasure/5.
 * The reason is that the new error measure is more easily comparable. Unfortunately we don't have a way
 * of finding the circle of best fit using that error measure.
 * The representation is as follows: 
 *  curvedTrajectory(secondToLastPosition(X2,Y2),
 *  	secondToLastElapsedTime(ElapsedTime2),lastPosition(X3,Y3),
 *		latestProjectedCircle(Xc,Yc,R,DirectionSign),magnitude(XMagn,YMagn),
 *      acceleration(AccelTriplets),PositionList,circleOfBestFit(COBFXc,COBFYc,COBFRc,COBFErrorMeasure))
 * DirectionSign is an indication of where the defining circle is in relation
 * to the curved trajectory. DirectionSign is the output of angleBetweenTwoVectors/8,
 * which is called by figureMovesCurvilinearly/6.
 * We also allow curves with short linear segments. If a linear segment is not the latest observed
 * segment, i.e., if the latest observed segment is a curved segment, the representation would be
 * the same as the one above. If a linear segment is the latest observed segment, the format would then be: 
 *  curvedTrajectory(secondToLastPosition(X2,Y2),
 *		secondToLastElapsedTime(ElapsedTime2),lastPosition(X3,Y3),
 *		linear(Length),previousProjectedCircle(Xc,Yc,R,DirectionSign),magnitude(XMagn,YMagn),
 *		acceleration(AccelTriplets),PositionList,circleOfBestFit(COBFXc,COBFYc,COBFRc,COBFErrorMeasure))
 * The previousProjectedCircle functor contains information about the latest projected
 * circle prior to the linear segment. The linear functor contains the length of the
 * linear segment. Note that a curve cannot consist entirely of a single linear segment.
 * It has to have curved segment(s) as well.
 * AccelTriplets is a list of (XAccel,YAccel,AccelDirection) triplets with each triplet 
 * representing the acceleration between two pairs of velocity magnitudes observed 
 * throughout the trajectory. The triplets closer to the front of the list correspond 
 * to more recent acceleration observations.
 ----------------------------------------------------------------------------*/

:- addRule(
	curvedTrajectory_baseStep,
	<=( cause(	figureHasTrajectory(FigureId,
									CurvedTrajectory,
									ElapsedTime1,ElapsedTime3,
									CF,
									originally(Shape1,Color1),
									DrawInstrs,
									base ),
				[[timestamp(ElapsedTime1),
				  figure(FigureId,Position1,Shape1,Color1)],
				 [timestamp(ElapsedTime2),
				  figure(FigureId,Position2,Shape2,Color2)],
				 [timestamp(ElapsedTime3),
				  figure(FigureId,Position3,Shape3,Color3)]
				]
			 ),
		[1:compute([Position1 = position(X1,Y1),
				    Position2 = position(X2,Y2),
				    Position3 = position(X3,Y3)]),
		 %Ensure the frames matching the RHS are adjacent
		 %Constraint 2 is unnecessary since the parser already ensures this
		 /*2:compute((twoFramesAreAdjacent(ElapsedTime1,ElapsedTime2,FigureId),
		 			twoFramesAreAdjacent(ElapsedTime2,ElapsedTime3,FigureId)
		 		  )),*/
		 %Construct list of all positions
		 3:compute(PositionList = [(X1,Y1),(X2,Y2),(X3,Y3)]),
		 %Calculate circle of best fit from the position list
		 4:compute((Constraint0 = 
		 				(findCircleOfBestFit(PositionList,COBFXc,COBFYc,COBFRc,_COBFErrorMeasure1),
		 			     %replace the error measure with an error measure that is more easily comparable
		 			     %which can be calculated using calculateErrorMeasure4/5
		 			     calculateErrorMeasure4(PositionList,COBFXc,COBFYc,COBFRc,COBFErrorMeasure),
		 			     CircleOfBestFit = circleOfBestFit(COBFXc,COBFYc,COBFRc,COBFErrorMeasure)
		 		    	),
		 		    delayableDisjunctedCalls(PositionList,Constraint0)
		 		  )),
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
		 5:compute((
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
		 						_PrevLinearTrajectoryPositionList ),
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
		 6:compute(( PrevSpeedSquared is PrevXMagn ^ 2 + PrevYMagn ^ 2,
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
		 				 (angleBetweenTwoVectors(1,0,XMagn0,YMagn0,0,0,Angle1,Sign),
		 				  (Sign >= 0 ->
		 				 	 Angle = Angle1
		 				  ;
		 				 	 Angle is 360 - Angle1
		 				  ),
		 				  AngleInRads is Angle * pi / 180,
		 				  TransposedPrevXMagn is PrevSpeed * cos(AngleInRads),
		 				  TransposedPrevYMagn is PrevSpeed * sin(AngleInRads)
		 				 ),
		 			 delayableDisjunctedCalls([XMagn0,YMagn0],Constraint)  
		 		  )),
		 %Calculate the acceleration between (PrevXMagn,PrevYMagn) & (XMagn0,YMagn0).
		 7:compute(( Constraint2 = 
		 				(XMagn0 is (X2 - X1) / (ElapsedTime2 - ElapsedTime1),
		 				 YMagn0 is (Y2 - Y1) / (ElapsedTime2 - ElapsedTime1)
		 				),
		 			 delayableDisjunctedCalls([X2,Y2],Constraint2),
		 			 calculateAcceleration(TransposedPrevXMagn,TransposedPrevYMagn,
		 			 	XMagn0,YMagn0,ElapsedTime1,ElapsedTime2,XAccel0,YAccel0,AccelDirection0)
		 		  )),
		 		  
		 8:compute((DisjunctedCalls = 
		 				(CurvedTrajectory =
		 						 curvedTrajectory(secondToLastPosition(X2,Y2),
		 			 					secondToLastElapsedTime(ElapsedTime2),
		 			 					lastPosition(X3,Y3),
		 			 					latestProjectedCircle(Xc,Yc,R,DirectionSign),
		 			 					magnitude(XMagn,YMagn),
      									acceleration([(XAccel,YAccel,AccelDirection)|[(XAccel0,YAccel0,AccelDirection0)]]),
      									PositionList,CircleOfBestFit),
		 				 figureMovesCurvilinearly(
		 						FigureId,
				  	  			observ1(ElapsedTime1,Position1,Shape1,Color1),
				  	  			observ2(ElapsedTime2,Position2,Shape2,Color2),
				  	  			observ3(ElapsedTime3,Position3,Shape3,Color3),
				  	  			CurvedTrajectory,
				  	  			CF)
		 		   		),
		 		    delayableDisjunctedCalls([X1,Y1,X2,Y2,X3,Y3],
		 		   		DisjunctedCalls)	
		 		   )
		 		  ),
		 %Generate draw instrs
		 9:compute((RuleLHSWithoutDIWithCFReplaced = figureHasTrajectory(FigureId,
																			CurvedTrajectory,
																			ElapsedTime1,ElapsedTime3,
																			cv,
																			originally(Shape1,Color1)
																		),
					genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime3,
										RuleLHSWithoutDIWithCFReplaced,CF,[X3,Y3,COBFXc,COBFYc,COBFRc],
										[X3,Y3,XMagn,YMagn,COBFXc,COBFYc,COBFRc,COBFErrorMeasure,DirectionSign],
										curved,DrawInstrs)
				  ))
		])).

/*------------------------------------------------------------------------------
 * The recursive rule can extend either a curved trajectory with a curvy last
 * segment, a curved trajectory with a linear last segment, or a linear trajectory.
 * To extend a linear trajectory, the next observed position must form a curve
 * with the linear trajectory.
 -----------------------------------------------------------------------------*/
:- addRule(
	 curvedTrajectory_recursiveStep,
	 <=( cause(	figureHasTrajectory(FigureId,
									CurvedTrajectory2,
									ElapsedTime1,ElapsedTime4,
									CF4,
									originally(Shape1,Color1),
									DrawInstrs,
									recursive ),
		 		[figureHasTrajectory(FigureId,
									Trajectory1,
									ElapsedTime1,ElapsedTime3,
									CF,
									originally(Shape1,Color1),
									_DrawInstrs1,
									BaseRecursiveOrWiggle ),
				 [timestamp(ElapsedTime4),
			  	  figure(FigureId,Position4,Shape2,Color2) ]
			  	]
			  ),
		 [%Construct list of all positions
		  1:compute(((Trajectory1 = curvedTrajectory(_,_,_,_,_,_,PrevPositionList,_)
		  			 ;
		  			  Trajectory1 = curvedTrajectory(_,_,_,_,_,_,_,PrevPositionList,_)
		  			 ;
		  			  Trajectory1 = linearMovingTrajectory(_,_,_,PrevPositionList)
		  			 ),
		  			 Position4 = position(X4,Y4),
		  			 append(PrevPositionList,[(X4,Y4)],PositionList)
		           )),
		  %Ensure ElapsedTime3 & ElapsedTime4 belong to 2 adjacent frames
		  %Constraint 2 is unnecessary since the parser already ensures this
		  /*2:compute(twoFramesAreAdjacent(ElapsedTime3,ElapsedTime4,FigureId)),*/
		  %We shouldn't extend a curved trajectory that is inferred from a wiggle. So BaseRecursiveOrWiggle
		  %should not be of type wiggle.
		  3:compute(BaseRecursiveOrWiggle \= wiggle),
		  %Calculate circle of best fit from the position list
		  4:compute((Constraint0 = 
		 				(findCircleOfBestFit(PositionList,COBFXc,COBFYc,COBFRc,_COBFErrorMeasure1),
		 				 %replace the error measure with an error measure that is more easily comparable
		 			     %which can be calculated using calculateErrorMeasure4/5
		 			     calculateErrorMeasure4(PositionList,COBFXc,COBFYc,COBFRc,COBFErrorMeasure),
		 			     CircleOfBestFit = circleOfBestFit(COBFXc,COBFYc,COBFRc,COBFErrorMeasure)
		 		    	),
		 		     delayableDisjunctedCalls(PositionList,Constraint0)
		 		   )),
		  5:compute((%This disjunct handles the case where the last observed
		 			 %points in the curve are curvy, i.e. non-linear.
		 			 Trajectory1 =
		 			 	curvedTrajectory(secondToLastPosition(X2,Y2),
		 			 					secondToLastElapsedTime(ElapsedTime2),
		 			 					lastPosition(X3,Y3),
		 			 					latestProjectedCircle(Xc,Yc,R,DirectionSign),
		 			 					magnitude(PrevXMagn,PrevYMagn),
		 			 					acceleration(PrevAccelTriplets),
		 			 					PrevPositionList,_PrevCircleOfBestFit),
		  			 Position4 = position(X4,Y4),
		  			 %If the last observed points are non-linear, we allow
		  			 %the current observed point, along with the last 2 points,
		  			 %to either form a curved / linear segment.
		  			 DisjunctedCalls =
		  			 	(CurvedTrajectory2 =
		  					curvedTrajectory(secondToLastPosition(X3,Y3),
		  								secondToLastElapsedTime(ElapsedTime3),
		  								lastPosition(X4,Y4),
		  								latestProjectedCircle(Xc1,Yc1,R1,DirectionSign1),
		  								magnitude(XMagn,YMagn),
		  								acceleration([(XAccel,YAccel,AccelDirection)|PrevAccelTriplets]),
		  								PositionList,CircleOfBestFit), 
					 	 figureMovesCurvilinearly(
		  				 		FigureId,
		  				 		observ1(ElapsedTime2,position(X2,Y2),Shape1,Color1),
		  						observ2(ElapsedTime3,position(X3,Y3),Shape1,Color1),
		  				 		observ3(ElapsedTime4,Position4,Shape2,Color2),
		  				 		CurvedTrajectory2,
		  				 		CF2),
		  			 	 euclideanDistance(Xc,Yc,Xc1,Yc1,CenterDistance),
		              	 %CF3 depends on the distance between the center of
		  			  	 %the circle which defines Trajectory1 and the
		  			  	 %center of the circle which defines CurvedTrajectory2.
		  			  	 %As the distance grows, CF3 drops according to a bell
		  			  	 %curve function.
		  			  	 Mu = 0, %ideally distance should be 0
		  			  	 Sigma = 10, %CF3 will be very low for distance >= 30 
		  			  	 bellCurve(mu(Mu),sigma(Sigma),CenterDistance,CF3),
		  			  	 %Constrain the circle which defines CurvedTrajectory2 to be on the same side as the circle
		  			  	 %which defines Trajectory1. This would constrain curves
 						 %to be more regularly shaped without change of direction and "M" shaped kinks.
		  			  	 DirectionSign1 = DirectionSign,
		  			  	 DirectionSign2 = DirectionSign1, %For passing to genDrawInstructions
		  			  	 !
		  			 	;
		  			 	 CurvedTrajectory2 =
		  			 	 	curvedTrajectory(secondToLastPosition(X3,Y3),
		  			 	 				secondToLastElapsedTime(ElapsedTime3),
		  			 	 				lastPosition(X4,Y4),
		  			 	 				linear(Length),
		             					previousProjectedCircle(Xc,Yc,R,DirectionSign),
		             					magnitude(XMagn,YMagn),
		             					acceleration([(XAccel,YAccel,AccelDirection)|PrevAccelTriplets]),
		             					PositionList,CircleOfBestFit),
		             	 DirectionSign2 = DirectionSign, %For passing to genDrawInstructions
		             	 LinearTrajectory1 = linearMovingTrajectory(	
		 											lastPosition(X3,Y3),
													magnitude(XMagn0,YMagn0),
													_PrevAcceleration,_),
						 LinearTrajectory2 = linearMovingTrajectory(	
		 											lastPosition(X4,Y4),
													magnitude(XMagn,YMagn),
													_CurrAcceleration,_),
						 figureMovesLinearly(
								FigureId,
								observ1(ElapsedTime2,position(X2,Y2),Shape1,Color1),
								observ2(ElapsedTime3,position(X3,Y3),Shape1,Color1),
								LinearTrajectory1 ),
						 figureMovesLinearly(
								FigureId,
								observ1(ElapsedTime3,position(X3,Y3),Shape1,Color1),
								observ2(ElapsedTime4,Position4,Shape2,Color2),
								LinearTrajectory2 ), 
						 angleBetweenTwoVectorsIsCloseToZero(XMagn0,YMagn0,XMagn,YMagn),
						 
						 %Calculate acceleration
						 calculateAcceleration(XMagn0,YMagn0,XMagn,YMagn,ElapsedTime3,
		 								  	   ElapsedTime4,XAccel,YAccel,AccelDirection),
		 				 
						 euclideanDistance(X3,Y3,X4,Y4,Length),
						 CF2 is 0.8, %this value corresponds to the max value
							 	     %that figureMovesCurvilinearly can give.
							  	     %This value might change in the future.
						 CF3 is 1.0  %for the curved case, CF3 is derived from
						 			 %the distance between the last 2 projected
						 			 %circles. There's no circle to compare so
						 			 %just give a dummy value. This value might
						 			 %change in the future
						),
					 delayableDisjunctedCalls([X4,Y4],DisjunctedCalls)
                    ;
                     %This disjunct handles the case where the last observed
		 			 %points in the curve are linear. We allow the linear segment
		 			 %to be extended by the current point if the resulting length
		 			 %does not exceed a certain threshold. Alternatively a non-
		 			 %linear segment could be formed.
                     Trajectory1 =
                     	curvedTrajectory(secondToLastPosition(X2,Y2),
                     					secondToLastElapsedTime(ElapsedTime2),
                     					lastPosition(X3,Y3),
                     					linear(Length),
                     					PreviousProjectedCircle,
                     					magnitude(PrevXMagn,PrevYMagn),
                     					acceleration(PrevAccelTriplets),
                     					PrevPositionList,_PrevCircleOfBestFit),
                     Position4 = position(X4,Y4),
                     DisjunctedCalls =
                     	(CurvedTrajectory2 =
		  					curvedTrajectory(secondToLastPosition(X3,Y3),
		  								secondToLastElapsedTime(ElapsedTime3),
		  								lastPosition(X4,Y4),
		  								latestProjectedCircle(Xc1,Yc1,R1,DirectionSign1),
		  								magnitude(XMagn,YMagn),
		  								acceleration([(XAccel,YAccel,AccelDirection)|PrevAccelTriplets]),
		  								PositionList,CircleOfBestFit),
					 	 figureMovesCurvilinearly(
		  				 		FigureId,
		  				 		observ1(ElapsedTime2,position(X2,Y2),Shape1,Color1),
		  						observ2(ElapsedTime3,position(X3,Y3),Shape1,Color1),
		  				 		observ3(ElapsedTime4,Position4,Shape2,Color2),
		  				 		CurvedTrajectory2,
		  				 		CF2),
		  			 	 PreviousProjectedCircle = previousProjectedCircle(Xc,Yc,R,DirectionSign),
		  			  	 euclideanDistance(Xc,Yc,Xc1,Yc1,CenterDistance),
		              	 %CF3 depends on the distance between the center of
		  		  	  	 %the circle which defines Trajectory1 and the
		  		  	  	 %center of the circle which defines CurvedTrajectory2.
		  		  	  	 %As the distance grows, CF3 drops according to a bell
				  	  	 %curve function.
	  			  	  	 Mu = 0, %ideally distance should be 0		  			  	 
	  			  	  	 Sigma = 10, %CF3 will be very low for distance >= 30 
				  	  	 bellCurve(mu(Mu),sigma(Sigma),CenterDistance,CF3),
				  	  	 %Constrain the circle which defines CurvedTrajectory2 to be on the same side as the circle
		  			  	 %which defines Trajectory1. This would constrain curves
 						 %to be more regularly shaped without change of direction and "M" shaped kinks.
		  			  	 DirectionSign1 = DirectionSign,
		  			  	 DirectionSign2 = DirectionSign1, %For passing to genDrawInstructions
				  	 	 !
				  	 	;
				  	 	 CurvedTrajectory2 = 
				  	 	 	curvedTrajectory(secondToLastPosition(X3,Y3),
		  								secondToLastElapsedTime(ElapsedTime3),
		  								lastPosition(X4,Y4),
		  								linear(NewLength),
		  								PreviousProjectedCircle,
		  								magnitude(XMagn,YMagn),
		  								acceleration([(XAccel,YAccel,AccelDirection)|PrevAccelTriplets]),
		  								PositionList,CircleOfBestFit),
		  				 PreviousProjectedCircle = previousProjectedCircle(_,_,_,DirectionSign2), %For passing to genDrawInstructions
		  				 euclideanDistance(X3,Y3,X4,Y4,AdditionalLength),
		  				 NewLength is Length + AdditionalLength,
		  				 setting(maxLinearSegmentLengthForCurvedTrajectory(MaxLinearSegmentLengthForCurvedTrajectory)),
		  				 NewLength $=< MaxLinearSegmentLengthForCurvedTrajectory, 
		  				 LinearTrajectory1 = linearMovingTrajectory(	
		 											lastPosition(X3,Y3),
													magnitude(XMagn0,YMagn0),
													_PrevAcceleration,_ ),
						 LinearTrajectory2 = linearMovingTrajectory(	
		 											lastPosition(X4,Y4),
													magnitude(XMagn,YMagn),
													_CurrAcceleration,_ ),
						 figureMovesLinearly(
								FigureId,
								observ1(ElapsedTime2,position(X2,Y2),Shape1,Color1),
								observ2(ElapsedTime3,position(X3,Y3),Shape1,Color1),
								LinearTrajectory1 ),
						 figureMovesLinearly(
								FigureId,
								observ1(ElapsedTime3,position(X3,Y3),Shape1,Color1),
								observ2(ElapsedTime4,Position4,Shape2,Color2),
								LinearTrajectory2 ), 
						 angleBetweenTwoVectorsIsCloseToZero(XMagn0,YMagn0,XMagn,YMagn),
						 
						 %Calculate acceleration
						 calculateAcceleration(XMagn0,YMagn0,XMagn,YMagn,ElapsedTime3,
		 								  	   ElapsedTime4,XAccel,YAccel,AccelDirection),
						 
				  	 	 CF2 is 0.8, %this value corresponds to the max value
							 	     %that figureMovesCurvilinearly can give.
							  	     %This value might change in the future.
						 CF3 is 1.0  %for the curved case, CF3 is derived from
						 			 %the distance between the last 2 projected
						 			 %circles. There's no circle to compare so
						 			 %just give a dummy value. This value might
						 			 %change in the future
						),
						delayableDisjunctedCalls([X4,Y4],DisjunctedCalls)
		  			;
		  			 %This disjunct handles the case where the trajectory being extended
		  			 %is linear. We need to check that the length is shorter than the 
		  			 %threshold for a linear segment to be considered part of a curve
		  			 %The latest observed position needs to form a curve with the linear
		  			 %trajectory
		  			 Trajectory1 =
		  			 	linearMovingTrajectory(lastPosition(X3,Y3),
		  			 						   magnitude(PrevXMagn,PrevYMagn),
                     						   acceleration(PrevAccelTriplets),
                     						   PrevPositionList),
                     PrevPositionList = [(X1,Y1)|_],
                     append(PrevPositionList1,[(X3,Y3)],PrevPositionList),
                     append(_,[(X2,Y2)],PrevPositionList1),
                     euclideanDistance(X1,Y1,X3,Y3,Length),
                     setting(maxLinearSegmentLengthForCurvedTrajectory(MaxLinearSegmentLengthForCurvedTrajectory)),
                     Length =< MaxLinearSegmentLengthForCurvedTrajectory, %upper threshold
                     %Don't extend a linear trajectory produced by the base linear trajectory rule since this will already be
                     %extended by the curved trajectory base rule
                     BaseRecursiveOrWiggle \= base,
                     CurvedTrajectory2 =
		  					curvedTrajectory(secondToLastPosition(X3,Y3),
		  								secondToLastElapsedTime(ElapsedTime3),
		  								lastPosition(X4,Y4),
		  								latestProjectedCircle(Xc1,Yc1,R1,DirectionSign1),
		  								magnitude(XMagn,YMagn),
		  								acceleration([(XAccel,YAccel,AccelDirection)|PrevAccelTriplets]),
		  								PositionList,CircleOfBestFit),
		  			 DirectionSign2 = DirectionSign1, %For passing to genDrawInstructions
					 %Find ElapsedTime2
					 findPreviousFrameElapsedTime(ElapsedTime3,FigureId,ElapsedTime2),
					 figureMovesCurvilinearly(
		  				 		FigureId,
		  				 		observ1(ElapsedTime2,position(X2,Y2),Shape1,Color1),
		  						observ2(ElapsedTime3,position(X3,Y3),Shape1,Color1),
		  				 		observ3(ElapsedTime4,Position4,Shape2,Color2),
		  				 		CurvedTrajectory2,
		  				 		CF2),
		  			 CF3 is 1.0	  
                    )
                   ),
           %Generate draw instrs
           6:compute((RuleLHSWithoutDIWithCFReplaced = figureHasTrajectory(FigureId,
																			CurvedTrajectory2,
																			ElapsedTime1,ElapsedTime4,
																			cv,
																			originally(Shape1,Color1)),
					  genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime4,
					  					  RuleLHSWithoutDIWithCFReplaced,CF4,[X4,Y4,COBFXc,COBFYc,COBFRc],
					  					  [X4,Y4,XMagn,YMagn,COBFXc,COBFYc,COBFRc,COBFErrorMeasure,DirectionSign2],
					  					  curved,DrawInstrs)
           			)),
           7:compute(delayableMin([CF,CF2,CF3],CF4))	  									
		 ])).
		 
/*------------------------------------------------------------------------------
 * The rule below generates curved trajectories from wiggles whose outlines fit
 * accurately enough to curves of best fit. 
 -----------------------------------------------------------------------------*/
 
 :- addRule(
	curvedTrajectory_fromWiggle,
	<=(	cause( figureHasTrajectory(FigureId,
								   CurvedTrajectory,
								   ElapsedTime1,ElapsedTime3,
								   CF,
								   originally(Shape1,Color1),
								   DrawInstrs,
								   wiggle ), 
			  [wiggle(FigureId,
 	 				  ElapsedTime1,ElapsedTime3,
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
	[%The wiggle's trajectory of best fit needs to be curved 
	 1:compute(TrajectoryOfBestFit = 
					curvedTrajectory(secondToLastPosition(X2,Y2),
	                     			 secondToLastElapsedTime(ElapsedTime2),lastPosition(X3,Y3),
	                     			 latestProjectedCircle(Xc,Yc,Rc,DirectionSign),
	                     			 magnitude(XMagn,YMagn),
	                     			 acceleration(AccelTriplets),PositionList,CircleOfBestFit)
			  ),
	 %Use the curved trajectory of best fit as the curved trajectory
	 2:compute(CurvedTrajectory = TrajectoryOfBestFit
	 		  ),
	 %Generate DrawInstrs
	 3:compute((RuleLHSWithoutDIWithCFReplaced = figureHasTrajectory(FigureId,
								  									 	CurvedTrajectory,
								   										ElapsedTime1,ElapsedTime3,
								   										cv,
								  										originally(Shape1,Color1)
								  									),
				generatePositionList(FigureId,ElapsedTime1,ElapsedTime3,PositionListForDI),
				genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime3,
									RuleLHSWithoutDIWithCFReplaced,CF,[PositionListForDI],
									[curved,X3,Y3,XMagn,YMagn],
									trajectoryFromWiggle,DrawInstrs)
	 		  ))
	])).
