package sg.ihpc.wayang.swf;

import java.io.*;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.awt.Point;

import sg.ihpc.wayang.CLPUtils;
import sg.ihpc.wayang.Constants;
import sg.ihpc.wayang.WorldModel;
import sg.ihpc.wayangTest.PerceptualLimits;
import sg.ihpc.wayangTest.viz.IVizWindow;
import sg.ihpc.wayangTest.viz.VizGrapherArc;

import com.parctechnologies.eclipse.Atom;
import com.parctechnologies.eclipse.CompoundTerm;
import com.parctechnologies.eclipse.CompoundTermImpl;

public class WorldModel_fromSWF implements WorldModel {

	enum EpistemicStatus {
		OBSERVATION, PREDICTION
	}
	
	enum CurveDirection {
		CLOCKWISE,ANTICLOCKWISE
	}
	
	boolean _bErrorTermsSeenInOutput,
			_bCLPSawStop;
	PerceptualLimits _oPerceptualLimits;
	Float _flMaxAllowableErrorInMagnitude;
	Float _flMaxAllowableErrorInAcceleration;
	Float _flMaxAllowableErrorInDegrees;
	Float _flMaxAllowableErrorForLineOfBestFitPerPositionOnAverage;
	Float _flMaxAllowableErrorForCircleOfBestFitPerPositionOnAverage;
	Float _flMaxAllowableRatioForWiggleDefiningCOBFs;
	Float _flMaxElapsedTimeOfStationaryTrajectoryForNotice;
	Float _flMinElapsedTimeOfStationaryTrajectoryForNotice;
	Float _flMaxDistanceToNoticedObject;
	Float _flMaxLinearSegmentLengthForDoubleIntentionsOrForces;
	Float _flMaxLinearSegmentLengthForCurvedTrajectory;
	Float _flTwipsPerSpatialUnit;
	Float _flPixelsPerTwip;
	Integer _iMsecsPerFrame;
	Integer _iMaxIncompleteEdgeQueueSize;
	Integer _iWiggleBaseStepWithOverlapNumberOfFrames;
	String _sLoggingMethod;
	String _sLoggingLevel;
	IVizWindow _oIViz;
	int _iCountOfInjectedFrames = 0;
	PrintWriter drawInstrPrintWriter;
	
	ArrayDeque<CompoundTerm> _coQueueOfInputTerms;
	
	public WorldModel_fromSWF(	SWFDescriber oSWFDescriber,
								String sLocalPathToSwf,
								PerceptualLimits oPerceptualLimits,
								Float flMaxAllowableErrorInMagnitude,
								Float flMaxAllowableErrorInAcceleration,
								Float flMaxAllowableErrorInDegrees,
								Float flMaxAllowableErrorForLineOfBestFitPerPositionOnAverage,
								Float flMaxAllowableErrorForCircleOfBestFitPerPositionOnAverage,
								Float flMaxAllowableRatioForWiggleDefiningCOBFs,
								Float flMaxElapsedTimeOfStationaryTrajectoryForNotice,
								Float flMinElapsedTimeOfStationaryTrajectoryForNotice,
								Float flMaxDistanceToNoticedObject,
								Float flMaxLinearSegmentLengthForDoubleIntentionsOrForces,
								Float flMaxLinearSegmentLengthForCurvedTrajectory,
								Float flTwipsPerSpatialUnit,
								Float flPixelsPerTwip,
								Integer iMaxIncompleteEdgeQueueSize,
								Integer iWiggleBaseStepWithOverlapNumberOfFrames,
								String sLoggingMethod,
								String sLoggingLevel,
								IVizWindow oIViz,
								PrintWriter drawInstrPrintWriter)
	throws IOException
	{
		_bErrorTermsSeenInOutput = false;
		_bCLPSawStop = false;
		
		_oPerceptualLimits = oPerceptualLimits;
		_flMaxAllowableErrorInMagnitude = flMaxAllowableErrorInMagnitude;
		_flMaxAllowableErrorInAcceleration = flMaxAllowableErrorInAcceleration;
		_flMaxAllowableErrorInDegrees = flMaxAllowableErrorInDegrees;
		_flMaxAllowableErrorForLineOfBestFitPerPositionOnAverage = flMaxAllowableErrorForLineOfBestFitPerPositionOnAverage;
		_flMaxAllowableErrorForCircleOfBestFitPerPositionOnAverage = flMaxAllowableErrorForCircleOfBestFitPerPositionOnAverage;
		_flMaxAllowableRatioForWiggleDefiningCOBFs = flMaxAllowableRatioForWiggleDefiningCOBFs;
		_flMaxElapsedTimeOfStationaryTrajectoryForNotice = flMaxElapsedTimeOfStationaryTrajectoryForNotice;
		_flMinElapsedTimeOfStationaryTrajectoryForNotice = flMinElapsedTimeOfStationaryTrajectoryForNotice;
		_flMaxDistanceToNoticedObject = flMaxDistanceToNoticedObject;
		_flMaxLinearSegmentLengthForDoubleIntentionsOrForces = flMaxLinearSegmentLengthForDoubleIntentionsOrForces;
		_flMaxLinearSegmentLengthForCurvedTrajectory = flMaxLinearSegmentLengthForCurvedTrajectory;
		_flTwipsPerSpatialUnit = flTwipsPerSpatialUnit;
		_flPixelsPerTwip = flPixelsPerTwip;
		_iMaxIncompleteEdgeQueueSize = iMaxIncompleteEdgeQueueSize;
		_iWiggleBaseStepWithOverlapNumberOfFrames = iWiggleBaseStepWithOverlapNumberOfFrames;
		_sLoggingMethod = sLoggingMethod;
		_sLoggingLevel = sLoggingLevel;
		
		_oIViz = oIViz;
		
		_coQueueOfInputTerms = new ArrayDeque<CompoundTerm>();
        
		FileInputStream inputStream = new FileInputStream( sLocalPathToSwf );
		//extract FPS information from the SWF file and calculate msecs per frame
		_iMsecsPerFrame = 1000/oSWFDescriber.extractSWFFrameRate(inputStream);
		
		_coQueueOfInputTerms.add(this.foGenerateSettingsTerm());
        
		//Create another file input stream. Previous operation closed the stream. 
		inputStream = new FileInputStream( sLocalPathToSwf );
        _coQueueOfInputTerms.addAll(oSWFDescriber.fcoGenerateFrameTerms(inputStream));
        
        //Assign the given PrintWriter for use in printing draw instrs to a file
        this.drawInstrPrintWriter = drawInstrPrintWriter;
	}
	
	@Override
	public CompoundTerm foGetInputTerm() {
		boolean bEnoughFramesToJustifyPause = _iCountOfInjectedFrames > 1;
		_oIViz.considerEnablingNextFrameButton(bEnoughFramesToJustifyPause);
		
		boolean bToggleFalse_AdvanceAtNextFrameRequest = false;
		if (bEnoughFramesToJustifyPause &&
			_oIViz.getIControlState().getStopAfterEachFrame() )
		{
			if (_oIViz.getIControlState().getAdvanceAtNextFrameRequest()) {
				//Allow next frame to be injected, but toggle the control back
				// so that we are forced to wait for a button press before
				// injecting the following frame.
				bToggleFalse_AdvanceAtNextFrameRequest = true;
			} else {
				//Causes the test/clp thread to block
				_oIViz.indicateTestOutcomeNotYetKnown(true); //true means we're waiting for button press
				_oIViz.getNextFrameGuard().waitForButtonPress();
			}
		}
		CompoundTerm oInputTerm = _coQueueOfInputTerms.poll();
		if (oInputTerm == null) { //Happens when queue is empty
			oInputTerm = foEndOfFramesTerm();
		}
    	
    	//System.out.println("TERM IN: "+CLPUtils.toString(oInputTerm)); //DEBUG
    	
    	if (bToggleFalse_AdvanceAtNextFrameRequest) {
    		_oIViz.getIControlState().setAdvanceAtNextFrameRequest(false);
    	}
    	if (oInputTerm.functor().equals(Constants.s_sFunctor_Frame)) {
    		_iCountOfInjectedFrames++;
    	}
    	return oInputTerm;
	}
	
