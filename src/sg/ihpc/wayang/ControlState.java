package sg.ihpc.wayang;

public class ControlState implements IControlState {
	private boolean _bStopAfterEachFrame = true;
	private boolean _bAdvanceAtNextFrameRequest = false;
	
	private boolean _bUseVisualizer = true;
	private boolean _bStopCLPOnMismatch = true;
	
	public boolean getStopAfterEachFrame() {
		return _bStopAfterEachFrame;
	}
	public boolean getAdvanceAtNextFrameRequest() {
		return _bAdvanceAtNextFrameRequest;
	}
	public boolean getUseVisualizer() {
		return _bUseVisualizer;
	}
	public boolean getStopCLPOnMismatch() {
		return _bStopCLPOnMismatch;
	}

	public void setStopAfterEachFrame(boolean bStopAfterEachFrame) {
		_bStopAfterEachFrame = bStopAfterEachFrame;
	}
	public void setAdvanceAtNextFrameRequest(boolean bAdvanceAtNextFrameRequest) {
		_bAdvanceAtNextFrameRequest = bAdvanceAtNextFrameRequest;
	}
}
