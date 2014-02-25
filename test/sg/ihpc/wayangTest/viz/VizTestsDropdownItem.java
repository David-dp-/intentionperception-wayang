package sg.ihpc.wayangTest.viz;

import java.io.IOException;

import sg.ihpc.wayangTest.Main;

import com.parctechnologies.eclipse.EclipseException;

//Adapted from http://en.wikipedia.org/wiki/Strategy_pattern

public class VizTestsDropdownItem {
	/*	The EmbeddedEclipse java singleton that wraps the EclipseCLP engine DLL
     *  doesn't provide a way to flush all rules after one unit test so a following
     *  unit test could start fresh with its own set of rules. (Nor does the
     *  singleton permit a way to retract all assertions without naming each
     *  predicate used in the assertions.) So, we can't currently define more than
     *  one unit test per test bundle.
     *  
     *  We might have to migrate to OutOfProcessEclipse instead, but that is said
     *  to have a higher overhead due to killing and starting new sibling procs.
     *  David wrote to the EclipseCLP mailing list 16 Dec 2010 for a recommendation.
     */
	private String	_sDisplayName,
					_sKnowledgeBaseFilepath,
					_sSWFPath,
					_sTestFilepath,
					_sTestPredicate;
	private VizWindow _oViz;
	
	public VizTestsDropdownItem(String sDisplayName,
								String sKnowledgeBaseFilepath,
								String sSWFPath,
								String sTestFilepath,
								String sTestPredicate,
								VizWindow oViz )
	{
		_sDisplayName 			= sDisplayName;
		_sKnowledgeBaseFilepath = sKnowledgeBaseFilepath;
		_sSWFPath 				= sSWFPath;
		_sTestFilepath 			= sTestFilepath;
		_sTestPredicate			= sTestPredicate;
		_oViz					= oViz;
	}
	
	String getDisplayName() { return _sDisplayName; }
	
    void execute()
	throws EclipseException, IOException, IllegalAccessException
	{
		_oViz.setSWFPath(_sSWFPath);
		
		Main.launchEclipseThread(	_sKnowledgeBaseFilepath,
									_sSWFPath,
									_sTestFilepath,
									_sTestPredicate );	
	}
}