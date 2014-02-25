package sg.ihpc.wayangTest.viz;

import java.awt.Color;
import java.util.ArrayList;
import java.util.List;

public class VizGrapherArc {
	static public enum Completion {COMPLETED, INCOMPLETE};
	static public enum Strokes {SOLID, DOTTED};
	
	static public enum AMismatch {NO, EXPECTED, ACTUAL};
	static public enum Predicate 
	{LIST, FIGURE_HAS_TRAJECTORY, EXERT_FORCE_ON, INTEND, DUMMY_TRIGGER, INTENTION_CHANGED};
	
	private AMismatch _eAMismatch;
	private Completion _eCompletion;
	private Predicate _ePredicate;
	private List<String> _cConflatedDescriptions;
	
	private int _iStartNode; //only used for debugging
	private int _iEndNode;   //only used for debugging
	
    public VizGrapherArc(	Predicate ePredicate,
    				Completion eCompletion,
    				AMismatch eAMismatch,
    				int iStartNode,
    				int iEndNode )
    {
    	_eAMismatch = eAMismatch;
        _eCompletion = eCompletion;
        _ePredicate = ePredicate;
        _cConflatedDescriptions = new ArrayList<String>();
        
        _iStartNode = iStartNode;
        _iEndNode = iEndNode;
        
        //System.out.println("Constructed: "+this); //DEBUG
    }
    int getStartNode() { //only used for debugging
    	return _iStartNode;
    }
    int getEndNode() { //only used for debugging
    	return _iEndNode;
    }
    public String toString() {
        return "arc_"+_iStartNode+"_"+_iEndNode+"_("+getOrbitLevel()+")_"+_ePredicate+"_"+_eCompletion;
    }
    public Color getColor() {
    	if (_eAMismatch == AMismatch.ACTUAL) {
    		return Color.RED;
    	} else if (_eAMismatch == AMismatch.EXPECTED) {
    		return Color.PINK;
    	}
    	Color oColor = Color.LIGHT_GRAY;
    	switch (_ePredicate) {
    		case FIGURE_HAS_TRAJECTORY: oColor = Color.CYAN; break;
    		case EXERT_FORCE_ON: oColor = Color.BLUE; break;
    		case INTEND: oColor = Color.GREEN; break;
    		case DUMMY_TRIGGER: oColor = Color.ORANGE; break;
    		case INTENTION_CHANGED: oColor = Color.MAGENTA; break;
    	}
    	return oColor;
    }
    public Strokes getStrokeStyle() {
    	Strokes eStrokes = Strokes.SOLID;
    	if (_eCompletion == Completion.INCOMPLETE) {
    		eStrokes = Strokes.DOTTED;
    	}
    	return eStrokes;
    }
    //We want "full" predicates like hasTrajectory to be shown vertically higher
    // than "supporting" predicates, and we want completed edges shown
    // higher than incomplete ones.
    int getOrbitLevel() {
    	int iOrbitForSpanSizeOf1 = 2*_ePredicate.ordinal() + _eCompletion.ordinal();
    	//We use max(1,X) so that self-loops are distinguishable from each other following
    	// the iOrbitForSpanSizeOf1 stacking order (without the +1, every self-loop
    	// would have orbit level 0 and thus be indistinguishable from any other
    	// self-loop at the same node.
    	int iMakeLongerSpansAppearAboveShorterOnes = Math.max(1,_iEndNode - _iStartNode);
    	return iOrbitForSpanSizeOf1 * iMakeLongerSpansAppearAboveShorterOnes;
    }
    VizGrapherArc.Predicate getPredicate() {
    	return _ePredicate;
    }
    VizGrapherArc.Completion getCompletionStatus() {
    	return _eCompletion;
    }
    int getDescriptionsCount() {
    	return _cConflatedDescriptions.size();
    }
    
    void fAddDescription(String sDescription) {
    	/* TODO Storing the desc strings has for some reason caused a growth of the perm gen
    	space. Since this array doesn't seem to be in use yet (nor does there seem
    	to be a way to access it currently) this part is commented out */
    	//_cConflatedDescriptions.add(sDescription);
    }
}
