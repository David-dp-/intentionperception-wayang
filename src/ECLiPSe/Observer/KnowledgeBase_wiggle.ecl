:- compile('KnowledgeBase_curvedTrajectory.ecl').

/*------------------------------------------------------------------------------
 * We define a wiggle as a succession of curved trajectories with defining circles
 * lying on two opposite sides. 
 * There are 2 base rules: the first one consists of two non-overlapping 
 * trajectories and the second one consists of two overlapping trajectories.
 * The recursive rules expand upon the base rules and can therefore consist
 * of multiple segments of curved trajectories in which each pair of curved
 * trajectories are defined by circles lying on two opposite sides. As is the case
 * with the base rules, the recursive rules specify that a wiggle can either be
 * extended with a non-overlapping curved trajectory or an overlapping one. 
 * The circles should be comparable in size, which is meant to restrict the
 * wiggle to having a balanced shape.
 * WigglePositionList contains positions that are used to generate a trajectory
 * of best fit (TrajectoryOfBestFit). 
 -----------------------------------------------------------------------------*/
 
 :- addRule(
 	 wiggle_baseStep_no_overlap,
 	 <=( cause( wiggle(FigureId,
 	 				   ElapsedTime1,ElapsedTime3,
 	 				   latestProjectedCircle(Xc2,Yc2,R2,DirectionSign2),
 	 				   COBFRc2,
 	 				   WigglePositionList,
 	 				   TrajectoryOfBestFit,
 	 				   originally(Shape1,Color1),
 	 				   CF,
 	 				   DrawInstrs
 	 				  ),
 	 			[figureHasTrajectory(	FigureId,
										CurvedTrajectory1,
										ElapsedTime1,ElapsedTime2,
										CF1,
										originally(Shape1,Color1),
										_DrawInstrs1,
										BaseRecursiveOrWiggle ),
				 figureHasTrajectory(	FigureId,
										CurvedTrajectory2,
										ElapsedTime2,ElapsedTime3,
										CF2,
										originally(Shape2,Color2),
										_DrawInstrs2,
										BaseRecursiveOrWiggle2 )
 	 			]
 	 		  ),	  
 	 	 [1:compute((CurvedTrajectory1 =
 	 	 				 curvedTrajectory(secondToLastPosition(X1,Y1),
 	 	 				 		secondToLastElapsedTime(ElapsedTime1b),lastPosition(X2,Y2),
 	 	 				 		latestProjectedCircle(Xc1,Yc1,R1,DirectionSign1),
 	 	 				 		magnitude(XMagn1,YMagn1),acceleration(AccelTriplets1),
 	 	 				 		PositionList1,
 	 	 				 		circleOfBestFit(COBFXc1,COBFYc1,COBFRc1,COBFErrorMeasure1))
 	 	 			;
 	 	 			 CurvedTrajectory1 =
 	 	 			 	 curvedTrajectory(secondToLastPosition(X1,Y1),
 	 	 			 	 		secondToLastElapsedTime(ElapsedTime1b),lastPosition(X2,Y2),
 	 	 			 	 		linear(Length1),previousProjectedCircle(Xc1,Yc1,R1,DirectionSign1),
 	 	 			 	 		magnitude(XMagn1,YMagn1),acceleration(AccelTriplets1),
 	 	 			 	 		PositionList1,
 	 	 				 		circleOfBestFit(COBFXc1,COBFYc1,COBFRc1,COBFErrorMeasure1))	
 	 	 		   )),
 	 	  2:compute((Constraint =
 	 	  				(CurvedTrajectory2 =
 	 	  					curvedTrajectory(secondToLastPosition(X3,Y3),
 	 	 				 		secondToLastElapsedTime(ElapsedTime2b),lastPosition(X4,Y4),
 	 	 				 		latestProjectedCircle(Xc2,Yc2,R2,DirectionSign2),
 	 	 				 		magnitude(XMagn2,YMagn2),acceleration(AccelTriplets2),
 	 	 				 		PositionList2,
 	 	 				 		circleOfBestFit(COBFXc2,COBFYc2,COBFRc2,COBFErrorMeasure2))
 	 	 				;
 	 	 				 CurvedTrajectory2 =
 	 	 			 	 	curvedTrajectory(secondToLastPosition(X3,Y3),
 	 	 			 	 		secondToLastElapsedTime(ElapsedTime2b),lastPosition(X4,Y4),
 	 	 			 	 		linear(Length2),previousProjectedCircle(Xc2,Yc2,R2,DirectionSign2),
 	 	 			 	 		magnitude(XMagn2,YMagn2),acceleration(AccelTriplets2),
 	 	 			 	 		PositionList2,
 	 	 				 		circleOfBestFit(COBFXc2,COBFYc2,COBFRc2,COBFErrorMeasure2))
 	 	  				),
 	 	  			 delayableDisjunctedCalls([CurvedTrajectory2],Constraint)
 	 	  		   )),
 	 	  %Component trajectories shouldn't be trajectories that are themselves inferred from wiggles
 	 	  3:compute((BaseRecursiveOrWiggle \= wiggle,
 	 	  			 delayableDisjunctedCalls([BaseRecursiveOrWiggle2],BaseRecursiveOrWiggle2 \= wiggle)
 	 	  		   )),	
 	 	  4:compute((%Check that COBFErrorMeasure1 and COBFErrorMeasure2 are sufficiently small
 	 	  		     setting(maxAllowableErrorForCircleOfBestFitPerPositionOnAverage(MaxAllowableErrorForCircleOfBestFitPerPositionOnAverage)),
	  				 length(PositionList1,NumberOfPositions1),
	  				 %Multiply the number of positions by the max allowable error, since the error limit is per position (on average)
	  				 MaxAllowableErrorForCircleOfBestFit1 is NumberOfPositions1 * MaxAllowableErrorForCircleOfBestFitPerPositionOnAverage,
	  				 COBFErrorMeasure1 =< MaxAllowableErrorForCircleOfBestFit1,
	  				 delayableDisjunctedCalls([PositionList2,COBFErrorMeasure2],
	  				 	(length(PositionList2,NumberOfPositions2),
	  				 	 MaxAllowableErrorForCircleOfBestFit2 is NumberOfPositions2 * MaxAllowableErrorForCircleOfBestFitPerPositionOnAverage,
	  				 	 COBFErrorMeasure2 =< MaxAllowableErrorForCircleOfBestFit2
	  				 	 ))
 	 	  		   )),
 	 	  5:compute(%The direction signs of the latest projected circles are sufficient to determine sides, whereas the radii
 	 	  			%should be taken from the circles of best fit defining the entire curves.
 	 	  			figureMovesWithConsistentWigglyPattern(DirectionSign1,DirectionSign2,COBFRc1,COBFRc2)),
 	 	  6:compute((%Collect positions that define the wiggle. We will use the positions to calculate line/circle of best fit for the wiggle.
 	 	  			 %The last position of CurvedTrajectory1 is the first position of CurvedTrajectory1, so we remove a duplicate.
 	 	  			 Constraint2 = (PositionList2 = [Position2|Positions2],
					 				append(PositionList1,Positions2,WigglePositionList)),
					 delayableDisjunctedCalls(PositionList2,Constraint2)
				   )),
		  7:compute(%Combine AccelTriplets1 and AccelTriplets2 and use as the trajectory of best fit's acceleration profile.
		  			%//TODO If the acceleration values, and not just the signs, are important, then each of the values would
		  			%		need to be projected in the direction of the trajectory of best fit
		  			delayableDisjunctedCalls([AccelTriplets2],append(AccelTriplets2,AccelTriplets1,AccelTriplets3)) 
		  		   ),
		  8:compute(%Calculate trajectory of best fit  
 	 	  			findTrajectoryOfBestFit(WigglePositionList,(XMagn2,YMagn2),ElapsedTime2b,ElapsedTime3,AccelTriplets3,TrajectoryOfBestFit)
 	 	  		   ),
 	 	  9:compute(combineConfidenceFactors([CF1,CF2],CF)),
 	 	  %A wiggle can consist of 2 curved trajectories generated from either the base or recursive curved trajectory rule, so unlike 
 	 	  %for some other rules involving linear/stationary trajectories, it's not appropriate for the base wiggle rule to restrict the component 
 	 	  %curved trajectories to those generated by the base curved trajectory rule. A side effect is that the base wiggle rule can generate
 	 	  %duplicates covering the same time period. This can happen, if, for example, the first duplicate matches a curve made up of P1,P2,P3 and
 	 	  %then a curve made up of P4,P5,P6,P7, whereas the second duplicate matches a curve made up of P1,P2,P3,P4 and then a curve made up of
 	 	  %P5,P6,P7.
 	 	  %As a possible way to reduce duplicates, constraint 10 checks whether there's already an existing wiggle edge covering the same
 	 	  %time period for the same figure, with a higher CF value. The constraint is satisfied if and only if there's no such edge. 
 	 	  10:compute((Constraint3 = (findall(CF3,
 	 	  									 (findAnyCorroboratingEdge(_SpanEnd1,_SpanEnd2,
 	 	  															   wiggle(FigureId,
 	 				   							   							  ElapsedTime1,ElapsedTime3,
 	 				   							   							  _LatestProjectedCircle,
 	 				   							   							  _COBFRc3,
 	 				   							   							  _WigglePositionList2,
 	 				   							   							  _TrajectoryOfBestFit2,
 	 				   							   							  _Originally,
 	 				   							   							  CF3,
 	 				   							   							  _DrawInstrs3
 	 				   							   							 ),
 	 				   							   					   _CF4,_ParentId, _RHS_parsedParts
 	 				  							  					  ),
 	 				  						  %We don't want to compare bounded reals, float/2 will convert the CFs to float values if the
 	 				  						  %CFs are indeed bounded reals.
 	 				  						  FloatCF3 is float(CF3),
 	 				  						  FloatCF is float(CF),
 	 				  						  FloatCF3 > FloatCF
 	 				  						 ),
 	 				  						 []
 	 				  					    )
 	 				  			    ),
 	 				  delayableDisjunctedCalls([CF],Constraint3)					   
 	 	  		    )),
 	 	  %Generate draw instrs
 	 	  11:compute((RuleLHSWithoutDIWithCFReplaced = wiggle(FigureId,
 	 				   										  ElapsedTime1,ElapsedTime3,
 	 				   										  originally(Shape1,Color1),
 	 				   										  cv),
 	 				  Constraint4 = (TrajectoryOfBestFit = linearMovingTrajectory(_,_,_,_) ->
 	 				  					TrajectoryOfBestFitType = linear
 	 				  				;
 	 				  					(TrajectoryOfBestFit = curvedTrajectory(_,_,_,_,_,_,_,_) ->
 	 				  						TrajectoryOfBestFitType = curved
 	 				  					;
 	 				  						TrajectoryOfBestFitType = undefined
 	 				  					)
 	 				  				),  
 	 				  delayableDisjunctedCalls([TrajectoryOfBestFit],Constraint4),
 	 				  generatePositionList(FigureId,ElapsedTime1,ElapsedTime3,PositionListForDI), 
 	 				  genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime3,
			  		 					 RuleLHSWithoutDIWithCFReplaced,CF,[PositionListForDI],
			  		 					 [TrajectoryOfBestFitType],
			  		 					 wiggle,DrawInstrs)
 	 	  			))	
 	 	 ])).
 	 	 
 :- addRule(
 	 wiggle_baseStep_with_overlap,
 	 <=( cause( wiggle(FigureId,
 	 				   ElapsedTime1,ElapsedTime3,
 	 				   latestProjectedCircle(Xc2,Yc2,R2,DirectionSign2),
 	 				   COBFRc2,
 	 				   WigglePositionList,
 	 				   TrajectoryOfBestFit,
 	 				   originally(Shape1,Color1),
 	 				   CF,
 	 				   DrawInstrs
 	 				  ),
 	 			[figureHasTrajectory(	FigureId,
										CurvedTrajectory1,
										ElapsedTime1,ElapsedTime2,
										CF1,
										originally(Shape1,Color1),
										_DrawInstrs1,
										BaseRecursiveOrWiggle ),
				 [timestamp(ElapsedTime3),figure(FigureId,position(X3,Y3),Shape2,Color2)]						
 	 			]
 	 		  ),
 	 	 [1:compute(%only a curvy curved trajectory would make sense here
 	 	 			CurvedTrajectory1 =
 	 	 				 curvedTrajectory(secondToLastPosition(X1,Y1),
 	 	 				 		secondToLastElapsedTime(ElapsedTime1b),lastPosition(X2,Y2),
 	 	 				 		latestProjectedCircle(Xc1,Yc1,R1,DirectionSign1),
 	 	 				 		magnitude(XMagn1,YMagn1),acceleration(AccelTriplets1),
 	 	 				 		PositionList1,
 	 	 				 		circleOfBestFit(COBFXc1,COBFYc1,COBFRc1,COBFErrorMeasure1))
 	 	 		   ),
 	 	  %Component trajectory shouldn't be a trajectory that is itself inferred from a wiggle
 	 	  2:compute(BaseRecursiveOrWiggle \= wiggle
 	 	  		   ),
 	 	  3:compute((%only a curvy curved trajectory would make sense here
 	 	  			 %Construct PositionList2
 	 	  			 PositionList2 = [(X1,Y1),(X2,Y2),(X3,Y3)],
 	 	  			 %Find circle of best fit for CurvedTrajectory2
 	 	  			 findCircleOfBestFit(PositionList2,COBFXc2,COBFYc2,COBFRc2,COBFErrorMeasure2),
 	 	  			 CurvedTrajectory2 =
 	 	  					curvedTrajectory(secondToLastPosition(X2,Y2),
 	 	  								secondToLastElapsedTime(ElapsedTime2),lastPosition(X3,Y3),
 	 	  								latestProjectedCircle(Xc2,Yc2,R2,DirectionSign2),
 	 	  								magnitude(XMagn2,YMagn2),acceleration([AccelTriplet2]),
 	 	  								PositionList2,
 	 	  								circleOfBestFit(COBFXc2,COBFYc2,COBFRc2,COBFErrorMeasure2)),
 	 	  			 figureMovesCurvilinearly(
 	 	  				 	FigureId,
 	 	  				 	observ1(ElapsedTime1b,position(X1,Y1),Shape1,Color1),
 	 	  				 	observ2(ElapsedTime2,position(X2,Y2),Shape1,Color1),
 	 	  				 	observ3(ElapsedTime3,position(X3,Y3),Shape2,Color2),
 	 	  				 	CurvedTrajectory2,
 	 	  				 	CF2)
 	 	  		   )),
 	 	  %Ensure the frame for ElapsedTime2 is adjacent to the frame for ElapsedTime3
 	 	  %Constraint 4 is unnecessary since the parser already ensures this
	 	  /*4:compute(twoFramesAreAdjacent(ElapsedTime2,ElapsedTime3,FigureId)),*/
	 	  
 	 	  5:compute((%Check that COBFErrorMeasure1 and COBFErrorMeasure2 are sufficiently small
 	 	  		     setting(maxAllowableErrorForCircleOfBestFitPerPositionOnAverage(MaxAllowableErrorForCircleOfBestFitPerPositionOnAverage)),
	  				 length(PositionList1,NumberOfPositions1),
	  				 %Multiply the number of positions by the max allowable error, since the error limit is per position (on average)
	  				 MaxAllowableErrorForCircleOfBestFit1 is NumberOfPositions1 * MaxAllowableErrorForCircleOfBestFitPerPositionOnAverage,
	  				 COBFErrorMeasure1 =< MaxAllowableErrorForCircleOfBestFit1,
	  				 delayableDisjunctedCalls([PositionList2,COBFErrorMeasure2],
	  				 	(length(PositionList2,NumberOfPositions2),
	  				 	 MaxAllowableErrorForCircleOfBestFit2 is NumberOfPositions2 * MaxAllowableErrorForCircleOfBestFitPerPositionOnAverage,
	  				 	 COBFErrorMeasure2 =< MaxAllowableErrorForCircleOfBestFit2
	  				 	 ))
 	 	  		   )),
 	 	  6:compute(figureMovesWithConsistentWigglyPattern(DirectionSign1,DirectionSign2,COBFRc1,COBFRc2)),
 	 	  7:compute((%Collect positions that define the wiggle. We will use the positions to calculate line/circle of best fit for the wiggle
					 delayableDisjunctedCalls([X3,Y3],append(PositionList1,[(X3,Y3)],WigglePositionList))
				   )),
		  8:compute(%Combine AccelTriplets1 and AccelTriplet2 and use as the trajectory of best fit's acceleration profile.
		  		    %//TODO If the acceleration values, and not just the signs, are important, then each of the values would
		  		    %		need to be projected in the direction of the trajectory of best fit
		  		    delayableDisjunctedCalls([AccelTriplet2],append([AccelTriplet2],AccelTriplets1,AccelTriplets3)) 
		  		   ),
		  9:compute(%Calculate trajectory of best fit  
 	 	  		    findTrajectoryOfBestFit(WigglePositionList,(XMagn2,YMagn2),ElapsedTime2,ElapsedTime3,AccelTriplets3,TrajectoryOfBestFit)
 	 	  		   ),
 	 	  %Generate draw instrs
 	 	  10:compute((RuleLHSWithoutDIWithCFReplaced = wiggle(FigureId,
 	 				   										  ElapsedTime1,ElapsedTime3,
 	 				   										  originally(Shape1,Color1),
 	 				   										  cv),
 	 				  Constraint =  (TrajectoryOfBestFit = linearMovingTrajectory(_,_,_,_) ->
 	 				  					TrajectoryOfBestFitType = linear
 	 				  				;
 	 				  					(TrajectoryOfBestFit = curvedTrajectory(_,_,_,_,_,_,_,_) ->
 	 				  						TrajectoryOfBestFitType = curved
 	 				  					;
 	 				  						TrajectoryOfBestFitType = undefined
 	 				  					)
 	 				  				),  
 	 				  delayableDisjunctedCalls([TrajectoryOfBestFit],Constraint),
 	 				  generatePositionList(FigureId,ElapsedTime1,ElapsedTime3,PositionListForDI), 
 	 				  genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime3,
			  		 					 RuleLHSWithoutDIWithCFReplaced,CF,[PositionListForDI],
			  		 					 [TrajectoryOfBestFitType],
			  		 					 wiggle,DrawInstrs)
 	 	  			)),	
 	 	  11:compute(combineConfidenceFactors([CF1,CF2],CF)),
 	 	  %Attempt to reduce duplicates by checking if there's already an existing wiggle edge covering
 	 	  %the same time period with a higher CF value.The constraint is satisfied if and only if there's 
 	 	  %no such edge.
 	 	  12:compute((Constraint2 = (findall(CF3,
 	 	  									 (findAnyCorroboratingEdge(_SpanEnd1,_SpanEnd2,
 	 	  															   wiggle(FigureId,
 	 				   							   							  ElapsedTime1,ElapsedTime3,
 	 				   							   							  _LatestProjectedCircle,
 	 				   							   							  _COBFRc3,
 	 				   							   							  _WigglePositionList2,
 	 				   							   							  _TrajectoryOfBestFit2,
 	 				   							   							  _Originally,
 	 				   							   							  CF3,
 	 				   							   							  _DrawInstrs3
 	 				   							   							 ),
 	 				   							   					   _CF4,_ParentId, _RHS_parsedParts
 	 				  							  					  ),
 	 				  						  %We don't want to compare bounded reals, float/2 will convert the CFs to float values if the
 	 				  						  %CFs are indeed bounded reals.
 	 				  						  FloatCF3 is float(CF3),
 	 				  						  FloatCF is float(CF),
 	 				  						  FloatCF3 > FloatCF
 	 				  						 ),
 	 				  						 []
 	 				  					    )
 	 				  			    ),
 	 				  delayableDisjunctedCalls([CF],Constraint2)
 	 	  			))
 	 	 ])).
 	 	 
 :- addRule(
 	 wiggle_recursiveStep_no_overlap,
 	 <=( cause( wiggle(FigureId,
 	 				   ElapsedTime1,ElapsedTime3,
 	 				   latestProjectedCircle(Xc2,Yc2,R2,DirectionSign2),
 	 				   COBFRc2,
 	 				   WigglePositionList,
 	 				   TrajectoryOfBestFit,
 	 				   originally(Shape0,Color0),
 	 				   CF,
 	 				   DrawInstrs
 	 				  ),
 	 			[wiggle(FigureId,
 	 					ElapsedTime1,ElapsedTime2,
 	 					latestProjectedCircle(Xc1,Yc1,R1,DirectionSign1),
 	 					COBFRc1,
 	 					WigglePositionList1,
 	 				    TrajectoryOfBestFit1,
 	 				    originally(Shape0,Color0),
 	 					CF1,
 	 					_DrawInstrs1
 	 				   ),
 	 			 figureHasTrajectory(	FigureId,
										CurvedTrajectory1,
										ElapsedTime2,ElapsedTime3,
										CF2,
										originally(Shape1,Color1),
										_DrawInstrs2,
										BaseRecursiveOrWiggle )
 	 			]
 	 		  ),
 	 	[1:compute((Constraint =
 	 	  				(CurvedTrajectory1 =
 	 	  					curvedTrajectory(secondToLastPosition(X1,Y1),
 	 	 				 		secondToLastElapsedTime(ElapsedTime2b),lastPosition(X2,Y2),
 	 	 				 		latestProjectedCircle(Xc2,Yc2,R2,DirectionSign2),
 	 	 				 		magnitude(XMagn2,YMagn2),acceleration(AccelTriplets2),
 	 	 				 		PositionList1,
 	 	  						circleOfBestFit(COBFXc2,COBFYc2,COBFRc2,COBFErrorMeasure2))
 	 	 				;
 	 	 				 CurvedTrajectory1 =
 	 	 			 	 	curvedTrajectory(secondToLastPosition(X1,Y1),
 	 	 			 	 		secondToLastElapsedTime(ElapsedTime2b),lastPosition(X2,Y2),
 	 	 			 	 		linear(Length1),previousProjectedCircle(Xc2,Yc2,R2,DirectionSign2),
 	 	 			 	 		magnitude(XMagn2,YMagn2),acceleration(AccelTriplets2),
 	 	 			 	 		PositionList1,
 	 	  						circleOfBestFit(COBFXc2,COBFYc2,COBFRc2,COBFErrorMeasure2))
 	 	  				),
 	 	  			 delayableDisjunctedCalls([CurvedTrajectory1],Constraint)
 	 			  )),
 	 	 %The component trajectory (CurvedTrajectory1) shouldn't be a trajectory that is itself inferred from a wiggle
 	 	 2:compute(delayableDisjunctedCalls([BaseRecursiveOrWiggle],BaseRecursiveOrWiggle \= wiggle)),
 	 	 3:compute((%Check that COBFErrorMeasure2 is sufficiently small
 	 	  		    %Multiply the number of positions by the max allowable error, since the error limit is per position (on average) 
 	 	  		     setting(maxAllowableErrorForCircleOfBestFitPerPositionOnAverage(MaxAllowableErrorForCircleOfBestFitPerPositionOnAverage)),
	  				 delayableDisjunctedCalls([PositionList1,COBFErrorMeasure2],
	  				 	(length(PositionList1,NumberOfPositions1),
	  				 	 MaxAllowableErrorForCircleOfBestFit2 is NumberOfPositions1 * MaxAllowableErrorForCircleOfBestFitPerPositionOnAverage,
	  				 	 COBFErrorMeasure2 =< MaxAllowableErrorForCircleOfBestFit2))
 	 	  		   )),
 	 	 4:compute(figureMovesWithConsistentWigglyPattern(DirectionSign1,DirectionSign2,COBFRc1,COBFRc2)),
 	 	 5:compute((%Collect positions that define the wiggle. We will use the positions to calculate line/circle of best fit for the wiggle
 	 	 			%Combine WigglePositionList1 with PositionList1 and use for curve fitting
					Constraint2 =
						(PositionList1 = [Position1|Positions1],
						 append(WigglePositionList1,Positions1,WigglePositionList)
						),
					delayableDisjunctedCalls(PositionList1,Constraint2) 
				   )),
		 6:compute((% If TrajectoryOfBestFit1 is undefined, don't do anything. Constraint 7
		 		    %will handle it properly. Otherwise, from TrajectoryOfBestFit1 find AccelTriplets1 and then combine
		 		    %AccelTriplets1 and AccelTriplets2 and use as the trajectory of best fit's acceleration profile.
		  		    %//TODO If the acceleration values, and not just the signs, are important, then each of the values would
		  		    %	    need to be projected in the direction of the trajectory of best fit
		  		    (TrajectoryOfBestFit1 = undefined ->
		  		   		 true
		  		    ;	
		  		   		 (TrajectoryOfBestFit1 = linearMovingTrajectory(	_LastPosition1,
																		_Magnitude1,
																		acceleration(AccelTriplets1),
																		_LTOBFPositionList )
						 ;
						  TrajectoryOfBestFit1 = curvedTrajectory(_SecondToLastPosition1,
	                     					 					 _SecondToLastElapsedTime1,
	                     					 					 _LastPosition1,
	                     					 					 _LatestProjectedCircle1,
	                     					 					 _Magnitude1,
	                     					 					 acceleration(AccelTriplets1),
	                     					 					 _CTOBFPositionList,
	                     					 					 _CTOBFCircleOfBestFit )
	                     ),
		  		   		 delayableDisjunctedCalls([AccelTriplets2],append(AccelTriplets2,AccelTriplets1,AccelTriplets3)) 
		  		    )
		  		  )),
		 7:compute((%Calculate trajectory of best fit(TrajectoryOfBestFit), unless TrajectoryOfBestFit1 is undefined, in which case 
		 		    %TrajectoryOfBestFit should be undefined as well.
		 		    (TrajectoryOfBestFit1 = undefined ->
		 		   		 TrajectoryOfBestFit = undefined
		 		    ;  
 	 	  		   		 findTrajectoryOfBestFit(WigglePositionList,(XMagn2,YMagn2),ElapsedTime2b,ElapsedTime3,AccelTriplets3,TrajectoryOfBestFit)
 	 	  		    )
 	 	  		  )),		  
 	 	 8:compute(combineConfidenceFactors([CF1,CF2],CF)),
 	 	 %Constraints 9 & 10 are attempts to reduce duplicates.
 	 	 %Constraint 9 checks whether there exists a duplicate of the component wiggle covering ElapsedTime1 to ElapsedTime2 with a higher CF value.
 	 	 %The constraint is satisfied if and only if such a duplicate does not exist.
 	 	 9:compute((Constraint3 = (findall(CF3,
 	 	 								   (findAnyCorroboratingEdge(_SpanEnd1,_SpanEnd2,
 	 	 								   							 wiggle(FigureId,
 	 																		ElapsedTime1,ElapsedTime2,
 	 																		_LatestProjectedCircle2,
 	 																		_COBFRc3,
 	 																		_WigglePositionList2,
 	 				    													_TrajectoryOfBestFit2,
 	 				    													_Originally,
 	 																		CF3,
 	 																		_DrawInstrs3
 	 				  													   ),
 	 				  												 _CF4,_ParentId,_RHS_parsedParts
 	 				  												),
 	 				  						%We don't want to compare bounded reals, float/2 will convert the CFs to float values if the
 	 				  						%CFs are indeed bounded reals.
 	 				  						FloatCF3 is float(CF3),
 	 				  						FloatCF1 is float(CF1),
 	 				  						FloatCF3 > FloatCF1
 	 				  					   ),
 	 				  					   []
 	 				  					  )
 	 	 						  ),
 	 	 			%Delay if the second effect has not been matched, i.e. CurvedTrajectory1 is not yet bound.
 	 	 			%This will ensure all duplicates have already been generated.
 	 	 			delayableDisjunctedCalls([CurvedTrajectory1],Constraint3)
 	 	 		  )),
 	 	 %Constraint 10 checks whether there exists a duplicate of the high level wiggle covering ElapsedTime1 to ElapsedTime3 
 	 	 %with a higher CF value. The constraint is satisfied if and only if there's no such duplicate. While constraint 9 guards against duplicates
 	 	 %caused by duplicates of the wiggle component covering the same time period (ElapsedTime1 to ElapsedTime2), constraint 10 guards against
 	 	 %duplicates formed by a wiggle component covering a different time period (ElapsedTime1 to ElapsedTime2b, where ElapsedTime2b \= ElapsedTime2)  
 	 	 10:compute((Constraint4 = (findall(CF5,
 	 	 								    (findAnyCorroboratingEdge(_SpanEnd3,_SpanEnd4,
 	 	 								   							  wiggle(FigureId,
 	 	 								   									 ElapsedTime1,ElapsedTime3,
 	 				   														 _LatestProjectedCircle3,
 	 																		 _COBFRc4,
 	 																		 _WigglePositionList3,
 	 				    													 _TrajectoryOfBestFit3,
 	 				    													 _Originally2,
 	 																		 CF5,
 	 																		 _DrawInstrs4
 	 				  														 ),
 	 				  												  _CF6,_ParentId2,_RHS_parsedParts2
 	 				  												 ),
 	 				  					    %We don't want to compare bounded reals, float/2 will convert the CFs to float values if the
 	 				  					    %CFs are indeed bounded reals.
 	 				  					    FloatCF5 is float(CF5),
 	 				  					    FloatCF is float(CF),
 	 				  					    FloatCF5 > FloatCF
 	 				  					   ),
 	 				  					   []
 	 				  					  )
 	 				  			   ),
 	 				 delayableDisjunctedCalls([CF],Constraint4)
 	 			   )),
 	 	 %Generate draw instrs
 	 	 11:compute((RuleLHSWithoutDIWithCFReplaced = wiggle(FigureId,
 	 				   										  ElapsedTime1,ElapsedTime3,
 	 				   										  originally(Shape0,Color0),
 	 				   										  cv),
 	 				 Constraint5 =  (TrajectoryOfBestFit = linearMovingTrajectory(_,_,_,_) ->
 	 				  					TrajectoryOfBestFitType = linear
 	 				  			    ;
 	 				  					(TrajectoryOfBestFit = curvedTrajectory(_,_,_,_,_,_,_,_) ->
 	 				  						TrajectoryOfBestFitType = curved
 	 				  					;
 	 				  						TrajectoryOfBestFitType = undefined
 	 				  					)
 	 				  			    ),  
 	 				 delayableDisjunctedCalls([TrajectoryOfBestFit],Constraint5),
 	 				 generatePositionList(FigureId,ElapsedTime1,ElapsedTime3,PositionListForDI), 
 	 				 genDrawInstructions(FigureId,Shape0,Color0,ElapsedTime1,ElapsedTime3,
			  		 					 RuleLHSWithoutDIWithCFReplaced,CF,[PositionListForDI],
			  		 					 [TrajectoryOfBestFitType],
			  		 					 wiggle,DrawInstrs)
 	 	  			))	
 	 	])).
 	 	
