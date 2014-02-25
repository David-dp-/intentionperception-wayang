package sg.ihpc.wayangTest.viz;

import edu.uci.ics.jung.graph.Graph;
import edu.uci.ics.jung.graph.util.EdgeIndexFunction;

public class VizGrapherParallelEdgeIndexFunction implements EdgeIndexFunction<VizGrapherNode,VizGrapherArc> {
	
	@Override
	public int getIndex(Graph<VizGrapherNode, VizGrapherArc> oGraph, VizGrapherArc oArc) {
		return oArc.getOrbitLevel();
	}

	@Override
	public void reset() {
		//No need to do anything
	}

	@Override
	public void reset(Graph<VizGrapherNode, VizGrapherArc> arg0, VizGrapherArc arg1) {
		//No need to do anything
	}

}
