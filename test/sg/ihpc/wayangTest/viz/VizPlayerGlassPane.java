package sg.ihpc.wayangTest.viz;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.geom.Line2D;
import java.awt.geom.Rectangle2D;
import java.util.ArrayList;
import java.util.Collection;

import javax.swing.JComponent;

@SuppressWarnings("serial")
public class VizPlayerGlassPane extends JComponent {
	
	private Collection<Shape> _coShapesToDraw = new ArrayList<Shape>();
	
	private double adaptX(double dXCoord) {
		return dXCoord;
	}
	private double adaptY(double dYCoord) {
		return this.getHeight() - dYCoord; //input origin is lower left; out's is top left
	}
	private double adaptLength(double dLength) {
		return dLength;
	}
	
	void drawStationary(Integer iXCentroid,
						Integer iYCentroid,
						Integer iFigureId,
						//CompoundTerm oShapeTerm,
						Integer iElapsedTime )
	{
		Shape oShape = new Rectangle2D.Double(	adaptX(iXCentroid+0.0),
												adaptY(iYCentroid+0.0),
												adaptLength(30.0),
												adaptLength(30.0) );
		_coShapesToDraw.add(oShape);
	}
	void drawLinear(Integer iXCentroid,
					Integer iYCentroid,
					Double dXMagnitude,
					Double dYMagnitude,
					Integer iFigureId,
					//CompoundTerm oShapeTerm,
					Integer iElapsedTime )
	{
		Shape oShape = new Line2D.Double(	0.0, //DEBUG adaptX(iXCentroid+0.0),
											0.0, //DEBUG adaptY(iYCentroid+0.0),
											adaptX(iXCentroid + dXMagnitude),
											adaptY(iYCentroid + dYMagnitude) );
		_coShapesToDraw.add(oShape);
	}
	void drawForce(	Integer iXCentroid,
					Integer iYCentroid,
					Double dXMagnitude,
					Double dYMagnitude,
					String sDirection,
					Integer iFigureId,
					//CompoundTerm oShapeTerm,
					Integer iElapsedTime )
	{
		//TODO
	}
	
	public void paint(Graphics g) {
		Graphics2D g2 = (Graphics2D)g;
        g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        
        g2.setPaint(Color.DARK_GRAY);
        for (Shape oShape : _coShapesToDraw) {
        	g2.draw(oShape);
        }
        super.paint(g);
	}
}
