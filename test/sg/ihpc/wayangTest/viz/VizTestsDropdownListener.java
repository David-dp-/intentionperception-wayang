package sg.ihpc.wayangTest.viz;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class VizTestsDropdownListener implements ActionListener {

	@Override
	public void actionPerformed(ActionEvent e) {
		
		VizTestsDropdown oDropdown = (VizTestsDropdown) e.getSource();
		
		VizWindow oViz = oDropdown.getViz();
		oViz.resetGraph();
		oViz.indicateTestOutcomeNotYetKnown(false); //false means not waiting
		
		oDropdown.executeTestItem(	oDropdown.getSelectedIndex() );
	}

}
