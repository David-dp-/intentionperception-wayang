package sg.ihpc.wayangTest;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import sg.ihpc.wayang.Constants;

import com.parctechnologies.eclipse.CompoundTerm;
import com.parctechnologies.eclipse.CompoundTermImpl;

public class PerceptualLimits {
	
	static private Set<String> s_csLimitNames;
	static {
		s_csLimitNames = new HashSet<String>();
		s_csLimitNames.add(Constants.s_sMinPerceptibleChangeInPosition);
		s_csLimitNames.add(Constants.s_sMinPerceptibleArea);
		s_csLimitNames.add(Constants.s_sMinPerceptibleRGBDifference);
		s_csLimitNames.add(Constants.s_sMaxElapsedTimeToAvoidFlicker);
		s_csLimitNames.add(Constants.s_sMinAreaOverDistanceToAvoidFlicker);
		s_csLimitNames.add(Constants.s_sMinPerceptibleAreaChangePerMsec);
		s_csLimitNames.add(Constants.s_sMinPerceptibleColorChangePerMsec);
		s_csLimitNames.add(Constants.s_sMinPerceptibleAccelerationOverSpeedRatio);
	}
	private Map<String,Float> _msflLimits;

	public PerceptualLimits(Properties oProperties)
	{
		_msflLimits = new HashMap<String,Float>();
		
		System.out.println("   Configured perceptual limits:");
		Float fl;
        for (String sLimitName : s_csLimitNames) {
        	fl = Float.valueOf(oProperties.getProperty(sLimitName));
        	_msflLimits.put(sLimitName, fl);
        	System.out.println("     "+sLimitName+" = "+fl);
        }
	}
	public List<CompoundTerm> appendLimitsAsTerms(List<CompoundTerm> coSettings)
	{
		CompoundTerm oSetting;
		for (String sLimitName : _msflLimits.keySet()) {
			oSetting = new CompoundTermImpl(sLimitName,
											_msflLimits.get(sLimitName) );
			coSettings.add(oSetting);
		}
		return coSettings;
	}
}
