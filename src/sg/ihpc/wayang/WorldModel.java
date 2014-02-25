package sg.ihpc.wayang;

import com.parctechnologies.eclipse.CompoundTerm;

public interface WorldModel {

	//This call might block waiting for synchronization on VizWindow
	// to be released
	public CompoundTerm foGetInputTerm();
	
	//This call might block waiting for synchronization on VizWindow
	// to be released
	public void fHandleOutputTerm(CompoundTerm oOutputTerm);
	
	public boolean fbTestSucceeded();
}
