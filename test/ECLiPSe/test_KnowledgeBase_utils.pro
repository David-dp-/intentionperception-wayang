
test_KnowledgeBase_utils :-
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
	figureIsStationary(1,
					observ1(0,position(2,2),circle(13), color(51, 255, 0)),
					observ2(41,position(2,2),circle(13), color(51, 255, 0)),
					stationaryTrajectory(originalPosition(2,2))),
	figureIsStationary(1,
					observ1(0,position(2,2),circle(13), color(51, 255, 0)),
					observ2(41,position(3,3),circle(13), color(51, 255, 0)),
					stationaryTrajectory(originalPosition(2,2))),
	
	XMagn is 3/41,
	YMagn is 3/41,
	figureMovesLinearly(1,
	 					observ1(0,position(3,3),circle(13), color(51, 255, 0)),
	 					observ2(41,position(6,6),circle(13), color(51, 255, 0)),
	 					linearMovingTrajectory(	lastPosition(6,6),
									magnitude(XMagn,YMagn))),
	
	%//TODO figureMovesCurvilinearly
	
	setting(maxAllowableErrorInMagnitude(MaxAllowableErrorInMagnitude)),
	Magn1 = 5,
	Magn2 is 5 - MaxAllowableErrorInMagnitude,
	magnitudesAreWithinErrorRange(Magn1,Magn2),
	
	%regularityFromForce
	
	euclideanDistance(3, 4, 6, 8, 5.0),
	
	figureIs2DCoherentBetweenFrames(
					1,
					observ1(0,position(2,3),circle(13),color(51, 255, 0)),
					observ2(41,position(5,6),circle(13),color(51, 255, 0)) ),		
	not(figureIs2DCoherentBetweenFrames(
					1,
					observ1(0,position(2,3),circle(13),color(51, 255, 0)),
					observ2(41,position(100,200),circle(13),color(51, 255, 0)) ) ),
					
	figureMaintainsAreaBetweenFrames(	
									1,
									0,
									circle(13),
									41,
									circle(13) ),
									
	areaChangeBetweenFrames(circle(13),circle(30),41),
	
	figureMaintainsShapeBetweenFrames(	
									1,
									0,
									circle(13),
									41,
									circle(30) ),
									
	shapeChangeBetweenFrames(circle(13),square(10,90)),
	
	figureMaintainsColorBetweenFrames(	
									1,
									0,
									color(51, 255, 0),
									41,
									color(51, 255, 0)),
									
	colorChangeBetweenFrames(color(51, 255, 0),color(0, 0, 0),41),
	
	figureDoesntFlickerAcrossFrames(
								1,
								0,
								2,
								3,
								4,
								5,
								circle(13),
								41 ),
								
	flickerDueToDistanceTravelled(circle(13),300),
	
	setting(maxElapsedTimeToAvoidFlicker(MaxElapsedTimeToAvoidFlicker)),
	ElapsedTime1 = 0,
	ElapsedTime2 is ElapsedTime1 + MaxElapsedTimeToAvoidFlicker + 1,
	flickerDueToSlowShutterDuringMovement(ElapsedTime1,ElapsedTime2),
	
	distanceTravelledAcrossFramesIsPerceptible(
									true,
									1,
									observ1(0,position(0,0)),
									observ2(41,position(3,5)) ),
	distanceTravelledAcrossFramesIsPerceptible(
									false,
									1,
									observ1(0,position(0,0)),
									observ2(41,position(1,1)) ),
									
	incrementConfidenceAsymptotically(0.4,0.4,0.5),
	
	invertTrajectory(	stationaryTrajectory( originalPosition(2,2) ),
				stationaryTrajectory( originalPosition(2,2) )),
	invertTrajectory(	linearMovingTrajectory(lastPosition(6,6),
									magnitude(5,5) ),
				linearMovingTrajectory(lastPosition(6,6),
									magnitude(-5,-5) )),
									
	extractPositionFromTrajectory(	stationaryTrajectory(
									originalPosition(5,6) ),
							position(5,6) ),
	extractPositionFromTrajectory(	linearMovingTrajectory(
									lastPosition(5,6),
									magnitude(3,4) ),
							position(5,6) ),
							
	makeNonResistiveStationaryTrajectory(	position(2,3),
									stationaryTrajectory(originalPosition(2,3)) ),
	
	onInterceptCourse(	
					circle(13),
					linearMovingTrajectory(
									lastPosition(3,4),
									magnitude(1,1) ),
					circle(13),
					stationaryTrajectory(
									originalPosition(7,8) )),
	onInterceptCourse(	
					circle(13),
					stationaryTrajectory(
									originalPosition(7,8) ),
					circle(13),
					linearMovingTrajectory(
									lastPosition(3,4),
									magnitude(1,1) ) ),
	 %negative time, i.e. collision that occurs in the past,
	 %should not be allowed
	not (onInterceptCourse(
					circle(0.3),
					linearMovingTrajectory(
									lastPosition(3,4),
									magnitude(1,1) ),
					circle(0.3),
					stationaryTrajectory(
									originalPosition(2,3) ) ) ),
	onInterceptCourse(	
					circle(13),
					linearMovingTrajectory(
									lastPosition(3,4),
									magnitude(1,1) ),
					circle(13),
					linearMovingTrajectory(
									lastPosition(5,4),
									magnitude(-1,1) )),
	onInterceptCourse( circle(13),
					stationaryTrajectory(originalPosition(0,0)),
					circle(13),
					stationaryTrajectory(originalPosition(1,1)) ),
					
	estimateRadiusFromShapeArea(circle(4),2),
	estimateRadiusFromShapeArea(oval(8,5,2),4.0),
	sqrt(31416,SideLength),
	estimateRadiusFromShapeArea(square(SideLength,90),100.0),
	estimateRadiusFromShapeArea(rectangle(7854,90,4),100.0),
	estimateRadiusFromShapeArea(triangle(1,2,3,4,5,6,31416),100.0),
	estimateRadiusFromShapeArea(polygonSides(5),0.0),
	estimateRadiusFromShapeArea(unrecognizedShape,0.0),
	
	onInterceptCourse1( posRadiusAndVelocity(0, 0, 13, 0.0, 0.0),
				    posRadiusAndVelocity(1, 1, 13, 0.0, 0.0),
				    0 ),
	onInterceptCourse1(	posRadiusAndVelocity(0, 0, 13, 1.0, 1.0),
					posRadiusAndVelocity(27, 1, 13, 0.0, 0.0),
					1.0 ),
					
	findIntersectionOfLines(twoPoints((0,0),(1,2)),
									twoPoints((0,2),(4,2)),
									intersection(1.0, 2.0)),
	findIntersectionOfLines(twoPoints((0.5,0),(0.5,1)),
									twoPoints((0,2),(1,1)),
									intersection(0.5, 1.5)),
	not(findIntersectionOfLines(twoPoints((0,0),(1,2)),
										 twoPoints((0,4),(1,6)),
										 intersection(_X1, _Y1)) ),
	not(findIntersectionOfLines(twoPoints((1,0),(1,1)),
										 twoPoints((2,0),(2,1)),
										 intersection(_X1, _Y1)) ),
	
	circleThroughThreePoints(-1, 0, 0, 1, 1, 0, -0.0, 0.0, 1.0),
	
	angleBetweenTwoVectors(0,1,1,0,0,0,90.0,-1),
	
	dotProduct(1,1,3,4,0,0,7),
	
	crossProduct(1,1,3,4,0,0,1),
	
	collinearOrdered( (1,1),(2,2),(3,3) ),
	collinearOrdered( (1,1),(2,2),(1.9,1.9) ),
	collinearOrdered( (1,1),(2,2),(2,2) ),
	collinearOrdered( (1,1),(1,1),(2,2) ),
	not (collinearOrdered( (1,1),(5,5),(2,2) )),
	
	bellCurve(mu(0),sigma(20),60,0.011108996538242301),
	bellCurve(mu(0),sigma(10),0,1.0),
	
	fourthPointLiesWithinCircleFormedFromFirstThreePoints((-1,0),(0,1),
																			(1,0),(0,0)),
	not(fourthPointLiesWithinCircleFormedFromFirstThreePoints((-1,0),(0,1),
																			(1,0),(2,0)) ),
	
	pointLiesOnWhichSideOfTheLine(twoPointsOfTheLine((0,0),(1,1)),(5,1),less),
	pointLiesOnWhichSideOfTheLine(twoPointsOfTheLine((0,0),(1,0)),(3,1),greater),
	pointLiesOnWhichSideOfTheLine(twoPointsOfTheLine((1,1),(0,1)),(-1,2),greater),
	
	pointLiesOnCorrectSideOfTheLine(twoPointsOfTheLine((0,0),(1,1)),(5,1),less),
	pointLiesOnCorrectSideOfTheLine(twoPointsOfTheLine((0,0),(1,0)),(3,1),greater),
	pointLiesOnCorrectSideOfTheLine(twoPointsOfTheLine((1,1),(0,1)),(-1,2),greater),
	
	delayableMin([-1,2,3],-1).
	