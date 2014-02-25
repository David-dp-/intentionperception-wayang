package sg.ihpc.wayangTest.viz;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class VizPlayerNextFrameButtonListener implements ActionListener {

	@Override
	public void actionPerformed(ActionEvent e) {
		
		VizPlayerNextFrameButton nextButton = (VizPlayerNextFrameButton)e.getSource();
		nextButton.setEnabled(false);
		
		VizWindow oViz = nextButton.getViz();
		oViz.getIControlState().setAdvanceAtNextFrameRequest(true);
		oViz.indicateTestOutcomeNotYetKnown(false); //false means not waiting
		
		//Permit the test/clp thread to resume
		oViz.getNextFrameGuard().notifyWaitersOfButtonPress();
	}

}
