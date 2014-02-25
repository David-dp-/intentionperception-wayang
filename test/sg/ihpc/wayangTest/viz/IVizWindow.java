package sg.ihpc.wayangTest.viz;

import sg.ihpc.wayang.IControlState;

public interface IVizWindow {
	VizPlayerNextFrameGuard getNextFrameGuard();
	
	void considerEnablingNextFrameButton(boolean bConsiderEnablingNextFrameButton);
	
	IControlState getIControlState();
	
	void drawStationary(Integer iXCentroid,
						Integer iYCentroid,
						Integer iFigureId,
						//CompoundTerm oShapeTerm,
						Integer iElapsedTime );
	void drawLinear(Integer iXCentroid,
					Integer iYCentroid,
					Double dXMagnitude,
					Double dYMagnitude,
					Integer iFigureId,
					//CompoundTerm oShapeTerm,
					Integer iElapsedTime );
	void drawForce(	Integer iXCentroid,
					Integer iYCentroid,
					Double dXMagnitude,
					Double dYMagnitude,
					String sDirection,
					Integer iFigureId,
					//CompoundTerm oShapeTerm,
					Integer iElapsedTime );
	void drawCurved(Integer iXCentroid,
					Integer iYCentroid,
					Integer iXCentroid2,
					Integer iYCentroid2,
					Integer iElapsedTime1,
					Integer iElapsedTime2,
					Double  iXCentroidC,
					Double  iYCentroidC,
					Double  Radius,
					//CompoundTerm oShapeTerm,
					Integer iFigureId );
	void drawIntendAtPositionStationary(Integer iXCentroid,
										Integer iYCentroid,
										Integer iFigureId,
										//CompoundTerm oShapeTerm,
										Integer iElapsedTime);
	void drawIntendAtPositionLinear(Integer iXCentroid,
									Integer iYCentroid,
									Double dXMagnitude,
									Double dYMagnitude,
									Integer iFigureId,
									//CompoundTerm oShapeTerm,
									Integer iElapsedTime);
	void addEdge(	int iIdOfSourceNode,
					int iIdOfDestinationNode,
					VizGrapherArc.Predicate ePredicate,
					VizGrapherArc.Completion eCompletion,
					VizGrapherArc.AMismatch eAMismatch,
					String sDescription );

	void indicateTestOutcome(boolean fbTestSucceeded);

	void indicateTestOutcomeNotYetKnown(boolean b);
}