:- addRule(
 	 wiggle_recursiveStep_with_overlap,
 	 <=( cause( wiggle(FigureId,
 	 				   ElapsedTime1,ElapsedTime3,
 	 				   latestProjectedCircle(Xc2,Yc2,R2,DirectionSign2),
 	 				   COBFRc2,
 	 				   WigglePositionList,
 	 				   TrajectoryOfBestFit,
 	 				   originally(Shape1,Color1),
 	 				   CF,
 	 				   DrawInstrs
 	 				  ),
 	 			[wiggle(FigureId,
 	 					ElapsedTime1,ElapsedTime2,
 	 					latestProjectedCircle(Xc1,Yc1,R1,DirectionSign1),
 	 					COBFRc1,
 	 					WigglePositionList1,
 	 				    TrajectoryOfBestFit1,
 	 				    originally(Shape1,Color1),
 	 					CF1,
 	 					_DrawInstrs1
 	 				   ),
 	 			 [timestamp(ElapsedTime3),figure(FigureId,position(X3,Y3),Shape3,Color3)]
 	 			]
 	 		  ),
 	 	 [1:compute((append(WigglePositionList1WithoutLastPosition,[(X2,Y2)],WigglePositionList1),
 	 	 			 append(_,[(X1,Y1)],WigglePositionList1WithoutLastPosition)	
 	 	 		   )),
 	 	  2:compute((%Construct PositionList2
 	 	  			 PositionList2 = [(X1,Y1),(X2,Y2),(X3,Y3)],
 	 	  			 %Find circle of best fit for CurvedTrajectory2
 	 	  			 findCircleOfBestFit(PositionList2,COBFXc2,COBFYc2,COBFRc2,COBFErrorMeasure2), 
 	 	  			 CurvedTrajectory2 =
 	 	  					curvedTrajectory(secondToLastPosition(X2,Y2),
 	 	  								secondToLastElapsedTime(ElapsedTime2),lastPosition(X3,Y3),
 	 	  								latestProjectedCircle(Xc2,Yc2,R2,DirectionSign2),
 	 	  								magnitude(XMagn2,YMagn2),acceleration([AccelTriplet2]),
 	 	  								PositionList2,
 	 	  								circleOfBestFit(COBFXc2,COBFYc2,COBFRc2,COBFErrorMeasure2)),
 	 	  			 findPreviousFrameElapsedTime(ElapsedTime2,FigureId,ElapsedTime1b),
 	 	  			 figureMovesCurvilinearly(
 	 	  				 	FigureId,
 	 	  				 	observ1(ElapsedTime1b,position(X1,Y1),Shape1,Color1),
 	 	  				 	observ2(ElapsedTime2,position(X2,Y2),Shape1,Color1),
 	 	  				 	observ3(ElapsedTime3,position(X3,Y3),Shape3,Color3),
 	 	  				 	CurvedTrajectory2,
 	 	  				 	CF2)
 	 	  		   )),
 	 	  %Ensure the frame for ElapsedTime2 is adjacent to the frame for ElapsedTime3
 	 	  %Constraint 3 is unnecessary since the parser already ensures this
	 	  /*3:compute(twoFramesAreAdjacent(ElapsedTime2,ElapsedTime3,FigureId)),*/
 	 	  
 	 	  4:compute((%Check that COBFErrorMeasure2 is sufficiently small
 	 	  		     %Multiply the number of positions by the max allowable error, since the error limit is per position (on average) 
 	 	  		     setting(maxAllowableErrorForCircleOfBestFitPerPositionOnAverage(MaxAllowableErrorForCircleOfBestFitPerPositionOnAverage)),
	  				 delayableDisjunctedCalls([PositionList2,COBFErrorMeasure2],
	  				 	(length(PositionList2,NumberOfPositions2),
	  				 	 MaxAllowableErrorForCircleOfBestFit2 is NumberOfPositions2 * MaxAllowableErrorForCircleOfBestFitPerPositionOnAverage,
	  				 	 COBFErrorMeasure2 =< MaxAllowableErrorForCircleOfBestFit2))
 	 	  		   )),
 	 	  5:compute(figureMovesWithConsistentWigglyPattern(DirectionSign1,DirectionSign2,COBFRc1,COBFRc2)),
 	 	  6:compute((%Collect positions that define the wiggle. We will use the positions to calculate line/circle of best fit
 	 	 			 %Combine WigglePositionList1 with WigglePositionList2 and use for curve fitting
					 WigglePositionList2 = [(X3,Y3)],
					 append(WigglePositionList1,WigglePositionList2,WigglePositionList)
				   )),
		  7:compute((% If TrajectoryOfBestFit1 is undefined, don't do anything. Constraint 8
		 		     %will handle it properly. Otherwise, from TrajectoryOfBestFit1 find AccelTriplets1 and then combine
		 		     %AccelTriplets1 and AccelTriplet2 and use as the trajectory of best fit's acceleration profile.
		  		     %//TODO If the acceleration values, and not just the signs, are important, then each of the values would
		  		     %	     need to be projected in the direction of the trajectory of best fit
		  		     (TrajectoryOfBestFit1 = undefined ->
		  		   		  true
		  		     ;	
		  		   		  (TrajectoryOfBestFit1 = linearMovingTrajectory(_LastPosition1,
																		 _Magnitude1,
																		 acceleration(AccelTriplets1),
																		 _LTOBFPositionList )
						  ;
						   TrajectoryOfBestFit1 = curvedTrajectory(_SecondToLastPosition1,
	                     					 					   _SecondToLastElapsedTime1,
	                     					 					   _LastPosition1,
	                     					 					   _LatestProjectedCircle1,
	                     					 					   _Magnitude1,
	                     					 					   acceleration(AccelTriplets1),
	                     					 					   _CTOBFPositionList,
	                     					 					   _CTOBFCircleOfBestFit )
	                      ),
		  		   		  delayableDisjunctedCalls([AccelTriplet2],append([AccelTriplet2],AccelTriplets1,AccelTriplets3)) 
		  		     )
		  		   )),
		  8:compute((%Calculate trajectory of best fit(TrajectoryOfBestFit), unless TrajectoryOfBestFit1 is undefined, in which case 
		 		     %TrajectoryOfBestFit should be undefined as well.
		 		     (TrajectoryOfBestFit1 = undefined ->
		 		   		  TrajectoryOfBestFit = undefined
		 		     ;  
 	 	  		   		  findTrajectoryOfBestFit(WigglePositionList,(XMagn2,YMagn2),ElapsedTime2,ElapsedTime3,AccelTriplets3,TrajectoryOfBestFit)
 	 	  		     )
 	 	  		   )),
 	 	  9:compute(combineConfidenceFactors([CF1,CF2],CF)),
 	 	  %Constraints 10 & 11 are attempts to reduce duplicates.
 	 	  %Constraint 10 checks whether there exists a duplicate of the component wiggle covering ElapsedTime1 to ElapsedTime2 with a higher CF value.
 	 	  %The constraint is satisfied if and only if such a duplicate does not exist.
 	 	  10:compute((Constraint = (findall(CF3,
 	 	 								    (findAnyCorroboratingEdge(_SpanEnd1,_SpanEnd2,
 	 	 								   							  wiggle(FigureId,
 	 																		 ElapsedTime1,ElapsedTime2,
 	 																		 _LatestProjectedCircle2,
 	 																		 _COBFRc3,
 	 																		 _WigglePositionList3,
 	 				    													 _TrajectoryOfBestFit2,
 	 				    													 _Originally,
 	 																		 CF3,
 	 																		 _DrawInstrs2
 	 				  													    ),
 	 				  												  _CF4,_ParentId,_RHS_parsedParts
 	 				  												 ),
 	 				  						 %We don't want to compare bounded reals, float/2 will convert the CFs to float values if the
 	 				  					     %CFs are indeed bounded reals.
 	 				  						 FloatCF3 is float(CF3),
 	 				  						 FloatCF1 is float(CF1),
 	 				  						 FloatCF3 > FloatCF1
 	 				  					    ),
 	 				  					    []
 	 				  					   )
 	 	 						   ),
 	 	 			  %Delay if the second effect has not been matched, i.e. ElapsedTime3 is not yet bound.
 	 	 			  %This will ensure all duplicates have already been generated.
 	 	 			  delayableDisjunctedCalls([ElapsedTime3],Constraint)
 	 	 		    )),
 	 	  %Constraint 11 checks whether there exists a duplicate of the high level wiggle covering ElapsedTime1 to ElapsedTime3 
 	 	  %with a higher CF value. The constraint is satisfied if and only if there's no such duplicate. While constraint 10 guards against duplicates
 	 	  %caused by duplicates of the wiggle component covering the same time period (ElapsedTime1 to ElapsedTime2), constraint 11 guards against
 	 	  %duplicates formed by a wiggle component covering a different time period (ElapsedTime1 to ElapsedTime2b, where ElapsedTime2b \= ElapsedTime2)  
 	 	  11:compute((Constraint2 = (findall(CF5,
 	 	 								     (findAnyCorroboratingEdge(_SpanEnd3,_SpanEnd4,
 	 	 								   							   wiggle(FigureId,
 	 	 								   									  ElapsedTime1,ElapsedTime3,
 	 				   														  _LatestProjectedCircle3,
 	 																		  _COBFRc4,
 	 																		  _WigglePositionList4,
 	 				    													  _TrajectoryOfBestFit3,
 	 				    													  _Originally2,
 	 																		  CF5,
 	 																		  _DrawInstrs3
 	 				  														 ),
 	 				  												   _CF6,_ParentId2,_RHS_parsedParts2
 	 				  												  ),
 	 				  					      %We don't want to compare bounded reals, float/2 will convert the CFs to float values if the
 	 				  					   	  %CFs are indeed bounded reals.
 	 				  					   	  FloatCF5 is float(CF5),
 	 				  					      FloatCF is float(CF),
 	 				  					      FloatCF5 > FloatCF
 	 				  					     ),
 	 				  					     []
 	 				  					    )
 	 				  			    ),
 	 				  delayableDisjunctedCalls([CF],Constraint2)
 	 			    )),
 	 	  %Generate draw instrs
 	 	  12:compute((RuleLHSWithoutDIWithCFReplaced = wiggle(FigureId,
 	 				   										  ElapsedTime1,ElapsedTime3,
 	 				   										  originally(Shape1,Color1),
 	 				   										  cv),
 	 				  Constraint3 =  (TrajectoryOfBestFit = linearMovingTrajectory(_,_,_,_) ->
 	 				  					TrajectoryOfBestFitType = linear
 	 				  			     ;
 	 				  					(TrajectoryOfBestFit = curvedTrajectory(_,_,_,_,_,_,_,_) ->
 	 				  						TrajectoryOfBestFitType = curved
 	 				  					;
 	 				  						TrajectoryOfBestFitType = undefined
 	 				  					)
 	 				  			     ),  
 	 				  delayableDisjunctedCalls([TrajectoryOfBestFit],Constraint3),
 	 				  generatePositionList(FigureId,ElapsedTime1,ElapsedTime3,PositionListForDI),  
 	 				  genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime3,
			  		 					 RuleLHSWithoutDIWithCFReplaced,CF,[PositionListForDI],
			  		 					 [TrajectoryOfBestFitType],
			  		 					 wiggle,DrawInstrs)
 	 	  			))	  
 	 	 ])).