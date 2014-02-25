package sg.ihpc.wayang.swf;

import com.jswiff.swfrecords.Color;
import com.jswiff.swfrecords.RGB;
import com.jswiff.swfrecords.RGBA;
import com.parctechnologies.eclipse.CompoundTerm;
import com.parctechnologies.eclipse.CompoundTermImpl;

public class RGBCombo {
	private short _iErrorValue = -1;
	private short _iRedValue = _iErrorValue;
	private short _iGreenValue = _iErrorValue;
	private short _iBlueValue = _iErrorValue;
	
	public RGBCombo(Color oColor) {
		if (oColor == null) {
			//ignore
		} else if (oColor instanceof RGB) {
			_iRedValue = ((RGB)oColor).getRed();
			_iGreenValue = ((RGB)oColor).getGreen();
			_iBlueValue = ((RGB)oColor).getBlue();
		} else if (oColor instanceof RGBA) {
			_iRedValue = ((RGBA)oColor).getRed();
			_iGreenValue = ((RGBA)oColor).getGreen();
			_iBlueValue = ((RGBA)oColor).getBlue();
		}
	}
	public short getRedValue() {
		return _iRedValue;
	}
	public short getGreenValue() {
		return _iGreenValue;
	}
	public short getBlueValue() {
		return _iBlueValue;
	}
	public short getErrorValue() {
		return _iErrorValue;
	}
	
	public boolean fbErrorPresent() {
		return (_iRedValue == _iErrorValue || _iGreenValue == _iErrorValue || _iBlueValue == _iErrorValue);
	}
	public CompoundTerm foToCompoundTerm() {
		Object[] aoTermArgs = new Object[3];
		// ECLiPSe's EXDR format doesn't support Short's, so we use Integer instead.
		aoTermArgs[0] = new Integer(_iRedValue);
		aoTermArgs[1] = new Integer(_iGreenValue);
		aoTermArgs[2] = new Integer(_iBlueValue);
		return new CompoundTermImpl("color", aoTermArgs);
	}
}
