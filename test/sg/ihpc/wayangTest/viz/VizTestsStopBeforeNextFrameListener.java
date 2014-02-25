package sg.ihpc.wayangTest.viz;

import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;

import javax.swing.JCheckBox;

public class VizTestsStopBeforeNextFrameListener implements ItemListener {

	public void itemStateChanged(ItemEvent e) {
		VizTestsStopBeforeNextFrame stopAfterEachFrame
			= (VizTestsStopBeforeNextFrame)e.getSource();
		VizWindow oViz = stopAfterEachFrame.getViz();
		if (stopAfterEachFrame == null) {
			System.err.println("Null returned for e.getSource()");
		} else if (stopAfterEachFrame.isSelected()) {
			oViz.getIControlState().setStopAfterEachFrame(true);
		} else {
			oViz.getIControlState().setStopAfterEachFrame(false);
		}
	}

}
