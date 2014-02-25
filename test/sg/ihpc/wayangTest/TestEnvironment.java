package sg.ihpc.wayangTest;

import java.io.FileReader;
import java.io.IOException;
import java.util.Properties;

import sg.ihpc.wayang.Constants;

public class TestEnvironment {

	private static FileReader s_oFileReader;
	private static Properties s_oProperties;
	private static Integer s_iShapesFudgeFactor;
	private static Float s_flTwipsPerSpatialUnit;
	private static Float s_flPixelsPerTwip;
	private static PerceptualLimits s_oPerceptualLimits;
	private static Float s_flMaxAllowableErrorInMagnitude;
	private static Float s_flMaxAllowableErrorInAcceleration;
	private static Float s_flMaxAllowableErrorInDegrees;
	private static Float s_flMaxAllowableErrorForLineOfBestFitPerPositionOnAverage;
	private static Float s_flMaxAllowableErrorForCircleOfBestFitPerPositionOnAverage;
	private static Float s_flMaxAllowableRatioForWiggleDefiningCOBFs;
	private static Float s_flMaxElapsedTimeOfStationaryTrajectoryForNotice;
	private static Float s_flMinElapsedTimeOfStationaryTrajectoryForNotice;
	private static Float s_flMaxDistanceToNoticedObject;
	private static Float s_flMaxLinearSegmentLengthForDoubleIntentionsOrForces;
	private static Float s_flMaxLinearSegmentLengthForCurvedTrajectory;
	private static Integer s_iWiggleBaseStepWithOverlapNumberOfFrames;
	private static Integer s_iMaxIncompleteEdgeQueueSize;
	private static Integer s_iGraphWidth;
	private static Integer s_iGraphHeight;
	private static Integer s_iGraphNodeSeparation;
	private static Integer s_iGraphMargin;
	private static Integer s_iGraphNumDifferentArcWidths;
	private static String s_loggingMethod;
	private static String s_loggingLevel;
	
	private static TestEnvironment s_oTestEnvironment;
	