	@Override
	public void fHandleOutputTerm(CompoundTerm oTerm) {
		//System.out.println("TERM OUT: "+oTerm); //DEBUG
		if (oTerm == null) {
			//do nothing
		} else if (	Constants.s_sFunctor_EdgeSummary.equals(oTerm.functor()) ||
					Constants.s_sFunctor_Draw.equals(oTerm.functor()) ||
					Constants.s_sFunctor_ListOfDIs.equals(oTerm.functor()) ) {
			
			fVisualize(oTerm);
		} else if (Constants.s_sFunctor_Mismatch.equals(oTerm.functor())) {
			if (!_bErrorTermsSeenInOutput) { //Ignore all but the first mismatch
				_bErrorTermsSeenInOutput = true; //Never set to false once set to true
				_coQueueOfInputTerms.addFirst(foEndOfFramesTerm());			
				fVisualize(oTerm);
			}
		} else if (	Constants.s_sFunctor_SawEndOfFrames.equals(oTerm.functor()) ) {
			_bCLPSawStop = true;
		}
	}
	
	@Override
	public boolean fbTestSucceeded() {
		return !_bErrorTermsSeenInOutput && _bCLPSawStop;
	}

	
	CompoundTerm foGenerateSettingsTerm() {
        List<CompoundTerm> coSettings = new ArrayList<CompoundTerm>();
        
        coSettings = _oPerceptualLimits.appendLimitsAsTerms(coSettings);
        coSettings.add(new CompoundTermImpl(Constants.s_sMaxAllowableErrorInMagnitude,
        									_flMaxAllowableErrorInMagnitude ));
        coSettings.add(new CompoundTermImpl(Constants.s_sMaxAllowableErrorInAcceleration,
				_flMaxAllowableErrorInAcceleration ));
        coSettings.add(new CompoundTermImpl(Constants.s_sMaxAllowableErrorInDegrees,
        									_flMaxAllowableErrorInDegrees ));
        coSettings.add(new CompoundTermImpl(Constants.s_sMaxAllowableErrorForLineOfBestFitPerPositionOnAverage,
											_flMaxAllowableErrorForLineOfBestFitPerPositionOnAverage ));
        coSettings.add(new CompoundTermImpl(Constants.s_sMaxAllowableErrorForCircleOfBestFitPerPositionOnAverage,
											_flMaxAllowableErrorForCircleOfBestFitPerPositionOnAverage ));
        coSettings.add(new CompoundTermImpl(Constants.s_sMaxAllowableRatioForWiggleDefiningCOBFs,
											_flMaxAllowableRatioForWiggleDefiningCOBFs ));
        coSettings.add(new CompoundTermImpl(Constants.s_sMaxElapsedTimeOfStationaryTrajectoryForNotice,
											_flMaxElapsedTimeOfStationaryTrajectoryForNotice ));
        coSettings.add(new CompoundTermImpl(Constants.s_sMinElapsedTimeOfStationaryTrajectoryForNotice,
        									_flMinElapsedTimeOfStationaryTrajectoryForNotice ));
        coSettings.add(new CompoundTermImpl(Constants.s_sMaxDistanceToNoticedObject,
        									_flMaxDistanceToNoticedObject ));
        coSettings.add(new CompoundTermImpl(Constants.s_sMaxLinearSegmentLengthForDoubleIntentionsOrForces,
        		_flMaxLinearSegmentLengthForDoubleIntentionsOrForces ));	
        coSettings.add(new CompoundTermImpl(Constants.s_sMaxLinearSegmentLengthForCurvedTrajectory,
        		_flMaxLinearSegmentLengthForCurvedTrajectory ));	
        coSettings.add(new CompoundTermImpl(Constants.s_sTwipsPerSpatialUnit,
											_flTwipsPerSpatialUnit ));
        coSettings.add(new CompoundTermImpl(Constants.s_sPixelsPerTwip,
				_flPixelsPerTwip ));
        coSettings.add(new CompoundTermImpl(Constants.s_sMsecsPerFrame,
				_iMsecsPerFrame ));
        coSettings.add(new CompoundTermImpl(Constants.s_sMaxIncompleteEdgeQueueSize,
        		_iMaxIncompleteEdgeQueueSize ));
        coSettings.add(new CompoundTermImpl(Constants.s_sWiggleBaseStepWithOverlapNumberOfFrames,
        		_iWiggleBaseStepWithOverlapNumberOfFrames ));
        coSettings.add(new CompoundTermImpl(Constants.s_sLoggingMethod,
        									_sLoggingMethod ));
        coSettings.add(new CompoundTermImpl(Constants.s_sLoggingLevel,
        		      						_sLoggingLevel ));
        
        return new CompoundTermImpl("settings", coSettings);
	}
	
    /*
     * The format of the last terms sent to the inference engine will always be
     * 
     *   endOfFrames
     *   
     * These terms are provided by FrameTermProducer (the class that calls this method) whenever it receives a request
     * for a frame after coOut has been exhausted.
     */
    static CompoundTerm foEndOfFramesTerm() {
    	return new Atom(Constants.s_sFunctor_EndOfFrames);
    }

