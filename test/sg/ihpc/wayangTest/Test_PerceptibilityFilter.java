package sg.ihpc.wayangTest;

import java.io.IOException;

import sg.ihpc.wayang.WorldToObserver;

import org.testng.annotations.Test;

import com.parctechnologies.eclipse.EclipseException;

public class Test_PerceptibilityFilter {

	@Test
	public void resultValuesAreCorrect()
	throws EclipseException, IllegalAccessException, IOException
	{
		boolean bSuccess
			= WorldToObserver.go(	null,   //sPathToKnowledgeBaseSource
									"test/ECLiPSe/test_perceptibilityFilter.pro",
									"test_perceptibilityFilter",
									null ); //oWorldModel
		
		assert bSuccess;
	}
}
