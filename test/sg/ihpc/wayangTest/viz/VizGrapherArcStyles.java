package sg.ihpc.wayangTest.viz;

import java.awt.BasicStroke;
import java.awt.Stroke;
import java.util.ArrayList;

public class VizGrapherArcStyles {
	
	private int _iNumDifferentArcWidths;
	private ArrayList<BasicStroke> _coSolidStrokes;
	private ArrayList<BasicStroke> _coDottedStrokes;
	
	VizGrapherArcStyles(int iNumDifferentArcWidths) {
		_iNumDifferentArcWidths = iNumDifferentArcWidths;
		
		float[] aflDashConfig_SolidLine = {1.0f, 0.0f};
		_coSolidStrokes = generateStrokeWidthsForStyle(		BasicStroke.CAP_SQUARE,
															BasicStroke.JOIN_MITER,
															aflDashConfig_SolidLine);
		float[] aflDashConfig_DottedLine = {1.0f, _iNumDifferentArcWidths * 1.5f};
		_coDottedStrokes = generateStrokeWidthsForStyle(	BasicStroke.CAP_ROUND,
															BasicStroke.JOIN_ROUND,
															aflDashConfig_DottedLine );
	}
	ArrayList<BasicStroke> generateStrokeWidthsForStyle(	int iCap,
															int iJoin,
															float[] aflDashConfig )
	{
		ArrayList<BasicStroke> coStrokes = new ArrayList<BasicStroke>(_iNumDifferentArcWidths - 1);
		for (int i=1; i < _iNumDifferentArcWidths-1; i++) {
			coStrokes.add(new BasicStroke(	i * 1.0f, //float width
											iCap,     //int cap
											iJoin,    //int join
											10.0f,    //float miter_limit
											aflDashConfig, //float[] dash
											0.0f      //float dash_phase
											));
		}
		coStrokes.add(new BasicStroke(_iNumDifferentArcWidths * 1.0f));
		return coStrokes;
	}
	Stroke getStrokeWeightAndStyle(VizGrapherArc oArc)
	{
		int iDescriptionsCount = oArc.getDescriptionsCount();
		VizGrapherArc.Strokes eStroke = oArc.getStrokeStyle();
		int iStrokeWidthIndex;
		if (iDescriptionsCount < 4) {
    		iStrokeWidthIndex = iDescriptionsCount-1;
    	} else {
    		iStrokeWidthIndex = _iNumDifferentArcWidths-2;
    	}
    	Stroke oStroke = _coSolidStrokes.get(iStrokeWidthIndex);
        switch (eStroke) {
        	case DOTTED: oStroke = _coDottedStrokes.get(iStrokeWidthIndex); break;
        }
        return oStroke;
	}
}
