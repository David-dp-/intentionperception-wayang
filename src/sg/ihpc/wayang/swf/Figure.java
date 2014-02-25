package sg.ihpc.wayang.swf;

import java.lang.IllegalArgumentException;

import com.jswiff.swfrecords.FillStyle;
import com.jswiff.swfrecords.FillStyleArray;
import com.jswiff.swfrecords.Matrix;
import com.jswiff.swfrecords.ShapeWithStyle;
import com.jswiff.swfrecords.tags.PlaceObject2;
import com.parctechnologies.eclipse.CompoundTerm;

public class Figure {
	
	private Integer _iShapesFudgeFactor;
	private Float _flTwipsPerSpatialUnit;
	
	private Integer _iId;
	private Integer _iDepth;
	private int _iXPos;
	private int _iYPos;
	private RGBCombo _oRGBCombo;
	private Shape _oShape;
	
	Figure() {}
	
	Figure(	int				iId,
			ShapeWithStyle	oShapeWithStyle,
			Float			flTwipsPerSpatialUnit,
			Integer			iShapesFudgeFactor )
	{
		_flTwipsPerSpatialUnit = flTwipsPerSpatialUnit;
		_iShapesFudgeFactor = iShapesFudgeFactor;
		
	    FillStyleArray oFillStyleArray;
	    FillStyle oFillStyle;
	    
	    _iId = iId;
	    
	    //System.out.println("new Figure; id = "+_iId); //DEBUG
	    
	    if (oShapeWithStyle != null) {
			//Get fill color
			oFillStyleArray = oShapeWithStyle.getFillStyles();
			if (oFillStyleArray != null &&
				oFillStyleArray.getSize() == 1 )
			{
				oFillStyle = oFillStyleArray.getStyle(1); //javadoc:"WARNING: indexes start at 1, not at 0!"
				if (oFillStyle != null) {
					_oRGBCombo = new RGBCombo(oFillStyle.getColor());
				}
			}
			
			//Get shape info
			_oShape = new Shape(oShapeWithStyle.getShapeRecords(),
    							_flTwipsPerSpatialUnit,
								_iShapesFudgeFactor );
		}
	}
	
	Integer getId() {
		return _iId;
	}
	Integer getDepth() {
		return _iDepth;
	}
	int getXPos() {
		return _iXPos;
	}
	int getYPos() {
		return _iYPos;
	}
	
	void fUpdate(PlaceObject2 oPlaceObject2)
	throws IllegalArgumentException {
		if (oPlaceObject2 == null) {
			throw new IllegalArgumentException("PlaceObject2 must be non-null.");
		}

		int iDepth = oPlaceObject2.getDepth();
		if (iDepth < 1) {
			throw new IllegalArgumentException("Depth must be positive. (Given:"+iDepth+")");
		}
		_iDepth = iDepth;
		
		Matrix matrix = oPlaceObject2.getMatrix();
	    int iTranslateX = matrix.getTranslateX(),
	    	iTranslateY = matrix.getTranslateY();
		if (iTranslateX < 0) {
			throw new IllegalArgumentException("X position must be non-negative. (Given:"+iTranslateX+")");
		}
		if (iTranslateY < 0) {
			throw new IllegalArgumentException("Y position must be non-negative. (Given:"+iTranslateY+")");
		}
    	if (matrix != null) {
    		_iXPos = iTranslateX;
    		_iYPos = iTranslateY;
    		
    	    //System.out.println("updating Figure id = "+_iId); //DEBUG

    		/* The matrix's scaleX value is the cosine of the inclination angle, and its rotateSkew1 is
    		 * the negative sine of the angle (we use the negative sine rather than the sine because
    		 * SWFs use an origin in the upper left rather than the lower left as we prefer to).
    		 */
    		double dSignum = Math.signum(matrix.getRotateSkew1());
    		double dTotalClockwiseRotationAngleSoFar = Math.toDegrees( dSignum * Math.acos(matrix.getScaleX()) );
    	    _oShape.fUpdate(dTotalClockwiseRotationAngleSoFar);
    	}
    	//We ignore rotation and scaling for now, so rest of matrix is not copied in here
	}
	
	boolean fbRGBComboErrorPresent() {
		if (_oRGBCombo == null) {
			return true;
		}
		return _oRGBCombo.fbErrorPresent();
	}
	CompoundTerm foRGBComboToCompoundTerm() {
		if (_oRGBCombo == null) {
			return null;
		}
		return _oRGBCombo.foToCompoundTerm();
	}
	
	CompoundTerm foShapeToCompoundTerm() {
		if (_oShape == null) {
			return null;
		}
		return _oShape.foToCompoundTerm();
	}
}