	private TestEnvironment() throws IOException {
		s_oFileReader = new FileReader("input/Wayang.properties");
		s_oProperties = new Properties();
	    s_oProperties.load(s_oFileReader);
        
	    s_iShapesFudgeFactor = Integer.valueOf(s_oProperties.getProperty(Constants.s_sMaxTwipsDiffBetweenHeightAndWidthForRecognizingCirclesAndSquares));
        s_flTwipsPerSpatialUnit = Float.valueOf(s_oProperties.getProperty(Constants.s_sTwipsPerSpatialUnit));
        s_flPixelsPerTwip = Float.valueOf(s_oProperties.getProperty(Constants.s_sPixelsPerTwip));
        s_flMaxAllowableErrorInMagnitude
        	= Float.valueOf(s_oProperties.getProperty(Constants.s_sMaxAllowableErrorInMagnitude));
        s_flMaxAllowableErrorInAcceleration
    		= Float.valueOf(s_oProperties.getProperty(Constants.s_sMaxAllowableErrorInAcceleration));
        s_flMaxAllowableErrorInDegrees
        	= Float.valueOf(s_oProperties.getProperty(Constants.s_sMaxAllowableErrorInDegrees));
        s_flMaxAllowableErrorForLineOfBestFitPerPositionOnAverage
        	= Float.valueOf(s_oProperties.getProperty(Constants.s_sMaxAllowableErrorForLineOfBestFitPerPositionOnAverage));
        s_flMaxAllowableErrorForCircleOfBestFitPerPositionOnAverage
    		= Float.valueOf(s_oProperties.getProperty(Constants.s_sMaxAllowableErrorForCircleOfBestFitPerPositionOnAverage));
        s_flMaxAllowableRatioForWiggleDefiningCOBFs
        	= Float.valueOf(s_oProperties.getProperty(Constants.s_sMaxAllowableRatioForWiggleDefiningCOBFs));
        s_flMaxElapsedTimeOfStationaryTrajectoryForNotice
    		= Float.valueOf(s_oProperties.getProperty(Constants.s_sMaxElapsedTimeOfStationaryTrajectoryForNotice));
        s_flMinElapsedTimeOfStationaryTrajectoryForNotice
        	= Float.valueOf(s_oProperties.getProperty(Constants.s_sMinElapsedTimeOfStationaryTrajectoryForNotice));
        s_flMaxDistanceToNoticedObject
        	= Float.valueOf(s_oProperties.getProperty(Constants.s_sMaxDistanceToNoticedObject));
        s_flMaxLinearSegmentLengthForDoubleIntentionsOrForces
        	= Float.valueOf(s_oProperties.getProperty(Constants.s_sMaxLinearSegmentLengthForDoubleIntentionsOrForces));
        s_flMaxLinearSegmentLengthForCurvedTrajectory
        	= Float.valueOf(s_oProperties.getProperty(Constants.s_sMaxLinearSegmentLengthForCurvedTrajectory));
        
        s_iWiggleBaseStepWithOverlapNumberOfFrames
        	= Integer.valueOf(s_oProperties.getProperty(Constants.s_sWiggleBaseStepWithOverlapNumberOfFrames));
        s_iMaxIncompleteEdgeQueueSize
    		= Integer.valueOf(s_oProperties.getProperty(Constants.s_sMaxIncompleteEdgeQueueSize));
        s_iGraphWidth
    		= Integer.valueOf(s_oProperties.getProperty(Constants.s_sGraphWidth));
        s_iGraphHeight
			= Integer.valueOf(s_oProperties.getProperty(Constants.s_sGraphHeight));
        s_iGraphNodeSeparation
			= Integer.valueOf(s_oProperties.getProperty(Constants.s_sGraphNodeSeparation));
        s_iGraphMargin
			= Integer.valueOf(s_oProperties.getProperty(Constants.s_sGraphMargin));
        s_iGraphNumDifferentArcWidths
			= Integer.valueOf(s_oProperties.getProperty(Constants.s_sGraphNumDifferentArcWidths));
        
        s_loggingMethod = s_oProperties.getProperty(Constants.s_sLoggingMethod);
        s_loggingLevel = s_oProperties.getProperty(Constants.s_sLoggingLevel);
        
        System.out.println("...Wayang settings:                 Shapes fudge factor            = "+s_iShapesFudgeFactor);
        System.out.println("                                   Twips per Spatial Unit          = "+s_flTwipsPerSpatialUnit);
        System.out.println("                                   Pixels per twip                 = "+s_flPixelsPerTwip);
        System.out.println("    Error to allow when comparing successive magnitudes            = "+s_flMaxAllowableErrorInMagnitude);
        System.out.println("    Error to allow when comparing successive accelerations         = "+s_flMaxAllowableErrorInAcceleration);
        System.out.println("    Upper limit before angle between 2 vectors becomes perceivable = "+s_flMaxAllowableErrorInDegrees);
        System.out.println("    Error to allow for line of best fit                            = "+s_flMaxAllowableErrorForLineOfBestFitPerPositionOnAverage);
        System.out.println("    Error to allow for circle of best fit                          = "+s_flMaxAllowableErrorForCircleOfBestFitPerPositionOnAverage);
        System.out.println("	Upper limit on ratio between 2 circles defining a wiggle       = "+s_flMaxAllowableRatioForWiggleDefiningCOBFs);
        System.out.println("    Maximum elapsed time of stationary trajectory for noticing     = "+s_flMaxElapsedTimeOfStationaryTrajectoryForNotice);
        System.out.println("    Minimum elapsed time of stationary trajectory for noticing     = "+s_flMinElapsedTimeOfStationaryTrajectoryForNotice);
        System.out.println("    Maximum distance between a noticed object and the one noticing = "+s_flMaxDistanceToNoticedObject);
        System.out.println("    Maximum linear segment length for double intentions or forces  = "+s_flMaxLinearSegmentLengthForDoubleIntentionsOrForces);
        System.out.println("    Maximum linear segment length for curved trajectory            = "+s_flMaxLinearSegmentLengthForCurvedTrajectory);
        System.out.println("    Number of frames matched by wiggle base step with overlap rule = "+ s_iWiggleBaseStepWithOverlapNumberOfFrames);
        System.out.println("    Maximum incomplete edge queue size                             = "+ s_iMaxIncompleteEdgeQueueSize);
        System.out.println("                                            Graph width            = "+s_iGraphWidth);
        System.out.println("                                           Graph height            = "+s_iGraphHeight);
        System.out.println("                                  Graph node separation            = "+s_iGraphNodeSeparation);
        System.out.println("                                           Graph margin            = "+s_iGraphMargin);
        System.out.println("                      Num different arc widths in graph            = "+s_iGraphNumDifferentArcWidths);
        System.out.println("                                         Logging method            = "+s_loggingMethod);
        System.out.println("                                         Logging level             = "+s_loggingLevel);
        
        s_oPerceptualLimits = new PerceptualLimits(s_oProperties);
	}
	static TestEnvironment getInstance() throws IOException {
		if (s_oTestEnvironment == null) {
			s_oTestEnvironment = new TestEnvironment();
		}
		return s_oTestEnvironment;
	}
	Integer getShapesFudgeFactor() {
		return s_iShapesFudgeFactor;
	}
	Float getTwipsPerSpatialUnit() {
		return s_flTwipsPerSpatialUnit;
	}
	Float getPixelsPerTwip() {
		return s_flPixelsPerTwip;
	}
	PerceptualLimits getPerceptualLimits() {
		return s_oPerceptualLimits;
	}
	Float getMaxAllowableErrorInMagnitude() {
		return s_flMaxAllowableErrorInMagnitude;
	}
	Float getMaxAllowableErrorInAcceleration() {
		return s_flMaxAllowableErrorInAcceleration;
	}
	Float getMaxAllowableErrorInDegrees() {
		return s_flMaxAllowableErrorInDegrees;
	}
	Float getMaxAllowableErrorForLineOfBestFitPerPositionOnAverage() {
		return s_flMaxAllowableErrorForLineOfBestFitPerPositionOnAverage;
	}
	Float getMaxAllowableErrorForCircleOfBestFitPerPositionOnAverage() {
		return s_flMaxAllowableErrorForCircleOfBestFitPerPositionOnAverage;
	}
	Float getMaxAllowableRatioForWiggleDefiningCOBFs() {
		return s_flMaxAllowableRatioForWiggleDefiningCOBFs;
	}
	Float getMaxElapsedTimeOfStationaryTrajectoryForNotice() {
		return s_flMaxElapsedTimeOfStationaryTrajectoryForNotice;
	}
	Float getMinElapsedTimeOfStationaryTrajectoryForNotice() {
		return s_flMinElapsedTimeOfStationaryTrajectoryForNotice;
	}
	Float getMaxDistanceToNoticedObject() {
		return s_flMaxDistanceToNoticedObject;
	}
	Float getMaxLinearSegmentLengthForDoubleIntentionsOrForces() {
		return s_flMaxLinearSegmentLengthForDoubleIntentionsOrForces;
	}
	Float getMaxLinearSegmentLengthForCurvedTrajectory() {
		return s_flMaxLinearSegmentLengthForCurvedTrajectory;
	}
	String getLoggingMethod() {
		return s_loggingMethod;
	}
	String getLoggingLevel() {
		return s_loggingLevel;
	}
	Integer getWiggleBaseStepWithOverlapNumberOfFrames() {
		return s_iWiggleBaseStepWithOverlapNumberOfFrames;
	}
	Integer getMaxIncompleteEdgeQueueSize() {
		return s_iMaxIncompleteEdgeQueueSize;
	}
	public Integer getGraphWidth() {
		return s_iGraphWidth;
	}
	public Integer getGraphHeight() {
		return s_iGraphHeight;
	}
	public Integer getGraphNodeSeparation() {
		return s_iGraphNodeSeparation;
	}
	public Integer getGraphMargin() {
		return s_iGraphMargin;
	}
	public Integer getGraphNumDifferentArcWidths() {
		return s_iGraphNumDifferentArcWidths;
	}
}
