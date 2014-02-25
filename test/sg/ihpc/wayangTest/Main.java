package sg.ihpc.wayangTest;

import java.io.*;

import sg.ihpc.wayang.Constants;
import sg.ihpc.wayang.WorldToObserver;
import sg.ihpc.wayang.swf.SWFDescriber;
import sg.ihpc.wayang.swf.WorldModel_fromSWF;
import sg.ihpc.wayangTest.viz.IVizWindow;
import sg.ihpc.wayangTest.viz.VizWindow;

import com.parctechnologies.eclipse.EclipseException;

public class Main {

	private static TestEnvironment s_oEnv;
	private static SWFDescriber s_oSWFDescriber;
	private static IVizWindow s_oIViz;
	
	public static final void main(String[] asArgs) {
		try {
			s_oEnv = TestEnvironment.getInstance();
		    
		    s_oSWFDescriber = new SWFDescriber(	s_oEnv.getShapesFudgeFactor(),
		    									s_oEnv.getTwipsPerSpatialUnit() );
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		if (s_oEnv == null) {
			System.err.println("s_oEnv is null");
		}
		if (s_oSWFDescriber == null) {
			System.err.println("s_oSWFDescriber is null");
		}
		
		s_oIViz = VizWindow.getInstance(s_oEnv); //also makes viz appear
	}
	
	/* Used by the execute() methods of classes in TestItem.java
	 */
	public static void launchEclipseThread(	String sPathToKnowledgeBase1,
											String sPathToSWFInput,
											String sPathToTestFile1,
											String sTesterPredicate1 )
	throws EclipseException, IOException, IllegalAccessException
	{
		//Create a PrintWriter for writing draw instrs to a file
		//For every CLP session, create a new PrintWriter to write all draw instrs for that session
		final PrintWriter drawInstrPrintWriter = 
			new PrintWriter(new BufferedWriter(new FileWriter(Constants.s_sDrawInstrFilename)));
		final WorldModel_fromSWF oWorldModel
			= new WorldModel_fromSWF(	s_oSWFDescriber,
										sPathToSWFInput,
										s_oEnv.getPerceptualLimits(),
										s_oEnv.getMaxAllowableErrorInMagnitude(),
										s_oEnv.getMaxAllowableErrorInAcceleration(),
										s_oEnv.getMaxAllowableErrorInDegrees(),
										s_oEnv.getMaxAllowableErrorForLineOfBestFitPerPositionOnAverage(),
										s_oEnv.getMaxAllowableErrorForCircleOfBestFitPerPositionOnAverage(),
										s_oEnv.getMaxAllowableRatioForWiggleDefiningCOBFs(),
										s_oEnv.getMaxElapsedTimeOfStationaryTrajectoryForNotice(),
										s_oEnv.getMinElapsedTimeOfStationaryTrajectoryForNotice(),
										s_oEnv.getMaxDistanceToNoticedObject(),
										s_oEnv.getMaxLinearSegmentLengthForDoubleIntentionsOrForces(),
										s_oEnv.getMaxLinearSegmentLengthForCurvedTrajectory(),
										s_oEnv.getTwipsPerSpatialUnit(),
										s_oEnv.getPixelsPerTwip(),
										s_oEnv.getMaxIncompleteEdgeQueueSize(),
										s_oEnv.getWiggleBaseStepWithOverlapNumberOfFrames(),
										s_oEnv.getLoggingMethod(),
										s_oEnv.getLoggingLevel(),
										s_oIViz,
										drawInstrPrintWriter);
		final String 	sPathToKnowledgeBase = sPathToKnowledgeBase1,
						sPathToTestFile = sPathToTestFile1,
						sTesterPredicate = sTesterPredicate1;
		Runnable clpRunnable = new Runnable() {
			public void run() {
				try {
					WorldToObserver.go(	sPathToKnowledgeBase,
										sPathToTestFile,
										sTesterPredicate,
										oWorldModel );
					s_oIViz.indicateTestOutcome(oWorldModel.fbTestSucceeded());
					//Close the PrintWriter for writing draw instrs, since this CLP session has ended
					drawInstrPrintWriter.close();
				} catch (EclipseException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (IllegalAccessException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		};
		Thread clpThread = new Thread(clpRunnable, "clpThread");
		clpThread.start();
	}	
}


