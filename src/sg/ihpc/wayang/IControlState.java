package sg.ihpc.wayang;

public interface IControlState {
	public boolean getStopAfterEachFrame();
	public boolean getAdvanceAtNextFrameRequest();
	public boolean getUseVisualizer();
	public boolean getStopCLPOnMismatch();
	
	public void setAdvanceAtNextFrameRequest(boolean bAdvanceAtNextFrameRequest);
	public void setStopAfterEachFrame(boolean b);
}
