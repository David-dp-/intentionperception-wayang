
test_perceptibilityFilter :-
	storeSettings([ minAreaOverDistanceToAvoidFlicker(4.0)
						 ,minPerceptibleChangeInPosition(2.0)
						 ,minPerceptibleArea(4.0)
						 ,minPerceptibleRGBDifference(8.0)
						 ,maxElapsedTimeToAvoidFlicker(90.0)
						 ,minPerceptibleAreaChangePerMsec(0.1)
						 ,minPerceptibleColorChangePerMsec(0.5)
						 ,maxAllowableErrorInMagnitude(0.1)
						 ,maxAllowableErrorInDegrees(3)
						]),
	hasRGBDifference(color(10,20,30), color(60,50,45), 95),
	hasApparentArea(triangle(2,0,2,120,2,240,55.0),55.0),
	hasApparentArea(circle(10),78.53975),
	hasApparentArea(oval(10,90,5),39.269875),
	hasApparentArea(square(10,90),100),
	hasApparentArea(rectangle(10,90,5),50),
	hasApparentArea(polygonSides(5),0.0),
	hasApparentArea(unrecognizedShape,0.0)
	.
