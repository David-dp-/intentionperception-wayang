:- lib(ic).
:- compile('KnowledgeBase_curvedTrajectory.ecl').
:- compile('KnowledgeBase_trajectory.ecl').

%DOC
%Curved movement due to a combination of 2 intentions. The first 
%intention is to approach the object we will refer to as the approached object.
%The second intention is to avoid the object we will refer to as the threat
%object. The two intentions exist at the same time throughout the movement.
%The threat object is located underneath the trajectory, while the approached
%object is located near the end of the curved trajectory. The curve should be 
%pointing away from the threat object. These rules correspond to R8, which is  
%the intention version of R7, in the manuscript.
%
:- addRule(
	intendToAvoidAndApproach_baseStep,
	<=( cause(conjunction([ intend(	FigureId,
									avoid,
									ThreatObjectId,
									CurvedTrajectory,
									noLinearSegment,
									originally(Shape1,Color1),
									ElapsedTime1,ElapsedTime3,
									CF,
									DrawInstrs ),
						    intend(	FigureId,
									approach,
									ApproachedObjectId,
									CurvedTrajectory,
									noLinearSegment,
									originally(Shape1,Color1),
									ElapsedTime1,ElapsedTime3,
									CF,
									[] ) %Draw instrs in first conjunct
			  			  ]),
			  [figureHasTrajectory(	FigureId,
			  						CurvedTrajectory,
			  						ElapsedTime1,ElapsedTime3,
			  						CF1,
			  						originally(Shape1,Color1),
			  						_DrawInstrs,
			  						BaseRecursiveOrWiggle )
			  ]
			 ),
		[1:compute(( %We only consider curved trajectories that do not end with a linear segment,
					 %since intendToAvoidAndApproach_recursiveStep already handles linear segments
					 CurvedTrajectory = 
						curvedTrajectory(secondToLastPosition(X2,Y2),
									secondToLastElapsedTime(ElapsedTime2),
									lastPosition(X3,Y3),
									latestProjectedCircle(Xc,Yc,R,DirectionSign),
									magnitude(XMagn,YMagn),
									acceleration(AccelTriplets),
									PositionList,
									circleOfBestFit(COBFXc,COBFYc,COBFRc,COBFErrorMeasure)),
					 %Check that COBFErrorMeasure is sufficiently small
					 setting(maxAllowableErrorForCircleOfBestFitPerPositionOnAverage(
					 	MaxAllowableErrorForCircleOfBestFitPerPositionOnAverage)),
	  				 length(PositionList,NumberOfPositions),
	  				 %Multiply the number of positions by the max allowable error, since the error 
	  				 %limit is per position (on average)
	  				 MaxAllowableErrorForCircleOfBestFit is NumberOfPositions * 
	  				 	MaxAllowableErrorForCircleOfBestFitPerPositionOnAverage,
	  				 COBFErrorMeasure =< MaxAllowableErrorForCircleOfBestFit
				  )),
		 %Constraint 2 implements atPosition(FigureId,(X1,Y1),ElapsedTime1)
		 %[as printed in BRM]
		 2:compute(( LHS =
		 			 [timestamp(ElapsedTime1),
		 			  figure(FigureId,position(X1,Y1),Shape1,Color1)],
		 			 findAnyCorroboratingEdgeWithCut(_SpanEnd1,_SpanEnd2,LHS,_CF2,
		 			 						  _ParentId,_RHS_ParsedParts)
		 		   )
		 		  ),
		 %Constraint 3 implements atPosition(ApproachedObjectId,(X4,Y4),ElapsedTime1)
		 %[as printed in BRM]
		 3:compute(( ApproachedObjectId #\= FigureId,
		 			 LHS2 =
		 			 [timestamp(ElapsedTime1),
		 			  figure(ApproachedObjectId,position(X4,Y4),_Shape2,_Color2)],
		 			 findAnyCorroboratingEdge(_SpanEnd3,_SpanEnd4,LHS2,_CF3,
		 			 						  _ParentId2,_RHS_ParsedParts2)
		 		   )
		 		  ),
		 %Constraint 4 implements atPosition(ApproachedObjectId,(X4,Y4),ElapsedTime2)
		 %[as printed in BRM]
		 4:compute(( LHS3 =
		 			 [timestamp(ElapsedTime2),
		 			  figure(ApproachedObjectId,position(X4,Y4),_Shape3,_Color3)],
		 			 findAnyCorroboratingEdgeWithCut(_SpanEnd5,_SpanEnd6,LHS3,_CF4,
		 			 						  _ParentId3,_RHS_ParsedParts3)
		 		   )
		 		  ),
		 %Constraint 5 implements atPosition(ApproachedObjectId,(X4,Y4),ElapsedTime3)
		 %[as printed in BRM]
		 5:compute(( LHS4 =
		 			 [timestamp(ElapsedTime3),
		 			  figure(ApproachedObjectId,position(X4,Y4),_Shape4,_Color4)],
		 			 findAnyCorroboratingEdgeWithCut(_SpanEnd7,_SpanEnd8,LHS4,_CF5,
		 			 						  _ParentId4,_RHS_ParsedParts4)
		 		   )
		 		  ),
		 %Constraint 6 implements atPosition(ThreatObjectId,(X5,Y5),ElapsedTime1)
		 %[as printed in BRM]
		 6:compute(( ThreatObjectId #\= ApproachedObjectId,
		 			 ThreatObjectId #\= FigureId,
		 			 LHS5 =
		 			 [timestamp(ElapsedTime1),
		 			  figure(ThreatObjectId,position(X5,Y5),_Shape5,_Color5)],
		 			 findAnyCorroboratingEdge(_SpanEnd9,_SpanEnd10,LHS5,_CF6,
		 			 						  _ParentId5,_RHS_ParsedParts5)
		 		   )
		 		  ),
		 %Constraint 7 implements atPosition(ThreatObjectId,(X5,Y5),ElapsedTime2)
		 %[as printed in BRM]
		 7:compute(( LHS6 =
		 			 [timestamp(ElapsedTime2),
		 			  figure(ThreatObjectId,position(X5,Y5),_Shape6,_Color6)],
		 			 findAnyCorroboratingEdgeWithCut(_SpanEnd11,_SpanEnd12,LHS6,_CF7,
		 			 						  _ParentId6,_RHS_ParsedParts7)
		 		   )
		 		  ),
		 %Constraint 8 implements atPosition(ThreatObjectId,(X5,Y5),ElapsedTime3)
		 %[as printed in BRM]
		 8:compute(( LHS7 =
		 			 [timestamp(ElapsedTime3),
		 			  figure(ThreatObjectId,position(X5,Y5),_Shape7,_Color7)],
		 			 findAnyCorroboratingEdgeWithCut(_SpanEnd13,_SpanEnd14,LHS7,_CF8,
		 			 						  _ParentId7,_RHS_ParsedParts8)
		 		   )
		 		  ),
		 %Constraint 10 might be too restrictive. It's easy to construct an
		 %example where observers would still ascribe 2 simultaneous intentions
		 %which nevertheless violates this constraint. Such an example would be
		 %a scenario where the moving object temporarily moves away from the 
		 %approached object, in order to avoid the threat object.
		 %Constraint 9's sole purpose is to feed the result values into
		 %constraint 10.
		 %Hence, we comment out constraints 9 & 10. 
		 /*
		 9:compute((euclideanDistance(X1,Y1,X4,Y4,Distance1_4),
		 			euclideanDistance(X2,Y2,X4,Y4,Distance2_4),
		 			euclideanDistance(X3,Y3,X4,Y4,Distance3_4),
		 			euclideanDistance(X1,Y1,X5,Y5,Distance1_5),
		 			euclideanDistance(X2,Y2,X5,Y5,Distance2_5),
		 			euclideanDistance(X3,Y3,X5,Y5,Distance3_5)
		 		   )
		 		  ),
		 %Constrain the distance relationship between the affected object
		 %and the threat object as well as the approached object
		 10:compute((Distance3_4 $=< Distance2_4,
		 			 Distance2_4 $=< Distance1_4,
		 			 Distance3_5 $>= Distance2_5,
		 			 Distance2_5 $>= Distance1_5
		 			)
		 		   ),
		 */
		 %Constrain the position of the threat object such that it lies below
		 %the curved trajectory. We check that the position of the threat object lies
		 %within the curved trajectory's circle of best fit
		 9:compute(positionLiesWithinCircle((X5,Y5),COBFXc,COBFYc,COBFRc)
		 		   ),
		 %Constrain the position of the approached object such that it lies ahead 
		 %of the curved trajectory. The position is constrained such that it lies
		 %within the boundaries consisting of the line formed by connecting 
		 %the last two points in the curve, (X2,Y2) & (X3,Y3), the line formed
		 %by connecting the last point in the curve, (X3,Y3), to the position
		 %of the threat object, (X5,Y5), and the line formed by connecting the 
		 %first point in the curve, (X1,Y1), to the position of the threat object,
		 %(X5,Y5). See the Wayang project's doc folder for a diagram 
		 %(attractorLocation.JPG).
		 %It is also possible that the approached object lies slightly 
		 %outside the area but still in the moving object's path if it were to 
		 %move in a straight line formed from the last 2 points. The alternative
		 %constraint is expressed in terms of regularityFromForce. 
		 10:compute((%Firstly, we consider the boundary line formed by
		 			 %connecting the last two points in the curve.
		 			
		 			 %Find the side of the line on which the threat object lies.  
		 			 pointLiesOnWhichSideOfTheLine(
		 				 twoPointsOfTheLine( (X2,Y2),(X3,Y3) ),
		 				 (X5,Y5),Side1 ),
		 			 %The approached object should lie on the same side as the
		 			 %threat object
		 			 pointLiesOnCorrectSideOfTheLine(
		 				 twoPointsOfTheLine( (X2,Y2),(X3,Y3) ),
		 				 (X4,Y4),Side1 ),
		 			
		 			 %Next, we consider the boundary line formed by
		 			 %connecting the last point in the curve to the position of
		 			 %the threat object.
		 			
		 			 %Find the side of the line on which the first point in the
		 			 %curve lies.
		 			 pointLiesOnWhichSideOfTheLine(
		 				 twoPointsOfTheLine( (X3,Y3),(X5,Y5) ),
		 				 (X1,Y1),Side2 ),
		 			 %The approached object should lie on the side opposite to 
		 			 %that on which the first point in the curve lies.
		 			 (Side2 = greater ->
		 				 pointLiesOnCorrectSideOfTheLine(
		 					 twoPointsOfTheLine( (X3,Y3),(X5,Y5) ),
		 					 (X4,Y4),less )
		 			  ;
		 			 	 pointLiesOnCorrectSideOfTheLine(
		 					 twoPointsOfTheLine( (X3,Y3),(X5,Y5) ),
		 					 (X4,Y4),greater )
		 			 ),
		 			
		 			 %Lastly, we consider the boundary line formed by
		 			 %connecting the first point in the curve to the position of
		 			 %the threat object.
		 			
		 			 %Find the side of the line on which the last point in the
		 			 %curve lies.
		 			 pointLiesOnWhichSideOfTheLine(
		 				 twoPointsOfTheLine( (X1,Y1),(X5,Y5) ),
		 				 (X3,Y3),Side3 ),
		 			 %The approached object should lie on the same side as the 
		 			 %last point in the curve.
		 			 pointLiesOnCorrectSideOfTheLine(
		 				 twoPointsOfTheLine( (X1,Y1),(X5,Y5) ),
		 				 (X4,Y4),Side3 )
		 			;
		 			 %Alternatively, we constrain the location of the approached
		 			 %object such that it lies ahead of the moving object's path,
		 			 %were the object to move in a straight line. 
		 			 %We use regularityFromForce, which is used in single
		 			 %acting force scenario but is also suitable for our usage 
		 			 %here.
		 			 regularityFromForce(FigureId,Shape1,
		 			 	linearMovingTrajectory( lastPosition(X3,Y3),
		 			 							magnitude(XMagn,YMagn),
		 			 							acceleration(AccelTriplets),
		 			 							[] ), %We don't need to define what the pos list might be
		 			 								  %since it won't be used. But it still needs to be bound.
		 			 	ElapsedTime3,
		 			 	ApproachedObjectId,
		 			 	attractive,
		 			 	_LinearAttractiveForceMagnitude,
		 			 	_CF9)
		 		    )
		 		   ),
		 %Check that there are no other objects that might have propelled the
		 %affected object. We check for any object in contact with the affected
		 %object at ElapsedTime1.
		 11:compute( findall( TargetId,
		 					 (TargetId #\= FigureId,
		 					  %TargetId #\= ThreatObjectId,
		 					  %TargetId #\= ApproachedObjectId,
		 					  LHS8 =
		 					  [timestamp(ElapsedTime1),
		 					   figure(TargetId,position(X6,Y6),Shape8,_Color8)],
		 					  findAnyCorroboratingEdge(
		 					   _SpanEnd15,_SpanEnd16,LHS8,_CF10,_ParentId8,
		 					   _RHS_ParsedParts9),
		 					  makeNonResistiveStationaryTrajectory(
		 					  	position(X1,Y1),StationaryTrajectory1),
		 					  makeNonResistiveStationaryTrajectory(
		 					  	position(X6,Y6),StationaryTrajectory2),
		 					  onInterceptCourse(Shape1,StationaryTrajectory1,
		 					  	Shape8,StationaryTrajectory2)
		 					 ),
		 					  []
		 					)
		 			),
		 %//TODO Constraint 12 is very strict and the irregularities in animations we use could cause this constraint
		 %       to fail to be fulfilled. Comment out for now.
		 /*12:compute( figureMovesWithConsistentAccelerationProfile(
		 				intendAtPositionOrAvoidApproach,
						AccelTriplets)
				   ),*/
		 %Check whether the moving object wiggles from ElapsedTime1 to ElapsedTime3
		 %Wiggling is an added sign of animacy and should increase the confidence 
		 %for the intention ascription.
		 13:compute((BaseRecursiveOrWiggle = wiggle ->
		 				true %//TODO The only reason this contingency condition is present 
		 					 %  is to allow increasing the CF value for the wiggle case.
		 		   ;
		 		   		true
		 		   )),
		 %Generate draw instrs
		 14:compute((RuleLHSWithoutDIWithCFReplaced = conjunction([ intend(	FigureId,
																			avoid,
																			ThreatObjectId,		
																			originally(Shape1,Color1),
																			ElapsedTime1,ElapsedTime3,
																			cv),										
						    										intend(	FigureId,
																			approach,
																			ApproachedObjectId,
																			originally(Shape1,Color1),
																			ElapsedTime1,ElapsedTime3,
																			cv)
			  			  										 ]),
			  		 generatePositionList(FigureId,ElapsedTime1,ElapsedTime3,PositionListForDI),
			  		 genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime3,
			  		 					 RuleLHSWithoutDIWithCFReplaced,CF,[PositionListForDI],
			  		 					 [ApproachedObjectId,ThreatObjectId],
			  		 					 combinedIntentionToApproachAndAvoid,DrawInstrs)
		 		   )),			  	 
		 15:compute( CF = CF1 ) %TODO: properly define the CF function		 					    
		])).
		
