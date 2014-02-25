package sg.ihpc.wayangTest.viz;

import javax.swing.JCheckBox;

@SuppressWarnings("serial")
public class VizTestsStopBeforeNextFrame extends JCheckBox {
	
	private VizWindow _oViz;

	VizTestsStopBeforeNextFrame(VizWindow oViz) {
		super("Stop before each new animation frame");
		setSelected(true);
		
		_oViz = oViz;
	}
	VizWindow getViz() {
		return _oViz;
	}
}