	public void fVisualize(CompoundTerm oTerm) {
		if (oTerm == null) {
			System.err.println("fVisualize was passed a null CompoundTerm.");
		} else if (Constants.s_sFunctor_FilteredFromPerception.equals(oTerm.functor())) {
			//TODO
		} else if (Constants.s_sFunctor_Discontinuity.equals(oTerm.functor())) {
			//TODO
		} else if (Constants.s_sFunctor_Tip.equals(oTerm.functor())) {
			//TODO
		} else if (Constants.s_sFunctor_Draw.equals(oTerm.functor())) {

			fVisualize_draw(oTerm);
		} else if (Constants.s_sFunctor_ListOfDIs.equals(oTerm.functor())) {
			int Arity = oTerm.arity();
			for (int i = 1 ; i <= Arity ; i++) {
				fVisualize_draw((CompoundTerm)oTerm.arg(i));
			}
		} else if (Constants.s_sFunctor_EdgeSummary.equals(oTerm.functor())) {
			/* TODO Temporarily disable this functionality. Changes are required for
			this part of the visualizer to work properly with the new indexing method.*/ 
			//fVisualize_edgeSummary(oTerm, VizGrapherArc.AMismatch.NO);
		} else if (Constants.s_sFunctor_Mismatch.equals(oTerm.functor())) {
			/* TODO Temporarily disable this functionality. Changes are required for
			this part of the visualizer to work properly with the new indexing method */
			//fVisualize_mismatch(oTerm);
		}
	}
	void fVisualize_draw(CompoundTerm oTerm) {
		//Note: term arg indices start at 1, not 0, as documented here:
		// http://87.230.22.228/doc/javadoc/JavaEclipseInterface/com/parctechnologies/eclipse/CompoundTerm.html#arg(int)
		//
		//Below are the formats of all draw terms that the CLP might pass.
		//Throughout the body of this method fields are accessed using indices corresponding to the positions in these terms
		//
		//draw(linear(EpistemicStatusString,DrawIDInt,listOfRHSMatchingAncestorDrawIds(RHSMatchingAncestorDrawIDInt1,RHSMatchingAncestorDrawIDInt2,...),FigureIDInt,EndingFrameNumberInt,
		//			  LHSStringModified,LHSFunctorString,StartingMSecsInt,EndingMSecsInt,ConfidenceFactorFloat,graphicalDisplayForLinearTrajectory(color(RInt,GInt,BInt),
		//			  XCoordInPx,YCoordInPx,circle(DInPx),XCoordInSUString,YCoordInSUString,XMagnInSUString,YMagnInSUString)))
		//draw(stationary(EpistemicStatusString,DrawIDInt,listOfRHSMatchingAncestorDrawIds(RHSMatchingAncestorDrawIDInt1,RHSMatchingAncestorDrawIDInt2,...),FigureIDInt,EndingFrameNumberInt,
		//				  LHSStringModified,LHSFunctorString,StartingMSecsInt,EndingMSecsInt,ConfidenceFactorFloat,
		//				  graphicalDisplayForStationaryTrajectory(color(RInt,GInt,BInt),XCoordInPx,YCoordInPx,circle(DInPx),XCoordInSUString,YCoordInSUString)))
		//draw(curved(EpistemicStatusString,DrawIDInt,listOfRHSMatchingAncestorDrawIds(RHSMatchingAncestorDrawIDInt1,RHSMatchingAncestorDrawIDInt2,...),FigureIDInt,EndingFrameNumberInt,
		//			  LHSStringModified,LHSFunctorString,StartingMSecsInt,EndingMSecsInt,ConfidenceFactorFloat,
		//			  graphicalDisplayForCurvedTrajectory(color(RInt,GInt,BInt),XCoordInPx,YCoordInPx,COBFXcInPx,COBFYcInPx,COBFRcInPx,circle(DInPx),XCoordInSUString,YCoordInSUString,
		//												  XMagnInSUString,YMagnInSUString,COBFXcInSUString,COBFYcInSUString,COBFRcInSUString,COBFErrorMeasureInSUString,DirectionSignString)))
		//draw(singleForce(EpistemicStatusString,DrawIDInt,listOfRHSMatchingAncestorDrawIds(RHSMatchingAncestorDrawIDInt1,RHSMatchingAncestorDrawIDInt2,...),ExertedUponIdInt,EndingFrameNumberInt,
		//				   LHSStringModified,LHSFunctorString,StartingMSecsInt,EndingMSecsInt,ConfidenceFactorFloat,
		//				   graphicalDisplayForSingleForce(color(RInt,GInt,BInt),listOfPositions(position(X1InPx,Y1InPx),position(X2InPx,Y2InPx),...),circle(DInPx),AttractiveOrRepulsiveString,
		//												  ForceMagnitudeString,ExertingIDString)))
		//draw(combinedForces(EpistemicStatusString,DrawIDInt,listOfRHSMatchingAncestorDrawIds(RHSMatchingAncestorDrawIDInt1,RHSMatchingAncestorDrawIDInt2,...),ExertedUponIdInt,EndingFrameNumberInt,
		//					  LHSStringModified,LHSFunctorString,StartingMSecsInt,EndingMSecsInt,ConfidenceFactorFloat,
		//					  graphicalDisplayForCombinedForces(color(RInt,GInt,BInt),listOfPositions(position(X1InPx,Y1InPx),position(X2InPx,Y2InPx),...),circle(DInPx),
        //														RepulsiveForceMagnitudeInSpatialUnitsString,AttractiveForceMagnitudeInSpatialUnitsString,RepulsorIDString,AttractorIDString)))
		//draw(intentionToApproachOrAvoid(EpistemicStatusString,DrawIDInt,listOfRHSMatchingAncestorDrawIds(RHSMatchingAncestorDrawIDInt1,RHSMatchingAncestorDrawIDInt2,...),FigureIdInt,EndingFrameNumberInt,
		//								  LHSStringModified,LHSFunctorString,StartingMSecsInt,EndingMSecsInt,ConfidenceFactorFloat,
		//								  graphicalDisplayForIntentionToApproachOrAvoid(color(RInt,GInt,BInt),listOfPositions(position(X1InPx,Y1InPx),position(X2InPx,Y2InPx),...),circle(DInPx),
		//																				ApproachOrAvoidString,TargetFigureIDString)))
		//draw(intentionToBeAtPosition(EpistemicStatusString,DrawIDInt,listOfRHSMatchingAncestorDrawIds(RHSMatchingAncestorDrawIDInt1,RHSMatchingAncestorDrawIDInt2,...),FigureIdInt,EndingFrameNumberInt,
		//							   LHSStringModified,LHSFunctorString,StartingMSecsInt,EndingMSecsInt,ConfidenceFactorFloat,
		//							   graphicalDisplayForIntentionToBeAtPosition(color(RInt,GInt,BInt),listOfPositions(position(X1InPx,Y1InPx),position(X2InPx,Y2InPx),...),circle(DInPx),
		//																		  FigureXCoordInSpatialUnitsString,FigureYCoordInSpatialUnitsString)))
		//draw(notice(EpistemicStatusString,DrawIDInt,listOfRHSMatchingAncestorDrawIds(RHSMatchingAncestorDrawIDInt1,RHSMatchingAncestorDrawIDInt2,...),FigureIdInt,EndingFrameNumberInt,
		//			  LHSStringModified,LHSFunctorString,StartingMSecsInt,EndingMSecsInt,ConfidenceFactorFloat,
		//			  graphicalDisplayForNotice(color(RInt,GInt,BInt),listOfPositions(position(X1InPx,Y1InPx),position(X2InPx,Y2InPx),...),circle(DInPx),
		//										NoticedFigureIDString)))
		//draw(intentionToApproachAugmentedWithIntentionToAvoid(EpistemicStatusString,DrawIDInt,listOfRHSMatchingAncestorDrawIds(RHSMatchingAncestorDrawIDInt1,RHSMatchingAncestorDrawIDInt2,...),FigureIdInt,EndingFrameNumberInt,
		//			  											LHSStringModified,LHSFunctorString,StartingMSecsInt,EndingMSecsInt,ConfidenceFactorFloat,
		//			  											graphicalDisplayForIntentionToApproachAugmentedWithIntentionToAvoid(color(RInt,GInt,BInt),listOfPositions(position(X1InPx,Y1InPx),position(X2InPx,Y2InPx),...),circle(DInPx),
		//																															ApproachedFigureIDString,ThreatFigureIDString,StartElapsedTimeForIntentionToAvoidString)))
		//draw(wiggle(EpistemicStatusString,DrawIDInt,listOfRHSMatchingAncestorDrawIds(RHSMatchingAncestorDrawIDInt1,RHSMatchingAncestorDrawIDInt2,...),FigureIdInt,EndingFrameNumberInt,
		//			  LHSStringModified,LHSFunctorString,StartingMSecsInt,EndingMSecsInt,ConfidenceFactorFloat,
		//			  graphicalDisplayForWiggle(color(RInt,GInt,BInt),listOfPositions(position(X1InPx,Y1InPx),position(X2InPx,Y2InPx),...),circle(DInPx),
		//										TrajectoryOfBestFitTypeString)))
		//draw(trajectoryFromWiggle(EpistemicStatusString,DrawIDInt,listOfRHSMatchingAncestorDrawIds(RHSMatchingAncestorDrawIDInt1,RHSMatchingAncestorDrawIDInt2,...),FigureIdInt,EndingFrameNumberInt,
		//		  					LHSStringModified,LHSFunctorString,StartingMSecsInt,EndingMSecsInt,ConfidenceFactorFloat,
		//			 			 	graphicalDisplayForTrajectoryFromWiggle(color(RInt,GInt,BInt),listOfPositions(position(X1InPx,Y1InPx),position(X2InPx,Y2InPx),...),circle(DInPx),
		//																	TrajectoryTypeString,FigureXCoordInSpatialUnitsString,FigureYCoordInSpatialUnitsString,XMagInSpatialUnitsString,YMagInSpatialUnitsString)))
		//
		CompoundTerm oDrawType	= (CompoundTerm)oTerm.arg(1);
		if (oDrawType == null) {
			System.err.println("oDrawType is null in this compound term read from out-queue: "+oTerm);
			return;
		}
		String sTypePredicate	= (String)oDrawType.functor();
		//System.out.println("fVisualize_draw a DI of type: " + sTypePredicate );

		if (sTypePredicate == null) {
			System.err.println("sTypePredicate is null in this compound term read from out-queue: "+oDrawType);
			return;
		}
		
		//Extract values that are common across different types of draw instructions
		String sEpistemicStatus = (String)oDrawType.arg(1);
		if(sEpistemicStatus == null){
			System.err.println("sEpistemicStatus is null in this compound term read from out-queue: "+oDrawType);
			return;
		}
		EpistemicStatus eEpistemicStatus; 
		if(sEpistemicStatus.equals(Constants.s_sFunctor_Observation))
			eEpistemicStatus = EpistemicStatus.OBSERVATION;
		else if(sEpistemicStatus.equals(Constants.s_sFunctor_Prediction))
			eEpistemicStatus = EpistemicStatus.PREDICTION;
		else{
			System.err.println("sEpistemicStatus is invalid in this compound term read from out-queue: "+oDrawType);
			return;
		}
		Integer iDrawID = (Integer)oDrawType.arg(2);
		if(iDrawID == null){
			System.err.println("iDrawID is null in this compound term read from out-queue: "+oDrawType);
			return;
		}
		CompoundTerm oListOfRHSMatchingAncestorDrawIDs = (CompoundTerm)oDrawType.arg(3);
		if(oListOfRHSMatchingAncestorDrawIDs == null){
			System.err.println("oListOfRHSMatchingAncestorDrawIDs is null in this compound term read from out-queue: "+oDrawType);
			return;
		}
		int numberOfRHSMatchingAncestorDraws = oListOfRHSMatchingAncestorDrawIDs.arity();
		Integer[] aRHSMatchingAncestorDrawIDs = new Integer[numberOfRHSMatchingAncestorDraws]; 
		for(int i = 0 ; i < numberOfRHSMatchingAncestorDraws ; i++) {
			aRHSMatchingAncestorDrawIDs[i] = (Integer)oListOfRHSMatchingAncestorDrawIDs.arg(i+1);
			if(aRHSMatchingAncestorDrawIDs[i] == null){
				System.err.println("aRHSMatchingAncestorDrawIDs[" + i + "] is null in this compound term read from out-queue: " +
						oListOfRHSMatchingAncestorDrawIDs);
				return;
			}
		}
		Integer iFigureID = (Integer)oDrawType.arg(4);
		if(iFigureID == null){
			System.err.println("iFigureID is null in this compound term read from out-queue: "+oDrawType);
			return;
		}
		Integer iEndingFrameNumber = (Integer)oDrawType.arg(5);
		if(iEndingFrameNumber == null){
			System.err.println("iEndingFrameNumber is null in this compound term read from out-queue: "+oDrawType);
			return;
		}
		String sLHSStringModified = (String)oDrawType.arg(6);
		if(sLHSStringModified == null){
			System.err.println("sLHSStringModified is null in this compound term read from out-queue: "+oDrawType);
			return;
		}
		String sLHSFunctor = (String)oDrawType.arg(7);
		Integer iStartingMSecs = (Integer)oDrawType.arg(8);
		if(iStartingMSecs == null){
			System.err.println("iStartingMSecs is null in this compound term read from out-queue: "+oDrawType);
			return;
		}
		Integer iEndingMSecs = (Integer)oDrawType.arg(9);
		if(iEndingMSecs == null){
			System.err.println("iEndingMSecs is null in this compound term read from out-queue: "+oDrawType);
			return;
		}
		Double dConfidenceFactor = (Double)oDrawType.arg(10);
		if(dConfidenceFactor == null){
			System.err.println("fConfidenceFactor is null in this compound term read from out-queue: "+oDrawType);
			return;
		}
		
		//Extract values that are specific to the current type of draw instruction
		if(sTypePredicate.equals(Constants.s_sFunctor_DrawType_Linear)) {
			
			CompoundTerm oGraphicalDisplayForLinearTrajectory = (CompoundTerm)oDrawType.arg(11);
			if(oGraphicalDisplayForLinearTrajectory == null){
				System.err.println("oGraphicalDisplayForLinearTrajectory is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			CompoundTerm oColor = (CompoundTerm)oGraphicalDisplayForLinearTrajectory.arg(1);
			if(oColor == null){
				System.err.println("oColor is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iR = (Integer)oColor.arg(1);
			if(iR == null){
				System.err.println("iR is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iG = (Integer)oColor.arg(2);
			if(iG == null){
				System.err.println("iG is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iB = (Integer)oColor.arg(3);
			if(iB == null){
				System.err.println("iB is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iXCoordInPx = (Integer)oGraphicalDisplayForLinearTrajectory.arg(2);
			if(iXCoordInPx == null){
				System.err.println("iXCoordInPx is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iYCoordInPx = (Integer)oGraphicalDisplayForLinearTrajectory.arg(3);
			if(iYCoordInPx == null){
				System.err.println("iYCoordInPx is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			CompoundTerm oShape = (CompoundTerm)oGraphicalDisplayForLinearTrajectory.arg(4);
			if(oShape == null){
				System.err.println("oShape is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			//sShapeType will eventually be used to check what shape it is. If it is circle, for example, a new Circle object
			//will be created to be passed in the call to the viz draw.
			String sShapeType = (String)oShape.functor();
			if(sShapeType == null){
				System.err.println("sShapeType is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iDInPx = (Integer)oShape.arg(1);
			if(iDInPx == null){
				System.err.println("iDInPx is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			String sXCoordInSU = (String)oGraphicalDisplayForLinearTrajectory.arg(5);
			if(sXCoordInSU == null){
				System.err.println("sXCoordInSU is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			String sYCoordInSU = (String)oGraphicalDisplayForLinearTrajectory.arg(6);
			if(sYCoordInSU == null){
				System.err.println("sYCoordInSU is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			String sXMagnInSU = (String)oGraphicalDisplayForLinearTrajectory.arg(7);
			if(sXMagnInSU == null){
				System.err.println("sXMagnInSU is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			String sYMagnInSU = (String)oGraphicalDisplayForLinearTrajectory.arg(8);
			if(sYMagnInSU == null){
				System.err.println("sYMagnInSU is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			//For now just construct a draw instruction string in the required format. This will eventually be replaced by
			//an actual call to the visualizer
			StringBuilder drawInstr = new StringBuilder();
			drawInstr.append("draw(EpistemicStatus.");
			drawInstr.append(eEpistemicStatus);
			drawInstr.append(",");
			drawInstr.append(iDrawID);
			drawInstr.append(",");
			drawInstr.append("new ArrayList<Integer>(Arrays.asList(");
			for(int i = 0 ; i < numberOfRHSMatchingAncestorDraws - 1 ; i++){
				drawInstr.append(aRHSMatchingAncestorDrawIDs[i]);
				drawInstr.append(",");
			}
			drawInstr.append(aRHSMatchingAncestorDrawIDs[numberOfRHSMatchingAncestorDraws - 1]);
			drawInstr.append(")),");
			drawInstr.append(iFigureID);
			drawInstr.append(",");
			drawInstr.append(iEndingFrameNumber);
			drawInstr.append(",");
			drawInstr.append("\"");
			drawInstr.append(sLHSStringModified);
			drawInstr.append("\",\"");
			drawInstr.append(sLHSFunctor);
			drawInstr.append("\",");
			drawInstr.append(iStartingMSecs);
			drawInstr.append(",");
			drawInstr.append(iEndingMSecs);
			drawInstr.append(",");
			drawInstr.append(dConfidenceFactor);
			drawInstr.append(",new GraphicalDisplayForLinearTrajectory(new Color(");
			drawInstr.append(iR);
			drawInstr.append(",");
			drawInstr.append(iG);
			drawInstr.append(",");
			drawInstr.append(iB);
			drawInstr.append("),");
			drawInstr.append(iXCoordInPx);
			drawInstr.append(",");
			drawInstr.append(iYCoordInPx);
			drawInstr.append(",new Circle(");
			drawInstr.append(iDInPx);
			drawInstr.append("),");
			drawInstr.append("\"");
			drawInstr.append(sXCoordInSU);
			drawInstr.append("\",\"");
			drawInstr.append(sYCoordInSU);
			drawInstr.append("\",\"");
			drawInstr.append(sXMagnInSU);
			drawInstr.append("\",\"");
			drawInstr.append(sYMagnInSU);
			drawInstr.append("\"))");
			System.out.println("Java generated draw instruction: " + drawInstr.toString());
			//print to draw instr file
			drawInstrPrintWriter.print(",");
			drawInstrPrintWriter.println(drawInstr.toString());
		}
		else if (sTypePredicate.equals(Constants.s_sFunctor_DrawType_Stationary)) {
			CompoundTerm oGraphicalDisplayForStationaryTrajectory = (CompoundTerm)oDrawType.arg(11);
			if(oGraphicalDisplayForStationaryTrajectory == null){
				System.err.println("oGraphicalDisplayForStationaryTrajectory is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			CompoundTerm oColor = (CompoundTerm)oGraphicalDisplayForStationaryTrajectory.arg(1);
			if(oColor == null){
				System.err.println("oColor is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iR = (Integer)oColor.arg(1);
			if(iR == null){
				System.err.println("iR is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iG = (Integer)oColor.arg(2);
			if(iG == null){
				System.err.println("iG is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iB = (Integer)oColor.arg(3);
			if(iB == null){
				System.err.println("iB is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iXCoordInPx = (Integer)oGraphicalDisplayForStationaryTrajectory.arg(2);
			if(iXCoordInPx == null){
				System.err.println("iXCoordInPx is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iYCoordInPx = (Integer)oGraphicalDisplayForStationaryTrajectory.arg(3);
			if(iYCoordInPx == null){
				System.err.println("iYCoordInPx is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			CompoundTerm oShape = (CompoundTerm)oGraphicalDisplayForStationaryTrajectory.arg(4);
			if(oShape == null){
				System.err.println("oShape is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			//sShapeType will eventually be used to check what shape it is. If it is circle, for example, a new Circle object
			//will be created to be passed in the call to the viz draw.
			String sShapeType = (String)oShape.functor();
			if(sShapeType == null){
				System.err.println("sShapeType is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iDInPx = (Integer)oShape.arg(1);
			if(iDInPx == null){
				System.err.println("iDInPx is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			String sXCoordInSU = (String)oGraphicalDisplayForStationaryTrajectory.arg(5);
			if(sXCoordInSU == null){
				System.err.println("sXCoordInSU is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			String sYCoordInSU = (String)oGraphicalDisplayForStationaryTrajectory.arg(6);
			if(sYCoordInSU == null){
				System.err.println("sYCoordInSU is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			//For now just construct a draw instruction string in the required format. This will eventually be replaced by
			//an actual call to the visualizer
			StringBuilder drawInstr = new StringBuilder();
			drawInstr.append("draw(EpistemicStatus.");
			drawInstr.append(eEpistemicStatus);
			drawInstr.append(",");
			drawInstr.append(iDrawID);
			drawInstr.append(",");
			drawInstr.append("new ArrayList<Integer>(Arrays.asList(");
			for(int i = 0 ; i < numberOfRHSMatchingAncestorDraws - 1 ; i++){
				drawInstr.append(aRHSMatchingAncestorDrawIDs[i]);
				drawInstr.append(",");
			}
			drawInstr.append(aRHSMatchingAncestorDrawIDs[numberOfRHSMatchingAncestorDraws - 1]);
			drawInstr.append(")),");
			drawInstr.append(iFigureID);
			drawInstr.append(",");
			drawInstr.append(iEndingFrameNumber);
			drawInstr.append(",");
			drawInstr.append("\"");
			drawInstr.append(sLHSStringModified);
			drawInstr.append("\",\"");
			drawInstr.append(sLHSFunctor);
			drawInstr.append("\",");
			drawInstr.append(iStartingMSecs);
			drawInstr.append(",");
			drawInstr.append(iEndingMSecs);
			drawInstr.append(",");
			drawInstr.append(dConfidenceFactor);
			drawInstr.append(",new GraphicalDisplayForStationaryTrajectory(new Color(");
			drawInstr.append(iR);
			drawInstr.append(",");
			drawInstr.append(iG);
			drawInstr.append(",");
			drawInstr.append(iB);
			drawInstr.append("),");
			drawInstr.append(iXCoordInPx);
			drawInstr.append(",");
			drawInstr.append(iYCoordInPx);
			drawInstr.append(",new Circle(");
			drawInstr.append(iDInPx);
			drawInstr.append("),");
			drawInstr.append("\"");
			drawInstr.append(sXCoordInSU);
			drawInstr.append("\",\"");
			drawInstr.append(sYCoordInSU);
			drawInstr.append("\"))");
			System.out.println("Java generated draw instruction: " + drawInstr.toString());
			//print to draw instr file
			drawInstrPrintWriter.print(",");
			drawInstrPrintWriter.println(drawInstr.toString());
		}
		else if (sTypePredicate.equals(Constants.s_sFunctor_DrawType_Curved)) {
			CompoundTerm oGraphicalDisplayForCurvedTrajectory = (CompoundTerm)oDrawType.arg(11);
			if(oGraphicalDisplayForCurvedTrajectory == null){
				System.err.println("oGraphicalDisplayForCurvedTrajectory is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			CompoundTerm oColor = (CompoundTerm)oGraphicalDisplayForCurvedTrajectory.arg(1);
			if(oColor == null){
				System.err.println("oColor is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iR = (Integer)oColor.arg(1);
			if(iR == null){
				System.err.println("iR is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iG = (Integer)oColor.arg(2);
			if(iG == null){
				System.err.println("iG is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iB = (Integer)oColor.arg(3);
			if(iB == null){
				System.err.println("iB is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iXCoordInPx = (Integer)oGraphicalDisplayForCurvedTrajectory.arg(2);
			if(iXCoordInPx == null){
				System.err.println("iXCoordInPx is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iYCoordInPx = (Integer)oGraphicalDisplayForCurvedTrajectory.arg(3);
			if(iYCoordInPx == null){
				System.err.println("iYCoordInPx is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iCOBFXcInPx = (Integer)oGraphicalDisplayForCurvedTrajectory.arg(4);
			if(iCOBFXcInPx == null){
				System.err.println("iCOBFXcInPx is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iCOBFYcInPx = (Integer)oGraphicalDisplayForCurvedTrajectory.arg(5);
			if(iCOBFYcInPx == null){
				System.err.println("iCOBFYcInPx is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iCOBFRcInPx = (Integer)oGraphicalDisplayForCurvedTrajectory.arg(6);
			if(iCOBFRcInPx == null){
				System.err.println("iCOBFRcInPx is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			CompoundTerm oShape = (CompoundTerm)oGraphicalDisplayForCurvedTrajectory.arg(7);
			if(oShape == null){
				System.err.println("oShape is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			//sShapeType will eventually be used to check what shape it is. If it is circle, for example, a new Circle object
			//will be created to be passed in the call to the viz draw.
			String sShapeType = (String)oShape.functor();
			if(sShapeType == null){
				System.err.println("sShapeType is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iDInPx = (Integer)oShape.arg(1);
			if(iDInPx == null){
				System.err.println("iDInPx is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			String sXCoordInSU = (String)oGraphicalDisplayForCurvedTrajectory.arg(8);
			if(sXCoordInSU == null){
				System.err.println("sXCoordInSU is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			String sYCoordInSU = (String)oGraphicalDisplayForCurvedTrajectory.arg(9);
			if(sYCoordInSU == null){
				System.err.println("sYCoordInSU is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			String sXMagnInSU = (String)oGraphicalDisplayForCurvedTrajectory.arg(10);
			if(sXMagnInSU == null){
				System.err.println("sXMagnInSU is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			String sYMagnInSU = (String)oGraphicalDisplayForCurvedTrajectory.arg(11);
			if(sYMagnInSU == null){
				System.err.println("sYMagnInSU is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			String sCOBFXcInSU = (String)oGraphicalDisplayForCurvedTrajectory.arg(12);
			if(sCOBFXcInSU == null){
				System.err.println("sCOBFXcInSU is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			String sCOBFYcInSU = (String)oGraphicalDisplayForCurvedTrajectory.arg(13);
			if(sCOBFYcInSU == null){
				System.err.println("sCOBFYcInSU is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			String sCOBFRcInSU = (String)oGraphicalDisplayForCurvedTrajectory.arg(14);
			if(sCOBFRcInSU == null){
				System.err.println("sCOBFRcInSU is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			String sCOBFErrorMeasureInSU = (String)oGraphicalDisplayForCurvedTrajectory.arg(15);
			if(sCOBFErrorMeasureInSU == null){
				System.err.println("sCOBFErrorMeasureInSU is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			String sDirectionSign = (String)oGraphicalDisplayForCurvedTrajectory.arg(16);
			if(sDirectionSign == null){
				System.err.println("sDirectionSign is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			CurveDirection eCurveDirection;
			if(sDirectionSign.equals("1"))
				eCurveDirection = CurveDirection.ANTICLOCKWISE;
			else if(sDirectionSign.equals("-1"))
				eCurveDirection = CurveDirection.CLOCKWISE;
			else{
				System.err.println("sDirectionSign is invalid in this compound term read from out-queue: "+oDrawType);
				return;
			}
			//For now just construct a draw instruction string in the required format. This will eventually be replaced by
			//an actual call to the visualizer
			StringBuilder drawInstr = new StringBuilder();
			drawInstr.append("draw(EpistemicStatus.");
			drawInstr.append(eEpistemicStatus);
			drawInstr.append(",");
			drawInstr.append(iDrawID);
			drawInstr.append(",");
			drawInstr.append("new ArrayList<Integer>(Arrays.asList(");
			for(int i = 0 ; i < numberOfRHSMatchingAncestorDraws - 1 ; i++){
				drawInstr.append(aRHSMatchingAncestorDrawIDs[i]);
				drawInstr.append(",");
			}
			drawInstr.append(aRHSMatchingAncestorDrawIDs[numberOfRHSMatchingAncestorDraws - 1]);
			drawInstr.append(")),");
			drawInstr.append(iFigureID);
			drawInstr.append(",");
			drawInstr.append(iEndingFrameNumber);
			drawInstr.append(",");
			drawInstr.append("\"");
			drawInstr.append(sLHSStringModified);
			drawInstr.append("\",\"");
			drawInstr.append(sLHSFunctor);
			drawInstr.append("\",");
			drawInstr.append(iStartingMSecs);
			drawInstr.append(",");
			drawInstr.append(iEndingMSecs);
			drawInstr.append(",");
			drawInstr.append(dConfidenceFactor);
			drawInstr.append(",new GraphicalDisplayForCurvedTrajectory(new Color(");
			drawInstr.append(iR);
			drawInstr.append(",");
			drawInstr.append(iG);
			drawInstr.append(",");
			drawInstr.append(iB);
			drawInstr.append("),");
			drawInstr.append(iXCoordInPx);
			drawInstr.append(",");
			drawInstr.append(iYCoordInPx);
			drawInstr.append(",");
			drawInstr.append(iCOBFXcInPx);
			drawInstr.append(",");
			drawInstr.append(iCOBFYcInPx);
			drawInstr.append(",");
			drawInstr.append(iCOBFRcInPx);
			drawInstr.append(",CurveDirection.");
			drawInstr.append(eCurveDirection);
			drawInstr.append(",new Circle(");
			drawInstr.append(iDInPx);
			drawInstr.append("),");
			drawInstr.append("\"");
			drawInstr.append(sXCoordInSU);
			drawInstr.append("\",\"");
			drawInstr.append(sYCoordInSU);
			drawInstr.append("\",\"");
			drawInstr.append(sXMagnInSU);
			drawInstr.append("\",\"");
			drawInstr.append(sYMagnInSU);
			drawInstr.append("\",\"");
			drawInstr.append(sCOBFXcInSU);
			drawInstr.append("\",\"");
			drawInstr.append(sCOBFYcInSU);
			drawInstr.append("\",\"");
			drawInstr.append(sCOBFRcInSU);
			drawInstr.append("\",\"");
			drawInstr.append(sCOBFErrorMeasureInSU);
			drawInstr.append("\"))");
			System.out.println("Java generated draw instruction: " + drawInstr.toString());
			//print to draw instr file
			drawInstrPrintWriter.print(",");
			drawInstrPrintWriter.println(drawInstr.toString());
		}
		else if (sTypePredicate.equals(Constants.s_sFunctor_DrawType_SingleForce)||
				 sTypePredicate.equals(Constants.s_sFunctor_DrawType_CombinedForces)||
				 sTypePredicate.equals(Constants.s_sFunctor_DrawType_IntentionToApproachOrAvoid)||
				 sTypePredicate.equals(Constants.s_sFunctor_DrawType_CombinedIntentionToApproachAndAvoid)||
				 sTypePredicate.equals(Constants.s_sFunctor_DrawType_IntentionToBeAtPosition)||
				 sTypePredicate.equals(Constants.s_sFunctor_DrawType_Notice)||
				 sTypePredicate.equals(Constants.s_sFunctor_DrawType_IntentionToApproachAugmentedWithIntentionToAvoid)||
				 sTypePredicate.equals(Constants.s_sFunctor_DrawType_Wiggle)||
				 sTypePredicate.equals(Constants.s_sFunctor_DrawType_TrajectoryFromWiggle)
				) 
		{
			CompoundTerm oGraphicalDisplay = (CompoundTerm)oDrawType.arg(11);
			if(oGraphicalDisplay == null){
				System.err.println("oGraphicalDisplay is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			CompoundTerm oColor = (CompoundTerm)oGraphicalDisplay.arg(1);
			if(oColor == null){
				System.err.println("oColor is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iR = (Integer)oColor.arg(1);
			if(iR == null){
				System.err.println("iR is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iG = (Integer)oColor.arg(2);
			if(iG == null){
				System.err.println("iG is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iB = (Integer)oColor.arg(3);
			if(iB == null){
				System.err.println("iB is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			CompoundTerm oListOfPositions = (CompoundTerm)oGraphicalDisplay.arg(2);
			if(oListOfPositions == null){
				System.err.println("oListOfPositions is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			int numberOfPositions = oListOfPositions.arity();
			List<Point> lListOfPositions = new ArrayList<Point>();
			CompoundTerm oPosition;
			Integer iXCoordInPx;
			Integer iYCoordInPx;
			for(int i = 0 ; i < numberOfPositions ; i++) {
				oPosition = (CompoundTerm)oListOfPositions.arg(i+1);
				if(oPosition == null) {
					System.err.println("oListOfPositions[" + i + "] is null in this compound term read from out-queue: "+oListOfPositions);
					return;
				}
				iXCoordInPx = (Integer)oPosition.arg(1);
				if(iXCoordInPx == null) {
					System.err.println("iXCoordInPx is null in this compound term read from out-queue: "+oPosition);
					return;
				}
				iYCoordInPx = (Integer)oPosition.arg(2);
				if(iYCoordInPx == null) {
					System.err.println("iYCoordInPx is null in this compound term read from out-queue: "+oPosition);
					return;
				}
				lListOfPositions.add(new Point(iXCoordInPx,iYCoordInPx));
			}
			
			CompoundTerm oShape = (CompoundTerm)oGraphicalDisplay.arg(3);
			if(oShape == null){
				System.err.println("oShape is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			//sShapeType will eventually be used to check what shape it is. If it is circle, for example, a new Circle object
			//will be created to be passed in the call to the viz draw.
			String sShapeType = (String)oShape.functor();
			if(sShapeType == null){
				System.err.println("sShapeType is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			Integer iDInPx = (Integer)oShape.arg(1);
			if(iDInPx == null){
				System.err.println("iDInPx is null in this compound term read from out-queue: "+oDrawType);
				return;
			}
			//Get tooltip specific arguments
			String tooltipContentsString = null;
			String tooltipObjectName = null;
			//For each of the draw types below, which require extracting tooltip contents for, call
			//generateTooltipContentsString with the graphical display object along with the starting
			//and ending indices of the fields that contain the tooltip strings in the graphical display
			//object. Refer to the draw term formats at the start of the method to find out the starting
			//and ending indices
			if(sTypePredicate.equals(Constants.s_sFunctor_DrawType_SingleForce)){
				tooltipContentsString = generateTooltipContentsString(oGraphicalDisplay, 4, 6);
				if (tooltipContentsString == null)
					return;
				tooltipObjectName = "TooltipForSingleForce";
			}
			else if(sTypePredicate.equals(Constants.s_sFunctor_DrawType_CombinedForces)){
				tooltipContentsString = generateTooltipContentsString(oGraphicalDisplay, 4, 7);
				if (tooltipContentsString == null)
					return;
				tooltipObjectName = "TooltipForConjunctionOfForces";
			}
			else if(sTypePredicate.equals(Constants.s_sFunctor_DrawType_IntentionToApproachOrAvoid)){
				tooltipContentsString = generateTooltipContentsString(oGraphicalDisplay, 4, 5);
				if (tooltipContentsString == null)
					return;
				tooltipObjectName = "TooltipForIntentionToApproachOrAvoid";
			}
			else if(sTypePredicate.equals(Constants.s_sFunctor_DrawType_CombinedIntentionToApproachAndAvoid)){
				tooltipContentsString = generateTooltipContentsString(oGraphicalDisplay, 4, 5);
				if (tooltipContentsString == null)
					return;
				tooltipObjectName = "TooltipForConjunctionOfIntentionsToApproachAndAvoid";
			}
			else if(sTypePredicate.equals(Constants.s_sFunctor_DrawType_IntentionToBeAtPosition)){
				tooltipContentsString = generateTooltipContentsString(oGraphicalDisplay, 4, 5);
				if (tooltipContentsString == null)
					return;
				tooltipObjectName = "TooltipForIntentionToBeAtPosition";
			}
			else if(sTypePredicate.equals(Constants.s_sFunctor_DrawType_Notice)){
				tooltipContentsString = generateTooltipContentsString(oGraphicalDisplay, 4, 4);
				if (tooltipContentsString == null)
					return;
				tooltipObjectName = "TooltipForNoticing";
			}
			else if(sTypePredicate.equals(Constants.s_sFunctor_DrawType_IntentionToApproachAugmentedWithIntentionToAvoid)){
				tooltipContentsString = generateTooltipContentsString(oGraphicalDisplay, 4, 6);
				if (tooltipContentsString == null)
					return;
				tooltipObjectName = "TooltipForAugmentationOfIntentionToApproachWithIntentionToAvoid";
			}
			else if(sTypePredicate.equals(Constants.s_sFunctor_DrawType_Wiggle)){
				tooltipContentsString = generateTooltipContentsString(oGraphicalDisplay, 4, 4);
				if (tooltipContentsString == null)
					return;
				tooltipObjectName = "TooltipForWiggle";
			}
			else if(sTypePredicate.equals(Constants.s_sFunctor_DrawType_TrajectoryFromWiggle)){
				tooltipContentsString = generateTooltipContentsString(oGraphicalDisplay, 4, 8);
				if (tooltipContentsString == null)
					return;
				tooltipObjectName = "TooltipForTrajectoryFromWiggle";
			}
			
			//For now just construct a draw instruction string in the required format. This will eventually be replaced by
			//an actual call to the visualizer
			
			StringBuilder drawInstr = new StringBuilder();
			drawInstr.append("draw(EpistemicStatus.");
			drawInstr.append(eEpistemicStatus);
			drawInstr.append(",");
			drawInstr.append(iDrawID);
			drawInstr.append(",");
			drawInstr.append("new ArrayList<Integer>(Arrays.asList(");
			for(int i = 0 ; i < numberOfRHSMatchingAncestorDraws - 1 ; i++){
				drawInstr.append(aRHSMatchingAncestorDrawIDs[i]);
				drawInstr.append(",");
			}
			drawInstr.append(aRHSMatchingAncestorDrawIDs[numberOfRHSMatchingAncestorDraws - 1]);
			drawInstr.append(")),");
			drawInstr.append(iFigureID);
			drawInstr.append(",");
			drawInstr.append(iEndingFrameNumber);
			drawInstr.append(",");
			drawInstr.append("\"");
			drawInstr.append(sLHSStringModified);
			drawInstr.append("\",\"");
			drawInstr.append(sLHSFunctor);
			drawInstr.append("\",");
			drawInstr.append(iStartingMSecs);
			drawInstr.append(",");
			drawInstr.append(iEndingMSecs);
			drawInstr.append(",");
			drawInstr.append(dConfidenceFactor);
			drawInstr.append(",new GraphicalDisplayForHighLevelAscription(new Color(");
			drawInstr.append(iR);
			drawInstr.append(",");
			drawInstr.append(iG);
			drawInstr.append(",");
			drawInstr.append(iB);
			drawInstr.append("),");
			drawInstr.append("new ArrayList<Point>(Arrays.asList(");
			for(int i = 0 ; i < numberOfPositions - 1 ; i++) {
				drawInstr.append("new Point(");
				drawInstr.append(lListOfPositions.get(i).x);
				drawInstr.append(",");
				drawInstr.append(lListOfPositions.get(i).y);
				drawInstr.append("),");
			}
			drawInstr.append("new Point(");
			drawInstr.append(lListOfPositions.get(numberOfPositions - 1).x);
			drawInstr.append(",");
			drawInstr.append(lListOfPositions.get(numberOfPositions - 1).y);
			drawInstr.append(")))");
			drawInstr.append(",new Circle(");
			drawInstr.append(iDInPx);
			drawInstr.append("),");
			drawInstr.append("new ");
			drawInstr.append(tooltipObjectName);
			drawInstr.append("(");
			drawInstr.append(tooltipContentsString);
			drawInstr.append(")");
			drawInstr.append("))");
			System.out.println("Java generated draw instruction: " + drawInstr.toString());
			//print to draw instr file
			drawInstrPrintWriter.print(",");
			drawInstrPrintWriter.println(drawInstr.toString());
		}
		else {
			System.err.println("sTypePredicate is unrecognizable in this compound term read from out-queue: "+oDrawType);
		}
	}
	void fVisualize_edgeSummary(CompoundTerm oTerm,
								VizGrapherArc.AMismatch eAMismatch )
	{
		//edgeSummary(IdAsString,ParentIdsAsStringsInList,SpanStart,SpanEnd,LHSPredAsString,CompletionStatusAsBool,LabelAsString)
		String	sId						= (String)oTerm.arg(1),
				sPredicate				= (String)oTerm.arg(5),
				sDescription			= (String)oTerm.arg(7);
		Collection<String> csParentIds	= (Collection<String>) oTerm.arg(2);
		Integer iSpanStart				= (Integer)oTerm.arg(3),
				iSpanEnd				= (Integer)oTerm.arg(4);
		String sCompletionStatus		= (String)oTerm.arg(6);
		VizGrapherArc.Predicate ePredicate = null;
		VizGrapherArc.Completion eCompletionStatus = null;
		if (sId == null) {
			System.err.println("sId is null in this compound term read from out-queue: "+oTerm);
			return;
		}
		if (sPredicate == null) {
			System.err.println("sPredicate is null in this compound term read from out-queue: "+oTerm);
			return;
		}
		if (sPredicate.equals(Constants.s_sFunctor_List)) {
			ePredicate = VizGrapherArc.Predicate.LIST;
		} else if (sPredicate.equals(Constants.s_sFunctor_FigureHasTrajectory)) {
			ePredicate = VizGrapherArc.Predicate.FIGURE_HAS_TRAJECTORY;
		} else if (sPredicate.equals(Constants.s_sFunctor_ExertForceOn)) {
			ePredicate = VizGrapherArc.Predicate.EXERT_FORCE_ON;
		} else if (sPredicate.equals(Constants.s_sFunctor_Intend)) {
			ePredicate = VizGrapherArc.Predicate.INTEND;
		} else if (sPredicate.equals(Constants.s_sFunctor_DummyTrigger)) {
			ePredicate = VizGrapherArc.Predicate.DUMMY_TRIGGER;
		} else if (sPredicate.equals(Constants.s_sFunctor_IntentionChange)) {
			ePredicate = VizGrapherArc.Predicate.INTENTION_CHANGED;
		} else {
			System.err.println("Cannot recognize sPredicate ["+sPredicate+"] in this compound term read from out-queue: "+oTerm);
			return;
		}
		if (sDescription == null) {
			System.err.println("sDescription is null in this compound term read from out-queue: "+oTerm);
			return;
		}
		if (sDescription.isEmpty()) {
			System.err.println("sDescription is empty in this compound term read from out-queue: "+oTerm);
			return;
		}
		//It's valid for csParentIds to be null
		if (iSpanStart == null) {
			System.err.println("iSpanStart is null in this compound term read from out-queue: "+oTerm);
			return;
		}
		if (iSpanEnd == null) {
			System.err.println("iSpanEnd is null in this compound term read from out-queue: "+oTerm);
			return;
		}
		if (sCompletionStatus == null) {
			System.err.println("oCompletionStatus is null in this compound term read from out-queue: "+oTerm);
			return;
		}
		if (Constants.s_sFunctor_Completed.equals(sCompletionStatus)) {
			eCompletionStatus = VizGrapherArc.Completion.COMPLETED;
		} else if (Constants.s_sFunctor_Incomplete.equals(sCompletionStatus)) {
			eCompletionStatus = VizGrapherArc.Completion.INCOMPLETE;
		} else {
			System.err.println("sCompletionStatus is neither \"completed\" nor \"incomplete\" in this compound term read from out-queue: "+oTerm);
			return;
		}
		
		_oIViz.addEdge(	iSpanStart, iSpanEnd,
						ePredicate, eCompletionStatus, eAMismatch,
						sDescription );
	}
	void fVisualize_mismatch(CompoundTerm oMismatchTerm) {
		//mismatch(edgeSummary("edge4", ["edge1"], 1, 1, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, stationaryTrajectory(originalPosition(61, 35)), 0, ElapsedTime2, 0.7, originally(circle(13), color(255, 0, 0))), 0.7, [], [[timestamp(0), figure(1, position(61, 35), circle(13), color(255, 0, 0))], [timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]"), 
		//         edgeSummary("edge4", [], 2, 3, "list", "completed", "[[timestamp(41), ground(167, 122, color(255, 255, 255)), figure(1, position(67, 39), circle(13), color(255, 0, 0))], 1.0, [[timestamp(41), ground(167, 122, color(255, 255, 255)), figure(1, position(67, 39), circle(13), color(255, 0, 0))]], []]"))
		CompoundTerm oActualTerm		= (CompoundTerm)oMismatchTerm.arg(1);
		CompoundTerm oExpectedTerm		= (CompoundTerm)oMismatchTerm.arg(2);
		fVisualize_edgeSummary(	oExpectedTerm,
								VizGrapherArc.AMismatch.EXPECTED );
		fVisualize_edgeSummary(	oActualTerm,
								VizGrapherArc.AMismatch.ACTUAL );
	}
	//the starting and ending indices correspond to the starting and ending positions of the tooltip
	//strings in the graphical display object
	private String generateTooltipContentsString(CompoundTerm oGraphicalDisplay,int startIndex, int endIndex) {
		StringBuilder tooltipContentsString = new StringBuilder();
		String singleTooltipContentString;
		for(int i = startIndex ; i < endIndex ; i++) {
			singleTooltipContentString = (String)oGraphicalDisplay.arg(i);
			if(singleTooltipContentString == null){
				System.err.println("singleTooltipContentString at position "+i+" is null in this compound term read from out-queue: "+oGraphicalDisplay);
				return null;
			}
			tooltipContentsString.append("\"");
			tooltipContentsString.append(singleTooltipContentString);
			tooltipContentsString.append("\",");
		}
		singleTooltipContentString = (String)oGraphicalDisplay.arg(endIndex);
		if(singleTooltipContentString == null){
			System.err.println("singleTooltipContentString at position "+endIndex+" is null in this compound term read from out-queue: "+oGraphicalDisplay);
			return null;
		}
		tooltipContentsString.append("\"");
		tooltipContentsString.append(singleTooltipContentString);
		tooltipContentsString.append("\"");
		return tooltipContentsString.toString();
	}	
}
