package sg.ihpc.wayang;

public class Constants {
	
	static final public String s_sLoggingMethod = "loggingMethod";
	static final public String s_sLoggingLevel = "loggingLevel";
	
	static final public String s_sMinPerceptibleChangeInPosition = "minPerceptibleChangeInPosition";
	static final public String s_sMinPerceptibleArea = "minPerceptibleArea";
	static final public String s_sMinPerceptibleRGBDifference = "minPerceptibleRGBDifference";
	static final public String s_sMaxElapsedTimeToAvoidFlicker = "maxElapsedTimeToAvoidFlicker";
	static final public String s_sMinAreaOverDistanceToAvoidFlicker = "minAreaOverDistanceToAvoidFlicker";
	static final public String s_sMinPerceptibleAreaChangePerMsec = "minPerceptibleAreaChangePerMsec";
	static final public String s_sMinPerceptibleColorChangePerMsec = "minPerceptibleColorChangePerMsec";
	static final public String s_sMinPerceptibleAccelerationOverSpeedRatio = "minPerceptibleAccelerationOverSpeedRatio";
	
	static final public String s_sMaxTwipsDiffBetweenHeightAndWidthForRecognizingCirclesAndSquares
							= "maxTwipsDiffBetweenHeightAndWidthForRecognizingCirclesAndSquares";
    static final public String s_sTwipsPerSpatialUnit = "twipsPerSpatialUnit";
    static final public String s_sPixelsPerTwip = "pixelsPerTwip";
    static final public String s_sMaxAllowableErrorInMagnitude
    						= "maxAllowableErrorInMagnitude";
    static final public String s_sMaxAllowableErrorInAcceleration
    						= "maxAllowableErrorInAcceleration";
    static final public String s_sMaxAllowableErrorInDegrees
    						= "maxAllowableErrorInDegrees";
    static final public String s_sMaxAllowableErrorForLineOfBestFitPerPositionOnAverage 
    						= "maxAllowableErrorForLineOfBestFitPerPositionOnAverage";
    static final public String s_sMaxAllowableErrorForCircleOfBestFitPerPositionOnAverage 
							= "maxAllowableErrorForCircleOfBestFitPerPositionOnAverage";
    static final public String s_sMaxAllowableRatioForWiggleDefiningCOBFs 
    						= "maxAllowableRatioForWiggleDefiningCOBFs";
    static final public String s_sMaxElapsedTimeOfStationaryTrajectoryForNotice
							= "maxElapsedTimeOfStationaryTrajectoryForNotice";
    static final public String s_sMinElapsedTimeOfStationaryTrajectoryForNotice
    						= "minElapsedTimeOfStationaryTrajectoryForNotice";
    static final public String s_sMaxDistanceToNoticedObject 
    						= "maxDistanceToNoticedObject";
    static final public String s_sMaxLinearSegmentLengthForDoubleIntentionsOrForces
    						= "maxLinearSegmentLengthForDoubleIntentionsOrForces";
    static final public String s_sMaxLinearSegmentLengthForCurvedTrajectory 
    						= "maxLinearSegmentLengthForCurvedTrajectory";
    static final public String s_sWiggleBaseStepWithOverlapNumberOfFrames
    						= "wiggleBaseStepWithOverlapNumberOfFrames";
    static final public String s_sMsecsPerFrame = "msecsPerFrame";
    static final public String s_sMaxIncompleteEdgeQueueSize = "maxIncompleteEdgeQueueSize";
    
    static final public String s_sFunctor_Frame = "frame";
    static final public String s_sFunctor_Timestamp = "timestamp";
    static final public String s_sFunctor_Ground = "ground";
    static final public String s_sFunctor_Figure = "figure";
    static final public String s_sFunctor_Position = "position";
    static final public String s_sFunctor_Color = "color";
    
    static final public String s_sFunctor_UnrecognizedShape = "unrecognizedShape";
    static final public String s_sFunctor_Square = "square";
    static final public String s_sFunctor_Rectangle = "rectangle";
    static final public String s_sFunctor_Triangle = "triangle";
    static final public String s_sFunctor_PolygonSides = "polygonSides";
    static final public String s_sFunctor_Circle = "circle";
    static final public String s_sFunctor_Oval = "oval";
    
    static final public String s_sFunctor_List = "list";
    static final public String s_sFunctor_FigureHasTrajectory = "figureHasTrajectory";
    static final public String s_sFunctor_ExertForceOn = "exertForceOn";
    static final public String s_sFunctor_Intend = "intend";
    static final public String s_sFunctor_DummyTrigger = "dummyTrigger3";
    static final public String s_sFunctor_IntentionChange = "intentionChanged";
    
    static final public String s_sFunctor_Completed = "completed";
    static final public String s_sFunctor_Incomplete = "incomplete";
    
    static final public String s_sFunctor_Observation = "observation";
    static final public String s_sFunctor_Prediction = "prediction";
    
    //for CLP control & Visualization
    static final public String s_sFunctor_EndOfFrames = "endOfFrames";
    static final public String s_sFunctor_EdgeSummary = "edgeSummary";
    static final public String s_sFunctor_Draw = "draw";
    static final public String s_sFunctor_ListOfDIs = "listOfDIs";
    static final public String s_sFunctor_Mismatch = "mismatch";
    static final public String s_sFunctor_SawEndOfFrames = "sawEndOfFrames";
    static final public String s_sFunctor_FilteredFromPerception = "filteredFromPerception";
    static final public String s_sFunctor_Discontinuity = "discontinuity";
    static final public String s_sFunctor_Tip = "tip";
    
    static final public String s_sFunctor_DrawType_Stationary = "stationary";
    static final public String s_sFunctor_DrawType_Linear = "linear";
    static final public String s_sFunctor_DrawType_Curved = "curved";
    static final public String s_sFunctor_DrawType_SingleForce = "singleForce";
    static final public String s_sFunctor_DrawType_CombinedForces = "combinedForces";
    static final public String s_sFunctor_DrawType_IntentionToApproachOrAvoid = "intentionToApproachOrAvoid";
    static final public String s_sFunctor_DrawType_CombinedIntentionToApproachAndAvoid = "combinedIntentionToApproachAndAvoid";
    static final public String s_sFunctor_DrawType_IntentionToBeAtPosition = "intentionToBeAtPosition";
    static final public String s_sFunctor_DrawType_Notice = "notice";
    static final public String s_sFunctor_DrawType_IntentionToApproachAugmentedWithIntentionToAvoid = 
    	"intentionToApproachAugmentedWithIntentionToAvoid";
    static final public String s_sFunctor_DrawType_Wiggle = "wiggle";
    static final public String s_sFunctor_DrawType_TrajectoryFromWiggle = "trajectoryFromWiggle";
    static final public String s_sGraphWidth = "graphWidth";
    static final public String s_sGraphHeight = "graphHeight";
    static final public String s_sGraphNodeSeparation = "graphNodeSeparation";
    static final public String s_sGraphMargin = "graphMargin";
    static final public String s_sGraphNumDifferentArcWidths = "graphNumDifferentArcWidths";
    
    static final public String s_sDrawInstrFilename = "drawInstrs.txt";
}
