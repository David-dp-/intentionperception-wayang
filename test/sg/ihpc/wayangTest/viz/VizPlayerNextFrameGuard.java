package sg.ihpc.wayangTest.viz;

public class VizPlayerNextFrameGuard {

	synchronized public void waitForButtonPress() {
		try {
            this.wait();
        } catch (InterruptedException e) {}
	}
	synchronized public void notifyWaitersOfButtonPress() {
		this.notifyAll();
	}
}
