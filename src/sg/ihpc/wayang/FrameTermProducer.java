package sg.ihpc.wayang;

import java.io.IOException;

import com.parctechnologies.eclipse.CompoundTerm;
import com.parctechnologies.eclipse.EXDROutputStream;
import com.parctechnologies.eclipse.QueueListener;
import com.parctechnologies.eclipse.ToEclipseQueue;

public class FrameTermProducer implements QueueListener {
	
	ToEclipseQueue _stOutputQueueStream = null;
    EXDROutputStream _stFormattedOutputQueueStream = null;
    WorldModel _oWorldModel;
    
    public FrameTermProducer(WorldModel oWorldModel)
    throws IOException, IllegalArgumentException, IllegalAccessException {
    	super();
    	_oWorldModel = oWorldModel;
    }
    
	@Override
	public void dataAvailable(Object arg0) {
		// TODO Auto-generated method stub
	}

	@Override
	public void dataRequest(Object oSource) {
		if (_stOutputQueueStream == null) {
    		_stOutputQueueStream = (ToEclipseQueue) oSource;
    		_stFormattedOutputQueueStream = new EXDROutputStream(_stOutputQueueStream);
    	}
    	try {
    		//This call might block waiting for synchronization on VizWindow
    		// to be released
    		CompoundTerm oInputTerm = _oWorldModel.foGetInputTerm();
    		
    		_stFormattedOutputQueueStream.write(oInputTerm);
    		_stFormattedOutputQueueStream.flush();
    	} catch(IOException ioe) {
    		System.out.println("Problem writing to out-queue to ECLiPSe...");
    		ioe.printStackTrace();
    	}
	}

}
