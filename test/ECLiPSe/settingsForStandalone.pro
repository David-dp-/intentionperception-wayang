% This file stores all settings/parameters that are relevant for the clp and should be updated
% when the corresponding setting in Wayang.properties is updated. These stored settings can be
% referred to in standalone files.

:- dynamic storedSettings/1.

uploadSettings :- 
	StoredSettings = [minPerceptibleAreaChangePerMsec(0.4), 
							minPerceptibleChangeInPosition(1.0), 
							minPerceptibleArea(16.0), 
							minAreaOverDistanceToAvoidFlicker(6.0), 
							minPerceptibleRGBDifference(8.0),
							minPerceptibleAccelerationOverSpeedRatio(0.0008), 
							maxElapsedTimeToAvoidFlicker(90.0), 
							minPerceptibleColorChangePerMsec(0.5), 
							maxAllowableErrorInMagnitude(0.2),
							maxAllowableErrorInAcceleration(0.1), 
							maxAllowableErrorInDegrees(4.0),
							maxAllowableErrorForLineOfBestFitPerPositionOnAverage(4.0),
							maxAllowableErrorForCircleOfBestFitPerPositionOnAverage(4.0),
							maxAllowableRatioForWiggleDefiningCOBFs(20.0),
							maxElapsedTimeOfStationaryTrajectoryForNotice(410.0),
							minElapsedTimeOfStationaryTrajectoryForNotice(123.0),
							maxDistanceToNoticedObject(75.0),
							maxLinearSegmentLengthForDoubleIntentionsOrForces(40.0),
							maxLinearSegmentLengthForCurvedTrajectory(30.0),
							twipsPerSpatialUnit(32.9),
							pixelsPerTwip(0.05),
							msecsPerFrame(41),
							maxIncompleteEdgeQueueSize(48000),
							wiggleBaseStepWithOverlapNumberOfFrames(4)],
	assert(storedSettings(StoredSettings)).
	
:- uploadSettings.