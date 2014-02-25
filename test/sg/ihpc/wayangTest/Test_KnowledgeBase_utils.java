package sg.ihpc.wayangTest;

import java.io.IOException;

import sg.ihpc.wayang.WorldToObserver;

import org.testng.annotations.Test;

import com.parctechnologies.eclipse.EclipseException;

public class Test_KnowledgeBase_utils {
	
	@Test
	public void resultValuesAreCorrect()
	throws EclipseException, IllegalAccessException, IOException
	{
		boolean bSuccess
			= WorldToObserver.go(	"src/ECLiPSe/Observer/KnowledgeBase_utils.ecl",
									"test/ECLiPSe/test_KnowledgeBase_utils.pro",
									"test_KnowledgeBase_utils",
									null ); //oWorldModel
		
		assert bSuccess;
	}
}
