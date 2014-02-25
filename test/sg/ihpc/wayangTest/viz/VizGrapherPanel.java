package sg.ihpc.wayangTest.viz;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Paint;
import java.awt.Stroke;

import org.apache.commons.collections15.Transformer;

import sg.ihpc.wayangTest.TestEnvironment;

import edu.uci.ics.jung.graph.util.EdgeIndexFunction;
import edu.uci.ics.jung.visualization.BasicVisualizationServer;
import edu.uci.ics.jung.visualization.decorators.ToStringLabeller;
import edu.uci.ics.jung.visualization.renderers.Renderer;

/* We extend BasicVisualizationServer instead of aggregating it because it's
 * a subclass of JPanel and we want containers to easily call paint() or
 * whatever they need without our having to anticipate such calls and provide
 * wrapper methods for the aggregate.
 */
@SuppressWarnings("serial")
class VizGrapherPanel extends BasicVisualizationServer<VizGrapherNode, VizGrapherArc> {
	
	static private final EdgeIndexFunction<VizGrapherNode,VizGrapherArc>
		s_oParallelEdgeIndexFunction = new VizGrapherParallelEdgeIndexFunction();
	
	private Integer _iGraphWidth;
	private Integer _iGraphHeight;
	private Integer _iGraphMargin;
	private VizGrapherArcStyles _oArcStyles;
	private VizGrapherGraph _oGraph;
	
	VizGrapherPanel(TestEnvironment oEnv) {
		//This call has nested assignments because BasicVisualizationServer's
		// constructor requires a Layout parameter, and we can provide that
		// only by first creating the DirectedSparseMultigraph first.
		//Java requires that super() always be the first statement, if called
		// explicitly, in any constructor like the one we're defining here.
		super(new VizGrapherGraph(	oEnv.getGraphWidth(),
									oEnv.getGraphHeight(),
									oEnv.getGraphNodeSeparation() ).getLayout());
		
		_oArcStyles = new VizGrapherArcStyles(oEnv.getGraphNumDifferentArcWidths());
		_oGraph = (VizGrapherGraph)super.getGraphLayout().getGraph();
		
		_iGraphWidth			= oEnv.getGraphWidth();
		_iGraphHeight			= oEnv.getGraphHeight();
		_iGraphMargin			= oEnv.getGraphMargin();
		
		//Sets the viewing area size
		super.setPreferredSize(new Dimension(	_iGraphWidth + _iGraphMargin,
												_iGraphHeight + _iGraphMargin ));
		super.setBackground(Color.BLACK);
	    
	    //Place vertex labels within the vertex shape
		super.getRenderer().getVertexLabelRenderer().setPosition(Renderer.VertexLabel.Position.CNTR);
	    
		//Provide a resource to tell the graph how to place parallel edges relative to
		// each other. Specifically, we want "full" predicates like hasTrajectory to be
		// shown vertically higher than "supporting" predicate, and we want completed
		// edges shown higher than incomplete ones.
		super.getRenderContext().setParallelEdgeIndexFunction(s_oParallelEdgeIndexFunction);
		
	    //Refer to the node's toString method to find what label it should have
		super.getRenderContext().setVertexLabelTransformer(new ToStringLabeller<VizGrapherNode>());
	    //Refer to the node's toColor method to find what color it should be
		super.getRenderContext().setVertexFillPaintTransformer(new Transformer<VizGrapherNode,Paint>() {
	        public Paint transform(VizGrapherNode vn) {
	            return vn.toColor();
	        }
	    });
	    
	    //Refer to the arc's toColor method to find what color it should be
		super.getRenderContext().setEdgeDrawPaintTransformer(new Transformer<VizGrapherArc,Paint>() {
	        public Paint transform(VizGrapherArc va) {
	            return va.getColor();
	        }
	    });
		super.getRenderContext().setArrowDrawPaintTransformer(new Transformer<VizGrapherArc,Paint>() {
	        public Paint transform(VizGrapherArc va) {
	            return va.getColor();
	        }
	    });
		super.getRenderContext().setArrowFillPaintTransformer(new Transformer<VizGrapherArc,Paint>() {
	        public Paint transform(VizGrapherArc va) {
	            return va.getColor();
	        }
	    });
		
		//Refer to the arc's toStroke method to find what stroke it should use, such as dotted or solid
		super.getRenderContext().setEdgeStrokeTransformer(new Transformer<VizGrapherArc,Stroke>() {
	        public Stroke transform(VizGrapherArc va) {
	        	return _oArcStyles.getStrokeWeightAndStyle(va);
	        }
	    });
		/*
		//Adapted from http://isaomatsunami.blogspot.com/2010/11/review-and-afterthoughtwef.html
		PluggableGraphMouse gm = new PluggableGraphMouse();
		gm.add(new PickingGraphMousePlugin());
		super.setGraphMouse(gm);
		super.setPickSupport(new ShapePickSupport(super, super, super.getRenderer(), 2));
		*/
	}

	//All accessors are package-private, so all access should be through VizWindow
	
	/*void resetGraph() {
		_oGraph.reset();
	}*/
    void addEdge(	int iIdOfSourceNode,
					int iIdOfDestinationNode,
					VizGrapherArc.Predicate ePredicate,
    				VizGrapherArc.Completion eCompletion,
					VizGrapherArc.AMismatch eAMismatch,
    				String sDescription )
    {
    	_oGraph.addEdge(	iIdOfSourceNode, iIdOfDestinationNode,
			    			ePredicate, eCompletion, eAMismatch,
			    			sDescription );
    }
}
