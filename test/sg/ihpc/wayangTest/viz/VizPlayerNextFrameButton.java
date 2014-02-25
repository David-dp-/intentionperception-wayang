package sg.ihpc.wayangTest.viz;

import java.awt.Component;

import javax.swing.JButton;

@SuppressWarnings("serial")
public class VizPlayerNextFrameButton extends JButton {
	
	private VizWindow _oViz;
	
	VizPlayerNextFrameButton(VizWindow oViz) {
		super("Next frame");
		setAlignmentX(Component.LEFT_ALIGNMENT);
	    setEnabled(false);
		addActionListener(new VizPlayerNextFrameButtonListener());
		
		_oViz = oViz;
	}
	/* I suspect we need sync because the UI (of which this is a part) runs
	 * mostly on the main thread, but we also call this from the
	 * test/clp thread (in foGetInputTerm() via considerEnablingNextFrameButton)
	 */
	synchronized public void setEnabled(boolean b) {
		super.setEnabled(b);
	}
	VizWindow getViz() {
		return _oViz;
	}
}
