package sg.ihpc.wayang;

import java.io.IOException;

import com.parctechnologies.eclipse.CompoundTerm;
import com.parctechnologies.eclipse.EXDRInputStream;
import com.parctechnologies.eclipse.FromEclipseQueue;
import com.parctechnologies.eclipse.QueueListener;

public class InferredTermConsumer implements QueueListener {
    FromEclipseQueue stInputQueueStream = null;
    EXDRInputStream stFormattedInputQueueStream = null;
    WorldModel _oWorldModel = null;
    
    InferredTermConsumer(WorldModel oWorldModel) {
    	_oWorldModel = oWorldModel;
    }

	@Override
	public void dataAvailable(Object oSource) {
    	if (stInputQueueStream == null) {
    		stInputQueueStream = (FromEclipseQueue) oSource;
    		stFormattedInputQueueStream = new EXDRInputStream(stInputQueueStream);
    	}
    	CompoundTerm oTerm = null;
    	try {
    		oTerm = (CompoundTerm)stFormattedInputQueueStream.readTerm();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		//This call might block waiting for synchronization on VizWindow
		// to be released
		_oWorldModel.fHandleOutputTerm(oTerm);
	}

	@Override
	public void dataRequest(Object arg0) {
		// Never called for Consumer's
	}

}
