package sg.ihpc.wayangTest.viz;

import java.util.HashMap;
import java.util.Map;

import sg.ihpc.wayangTest.viz.VizGrapherArc.Completion;
import sg.ihpc.wayangTest.viz.VizGrapherArc.Predicate;

public class VizGrapherSpan {
	
	//The index is: Predicate.ordinal, Completion.ordinal
	private Map<Integer,Map<Integer,VizGrapherArc> > _miioArcForPredAndCompletion;
	
	private int _iStartNode; //only used for debugging
	private int _iEndNode;   //only used for debugging
	
	VizGrapherSpan(int iStartNode,
			int iEndNode)
	{
		_iStartNode = iStartNode;
		_iEndNode   = iEndNode;
		
		_miioArcForPredAndCompletion
			= new HashMap<Integer,Map<Integer,VizGrapherArc> >(Predicate.values().length);
	}
	int getStartNode() { //only used for debugging
    	return _iStartNode;
    }
    int getEndNode() { //only used for debugging
    	return _iEndNode;
    }
    public String toString() {
        return "span_"+_iStartNode+"_"+_iEndNode+"_"+_miioArcForPredAndCompletion;
    }
	
	VizGrapherArc foGenerateArcIfNeeded(	VizGrapherArc.Predicate ePredicate,
									VizGrapherArc.Completion eCompletion,
									VizGrapherArc.AMismatch eAMismatch,
									String sDescription )
	{
		boolean bReturnArc = false;
		VizGrapherArc oArc = null;
		
		int iIndex = ePredicate.ordinal();
		Map<Integer,VizGrapherArc> mioArcsForCompletionStatus
			= _miioArcForPredAndCompletion.get(iIndex);
		if (mioArcsForCompletionStatus == null) {
			mioArcsForCompletionStatus
				= new HashMap<Integer,VizGrapherArc>(Completion.values().length);
			_miioArcForPredAndCompletion.put(iIndex, mioArcsForCompletionStatus);
		}
		iIndex = eCompletion.ordinal();
		//Ensure that mismatches always result in a red arc; dont allow a prev
		// arc with same index to be reused.
		if (eAMismatch == VizGrapherArc.AMismatch.NO) {
			oArc = mioArcsForCompletionStatus.get(iIndex);
		}
		if (oArc == null) {
			oArc = new VizGrapherArc(	ePredicate, eCompletion, eAMismatch,
								_iStartNode, _iEndNode );
			bReturnArc = true;
			mioArcsForCompletionStatus.put(iIndex, oArc);
		}
		oArc.fAddDescription(sDescription);
		
		return (bReturnArc ? oArc : null);
	}
}
