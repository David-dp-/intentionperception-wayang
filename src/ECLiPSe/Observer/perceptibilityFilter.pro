%DOC
% Remove any figures from arg1 that would not be perceptible, and set arg2
%  to the remaining figures, if any.
%
% Frames look like this:
% frame([timestamp(0),
%        ground(194, 141, color(255, 255, 255)),
%        figure(1, position(70, 58), rectangle(51, 150, 29), color(0, 102, 204))
%      ])
%
perceptibilityFilter(	frame([	ElapsedTime
								|[	ground(Width, Height, GroundColor)
									| FiguresIn  ]]),
						frame([	ElapsedTime
								|[	ground(Width, Height, GroundColor)
									| FiguresOut ]])) :-
	((FiguresIn = [])
	 -> FiguresOut = []
	 ;  (setting(minPerceptibleChangeInPosition(MinPerceptibleChangeInPosition)),
		 ((Width < MinPerceptibleChangeInPosition)
		  -> FiguresOut = []
		  ;  ((Height < MinPerceptibleChangeInPosition)
			  -> FiguresOut = []
			  ;  perceptibilityFilter1(	GroundColor,
			  							ElapsedTime,
			  							FiguresIn,
			  							FiguresOut ))))).
			  							
perceptibilityFilter1(_GroundColor, _ElapsedTime, [], []).
perceptibilityFilter1(
	GroundColor,
	ElapsedTime,
	[figure(Id,Position,Shape,Color) | TailFs],
	FiguresOut ) :-
	
	perceptibilityFilter1(GroundColor,ElapsedTime,TailFs,FiguresOut1),
	(figureIsPerceptible(Id,ElapsedTime,Shape,Color,GroundColor)
	 -> FiguresOut = [figure(Id,Position,Shape,Color) | FiguresOut1]
	 ;  FiguresOut = FiguresOut1 ).
	
figureIsPerceptible(FigureId,ElapsedTime,FigureShape,FigureColor,GroundColor) :-
	setting(minPerceptibleArea(MinPerceptibleArea)),
	hasApparentArea(FigureShape,ApparentArea),
	((ApparentArea >= MinPerceptibleArea)
	 -> true
	 ;  assert( filteredFromPerception(tooSmallToBeSeen(FigureId,ElapsedTime)) ),
	    !,fail ),
		
	setting(minPerceptibleRGBDifference(MinPerceptibleRGBDifference)),
	hasRGBDifference(FigureColor,GroundColor,RGBDifference),
	((RGBDifference >= MinPerceptibleRGBDifference)
	 -> true
	 ;  assert( filteredFromPerception(
	 				tooSimilarInColorToGroundToBeSeen(FigureId,ElapsedTime) )),
	    !,fail ).
	    
hasApparentArea(triangle(_,_,_,_,_,_,Area),Area).
hasApparentArea(circle(Diameter),Area) :-
	Radius is (Diameter / 2),
	^(Radius,2,RadiusSquared),
	Area is RadiusSquared * 3.14159.
hasApparentArea(oval(MajorDiameter,_,MinorDiameter),Area) :-
	Area is (MajorDiameter/2)*(MinorDiameter/2)*3.14159.
hasApparentArea(square(SideLength,_),Area) :-
	Area is SideLength*SideLength.
hasApparentArea(rectangle(MajorSide,_,MinorSide),Area) :-
	Area is MajorSide*MinorSide.
%//TODO? All other shapes are treated as invisible (hack)
hasApparentArea(_,0.0).

hasRGBDifference(color(R1,G1,B1), color(R2,G2,B2), Difference) :-
	RDiff is (R1 - R2),
	GDiff is (G1 - G2),
	BDiff is (B1 - B2),
	abs(RDiff, RDiff2),
	abs(GDiff, GDiff2),
	abs(BDiff, BDiff2),
	Difference is (RDiff2 + GDiff2 + BDiff2).