%What would the recursive case of this rule add to the base case?
%As of now, the base case would derive its CF value from that of the curve.
%The recursive rule for the curve derives its CF value from the smaller curve,
%the distance between the circle defining the smaller curve and the latest
%circle, and the CF value of the latest curve 
%(see KnowledgeBase_curvedTrajectory.ecl). If the recursive case of 
%intendToAvoidAndApproach will also check for curvilinearity and other similar
%checks, it should just let the curved trajectory rule do the work. In this
%case, only the base case is required.
%The recursive rule would still be useful for detecting additional scenarios
%that should be detected but cannot be detected by the base rule. The following
%implementation of the recursive rule can detect such a scenario. The scenario 
%consists of a curved movement followed by a short segment of linear movement 
%whose direction is consistent relative to the approached object. The recursive
%rule checks that the length of the linear segment does not exceed a 
%predetermined threshold. Beyond this threshold, we should probably not ascribe
%the movement to simultaneous intentions. Note that linear segments that are
%not exactly straight will still be detectable by the base rule, but will
%presumably be given a low confidence value. If the recursive rule extends
%such an ascription the test for the length of the linear segment will not be
%as intended (since the test will ignore the linear segment that is covered by
%the base rule).If the recursive rule derives its CF value from the CF value 
%of the base rule ascription, the resulting CF value will also be low, which 
%is what we want.
%//TODO Since the recursive rule allows the linear trajectory component to be inferred
%		from wiggles, there could be duplicates and we could apply duplicate-reduction 
%		constraints similar to what we have in the single intention to approach/avoid
%		recursive rule. However since the length of the linear trajectory is restricted
%		to a short length, we don't expect many duplicates and therefore we don't apply
%		the constraints for now, unless it is found to be necessary to do so.
%  
:- addRule(
	intendToAvoidAndApproach_recursiveStep,
	<=( cause(conjunction([ intend(	FigureId,
									avoid,
									ThreatObjectId,
									CurvedTrajectory,
									LinearSegmentInformation,
									originally(Shape1,Color1),
									ElapsedTime1,ElapsedTime5,
									CF,
									DrawInstrs ),
							intend(	FigureId,
									approach,
									ApproachedObjectId,
									CurvedTrajectory,
									LinearSegmentInformation,
									originally(Shape1,Color1),
									ElapsedTime1,ElapsedTime5,
									CF,
									[] ) %DrawInstrs stored in 1st conjunct
			  			  ]),
			  [ conjunction([ intend( FigureId,
			  			  			  avoid,
						  			  ThreatObjectId,
						  			  CurvedTrajectory,
						  			  LinearSegmentInformation1,
						  			  originally(Shape1,Color1),
						  			  ElapsedTime1,ElapsedTime4,
						  			  CF1,
						  			  _DrawInstrs1 ),
				  			  intend( FigureId,
				  		  			  approach,
						  			  ApproachedObjectId,
						  			  CurvedTrajectory,
						  			  LinearSegmentInformation1,
						  			  originally(Shape1,Color1),
						  			  ElapsedTime1,ElapsedTime4,
						 			  CF1,
						  			  _DrawInstrs2 )
							]),
				figureHasTrajectory(FigureId,
							linearMovingTrajectory( lastPosition(X6,Y6),
													magnitude(XMagn2,YMagn2),
													acceleration(AccelTriplets2),
													LinearTrajectoryPositionList),
							ElapsedTime4,ElapsedTime5,
							CF2,
							originally(Shape2,Color2),
							_DrawInstrs3,
							BaseRecursiveOrWiggle)
			  ]
			 ),
		[1:compute(CurvedTrajectory = 
						curvedTrajectory(secondToLastPosition(X2,Y2),
									secondToLastElapsedTime(ElapsedTime2),
									lastPosition(X3,Y3),
									latestProjectedCircle(Xc,Yc,R,DirectionSign),
									magnitude(XMagn,YMagn),
									acceleration(AccelTriplets0),
									PositionList,
									circleOfBestFit(COBFXc,COBFYc,COBFRc,COBFErrorMeasure))
				  ),
		 %Constraint 2 ensures that the linear trajectory (2nd effect) isn't generated by the trajectory recursive rule. 
		 %The reason for this is that we don't want longer trajectories to trigger the double intention recursive rule, 
		 %since there should already be a double intention edge with a longer double intention component and a shorter 
		 %(i.e. base-rule generated) trajectory component covering the same span from ElapsedTime1 to ElapsedTime5. 
		 %Without this constraint there would be duplicate ascriptions.
		 2:compute(delayableDisjunctedCalls([BaseRecursiveOrWiggle],BaseRecursiveOrWiggle \= recursive)
		 		  ),
		 3:compute((LinearSegmentInformation1 = 
		 				linearSegment(LengthOfLinearSegment1,
		 					secondToLastLinearPosition(X4,Y4),
							secondToLastLinearElapsedTime(ElapsedTime3),
							lastLinearPosition(X5,Y5),
							acceleration(AccelTriplets1)),
					delayableDisjunctedCalls(AccelTriplets2,append(AccelTriplets2,AccelTriplets1,AccelTriplets3)),
				    LinearSegmentInformation =
				    	linearSegment(LengthOfLinearSegment,
				    		secondToLastLinearPosition(X5,Y5),
				    		secondToLastLinearElapsedTime(ElapsedTime4),
				    		lastLinearPosition(X6,Y6),
				    		acceleration(AccelTriplets3))
				   ;
				    LinearSegmentInformation1 =
				    	noLinearSegment,
				    X4 = X2, Y4 = Y2,
				    X5 = X3, Y5 = Y3,
				    ElapsedTime3 = ElapsedTime2,
				    LengthOfLinearSegment1 = 0.0,
				    AccelTriplets3 = AccelTriplets2,
				    LinearSegmentInformation =
				    	linearSegment(LengthOfLinearSegment,
				    		secondToLastLinearPosition(X3,Y3),
				    		secondToLastLinearElapsedTime(ElapsedTime4),
				    		lastLinearPosition(X6,Y6),
				    		acceleration(AccelTriplets3))
				   )
				  ),
		 4:compute((figureMovesLinearly(
							FigureId,
							observ1(ElapsedTime3,position(X4,Y4),Shape1,Color1),
							observ2(ElapsedTime4,position(X5,Y5),Shape1,Color1),
							linearMovingTrajectory(	lastPosition(X5,Y5),
												magnitude(XMagn1,YMagn1),_,_ ) ),
					angleBetweenTwoVectorsIsCloseToZero(XMagn1,YMagn1,XMagn2,YMagn2)
		 		   )
		 		  ),
		 5:compute((euclideanDistance(X5,Y5,X6,Y6,AdditionalLength),
		 			LengthOfLinearSegment $= LengthOfLinearSegment1 + 
		 				AdditionalLength,
		 			%The value below is the upper threshold for the length
		 			%of the linear segment. The value should be adjusted to
		 			%an appropriate value.
		 			setting(maxLinearSegmentLengthForDoubleIntentionsOrForces(MaxLinearSegmentLengthForDoubleIntentionsOrForces)),
		 			LengthOfLinearSegment $=< MaxLinearSegmentLengthForDoubleIntentionsOrForces 
		 		   )	
		 		  ),
		 %Constrain the location of the approached object such that it's ahead   
		 %of the moving object. We use regularityFromForce, which is used in
		 %single acting force scenario but is also suitable for our usage here.
		 6:compute(regularityFromForce(FigureId,Shape1,
		 				linearMovingTrajectory(	lastPosition(X6,Y6),
												magnitude(XMagn2,YMagn2),
												acceleration(AccelTriplets2),LinearTrajectoryPositionList ),
						ElapsedTime5,
						ApproachedObjectId,
						attractive,
						_ForceMagnitude,
						CF3)
				  ),
		 %//TODO Constraint 7 is very strict and the irregularities in animations we use could cause this constraint
		 %       to fail to be fulfilled. Comment out for now.
		 /*7:compute((delayableDisjunctedCalls(AccelTriplets3,
		 									 (append(AccelTriplets3,AccelTriplets0,AccelTriplets4), 
		 			  						  figureMovesWithConsistentAccelerationProfile(
		 											intendAtPositionOrAvoidApproach,
													AccelTriplets4)
											))
				  )),*/
		 %Check whether the moving object wiggles from ElapsedTime4 to ElapsedTime5
		 %Wiggling is an added sign of animacy and should increase the confidence 
		 %for the intention ascription.
		 8:compute((Constraint = (BaseRecursiveOrWiggle = wiggle ->
		 							true %//TODO The only reason this contingency condition is present 
		 					 			 %  is to allow increasing the CF value for the wiggle case.
		 		   				 ;
		 		   					true
		 		   				 ),
		 		   	delayableDisjunctedCalls([BaseRecursiveOrWiggle],Constraint)
		 		   )),
		 9:compute((RuleLHSWithoutDIWithCFReplaced = conjunction([ intend(	FigureId,
																			avoid,
																			ThreatObjectId,		
																			originally(Shape1,Color1),
																			ElapsedTime1,ElapsedTime5,
																			cv),										
						    										intend(	FigureId,
																			approach,
																			ApproachedObjectId,
																			originally(Shape1,Color1),
																			ElapsedTime1,ElapsedTime5,
																			cv)
			  			  										 ]),
			  		generatePositionList(FigureId,ElapsedTime1,ElapsedTime5,PositionListForDI),
			  		genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime5,
			  		 					RuleLHSWithoutDIWithCFReplaced,CF,[PositionListForDI],
			  		 					[ApproachedObjectId,ThreatObjectId],
			  		 					combinedIntentionToApproachAndAvoid,DrawInstrs)
		 		  )),		
		 10:compute(combineConfidenceFactors([CF1,CF2,CF3],CF))		
		])).