package sg.ihpc.wayangTest.viz;

import java.awt.Dimension;
import java.util.HashMap;
import java.util.Map;

import edu.uci.ics.jung.algorithms.layout.AbstractLayout;
import edu.uci.ics.jung.algorithms.layout.FRLayout;
import edu.uci.ics.jung.graph.DirectedSparseMultigraph;

/* We extend rather than contain DirectedSparseMultigraph because VizParallelEdgeIndexFunction
 * must implement a getIndex() method that takes a Graph (and an Arc) and gives a result
 * relevant to that graph. If we just contained DirectedSparseMultigraph, then getIndex()
 * wouldn't be able to get at _miioSpans to generate the index value.
 * Alternatively, we would have to store references to the containing object in VizArc
 * and VizSpan.
 */
@SuppressWarnings("serial")
public class VizGrapherGraph extends DirectedSparseMultigraph<VizGrapherNode, VizGrapherArc> {
	
	//We will have nested maps so we can conflate all edges of the same span and same
	// appearance into a single visible edge. Since each nested map, and the parent
	// map are likely to have fewer cells than the default initial map size, we try
	// to limit memory footprint by using a smaller initial map size.
	static final private int s_iDefaultInitialMapSize = 10;
	
	private AbstractLayout<VizGrapherNode, VizGrapherArc> _oLayout;
	private int _iNodeSeparation;
	private int _iNodeYPosition;
	private Map<Integer,VizGrapherNode> _mioNodes;
	//The index is: SpanStartNode, SpanEndNode
	private Map<Integer,Map<Integer,VizGrapherSpan > > _miioSpans;
	
	VizGrapherGraph(	int iWidth,
					int iHeight,
					int iNodeSeparation )
	{
		_iNodeSeparation = iNodeSeparation;
		_iNodeYPosition = iNodeSeparation; //A little more than height of self-loops (which are displayed on top)
		
		_mioNodes = new HashMap<Integer,VizGrapherNode>(s_iDefaultInitialMapSize);
		
		_miioSpans = new HashMap<Integer,Map<Integer,VizGrapherSpan> >(s_iDefaultInitialMapSize);
		
		_oLayout = new FRLayout<VizGrapherNode, VizGrapherArc>(this);
		//Set the initial size of the subarea of the window where the graph will be shown
	    _oLayout.setSize(new Dimension(iWidth,iHeight));
	}
	AbstractLayout<VizGrapherNode, VizGrapherArc> getLayout() {
		return _oLayout;
	}
    
	/*void reset() {
		//Can't use the for(:) construct (nor an iterator) on this.getVertices()
		// because it throws ConcurrentModificationException due to our removing
		// from the collection. getVertices() returns an unmodifiable coll.
		for (VizNode oNode : _mioNodes.values()) {
			this.removeVertex(oNode);
		}
		_mioNodes.clear();
		_miioSpans.clear();
	}*/
    void addEdge(	int iIdOfSourceNode,
    				int iIdOfDestinationNode,
    				VizGrapherArc.Predicate ePredicate,
    				VizGrapherArc.Completion eCompletion,
    				VizGrapherArc.AMismatch eAMismatch,
    				String sDescription )
    {
    	int iNodeXPosition;
    	
		VizGrapherNode oSourceNode = _mioNodes.get(iIdOfSourceNode);
		if (oSourceNode == null) {
			oSourceNode = new VizGrapherNode(iIdOfSourceNode);
			iNodeXPosition = iIdOfSourceNode*_iNodeSeparation;
			_oLayout.setLocation(oSourceNode, iNodeXPosition, _iNodeYPosition);
			_oLayout.lock(oSourceNode, true);
			
			_mioNodes.put(iIdOfSourceNode, oSourceNode);
		}
		
		VizGrapherNode oDestinationNode = _mioNodes.get(iIdOfDestinationNode);
		if (oDestinationNode == null) {
			oDestinationNode = new VizGrapherNode(iIdOfDestinationNode);
			iNodeXPosition = iIdOfDestinationNode*_iNodeSeparation;
			_oLayout.setLocation(oDestinationNode, iNodeXPosition, _iNodeYPosition);
			_oLayout.lock(oDestinationNode, true);
			
			_mioNodes.put(iIdOfDestinationNode, oDestinationNode);
		}

		//We want to show just one arc for all edges with the same source, destination,
		// predicate, and completion state. So, we use nested maps to make sure we
		// haven't already created such an arc. We add the edge description to the
		// arc so that in some future version, we can select an arc and see all
		// associated descriptions. Arcs are managed within span objs.
		Map<Integer,VizGrapherSpan> mioSpansForSpanEnd = _miioSpans.get(iIdOfSourceNode);
		if (mioSpansForSpanEnd == null) {
			mioSpansForSpanEnd = new HashMap<Integer,VizGrapherSpan>(s_iDefaultInitialMapSize);
			_miioSpans.put(iIdOfSourceNode, mioSpansForSpanEnd);
		}
		VizGrapherSpan oSpan = mioSpansForSpanEnd.get(iIdOfDestinationNode);
		if (oSpan == null) {
			oSpan = new VizGrapherSpan(iIdOfSourceNode, iIdOfDestinationNode);
			mioSpansForSpanEnd.put(iIdOfDestinationNode, oSpan);
		}
		VizGrapherArc oArc = oSpan.foGenerateArcIfNeeded(	ePredicate, eCompletion,
													eAMismatch,
													sDescription);
		if (oArc != null) {
			this.addEdge(oArc, oSourceNode, oDestinationNode);
		}
    }
}
