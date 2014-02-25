package sg.ihpc.wayang.swf;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import sg.ihpc.wayang.Constants;

import com.jswiff.swfrecords.CurvedEdgeRecord;
import com.jswiff.swfrecords.ShapeRecord;
import com.jswiff.swfrecords.StraightEdgeRecord;
import com.jswiff.swfrecords.StyleChangeRecord;

import com.parctechnologies.eclipse.Atom;
import com.parctechnologies.eclipse.CompoundTerm;
import com.parctechnologies.eclipse.CompoundTermImpl;

public class Shape {
	final static private Map<String,Double> s_msdMaxNormAnglePerShapeType = fmsdMaxNormAnglesPerShapeType();
	
	private Integer _iShapesFudgeFactor;
	private Float _flTwipsPerSpatialUnit;
	
	private boolean _bPolygon;
	private int _iNumSides;
	
	private String _sShapeType;
	
	/* Use floats and doubles in order to minimize error from trigonometic and arithmetic operations.
	 *  We use float's only for (x,y) coords of the shape vertices, because these values result from
	 *  dividing int's (from SWF file) by float value of setting for "twips per spatial unit";
	 *  there would be little benefit to using double's in that case.
	 *  
	 * Note also that these vertices are centered around the coord origin (which is in a corner of
	 *  the movie display), NOT the center of the shape as it appears in a display. So, some coord
	 *  values will be negative.
	 */
	private List<Float> _cflXsOfShapeVertices;
	private List<Float> _cflYsOfShapeVertices;
	
	private double _dInitialLongestAxisInclineAngle;
	private double _dInitialSecondLongestAxisInclineAngle;
	private double _dInitialShortestAxisInclineAngle;
	
	private Double _dLongestAxisSU;
	private Double _dLongestAxisAngle;
	private Double _dSecondLongestAxisSU;
	private Double _dSecondLongestAxisAngle;
	private Double _dShortestAxisSU;
	private Double _dShortestAxisAngle;
	private List<Integer> _ciShapeArgs = new ArrayList<Integer>();
	
	private Double _dTriangleArea;
	
	static private Map<String,Double> fmsdMaxNormAnglesPerShapeType() {
		Map<String,Double> msd = new HashMap<String,Double>();
		msd.put(Constants.s_sFunctor_Square, 	90.0);
		msd.put(Constants.s_sFunctor_Oval, 		180.0);
		msd.put(Constants.s_sFunctor_Rectangle, 180.0);
		msd.put(Constants.s_sFunctor_Triangle, 	360.0);
		return msd;
	}
	
	Shape(	ShapeRecord[]	aoShapeRecords,
			Float			flTwipsPerSpatialUnit,
			Integer			iShapesFudgeFactor )
	{
		_sShapeType = Constants.s_sFunctor_UnrecognizedShape;
		
		_cflXsOfShapeVertices = new ArrayList<Float>();
		_cflYsOfShapeVertices = new ArrayList<Float>();
		
		_flTwipsPerSpatialUnit = flTwipsPerSpatialUnit;
		_iShapesFudgeFactor = iShapesFudgeFactor;
    	
    	StyleChangeRecord oStyleChangeRecord = null;
    	List<StraightEdgeRecord> coStraightEdgeRecords = new ArrayList<StraightEdgeRecord>();
    	List<CurvedEdgeRecord> coCurvedEdgeRecords = new ArrayList<CurvedEdgeRecord>();
    	for (ShapeRecord sr : aoShapeRecords) {
    		if (sr instanceof StyleChangeRecord) {
    			oStyleChangeRecord = (StyleChangeRecord)sr;
    		} else if (sr instanceof StraightEdgeRecord) {
    			coStraightEdgeRecords.add((StraightEdgeRecord)sr);
    		} else if (sr instanceof CurvedEdgeRecord) {
    			coCurvedEdgeRecords.add((CurvedEdgeRecord)sr);
    		} else {
    			System.err.println("SUSPICIOUS: Unrecognized ShapeRecord subtype");
    		}
    	}
    	if (coStraightEdgeRecords.size() > 0 && coCurvedEdgeRecords.size() == 0) {
    		//The shape is a finite-sided polygon
    		_bPolygon = true;
    		_iNumSides = coStraightEdgeRecords.size();
    		fRememberInitialCoordsOfVertices_Polygon(	oStyleChangeRecord,
    													coStraightEdgeRecords );
    		fIdentifyProperties();
    	} else if (coStraightEdgeRecords.size() == 0 && coCurvedEdgeRecords.size() > 0) {
    		//The shape is either a circle or oval
    		_bPolygon = false;
    		_iNumSides = -1;
    		fRememberInitialCoordsOfVertices_Oval(	oStyleChangeRecord,
													coCurvedEdgeRecords );
    		fIdentifyProperties();
    	} else {
			//Leave shape functor as "unrecognizedShape" with no args
		}
    	
    	/*//DEBUG
    	System.out.println("Incline angle of major axis: "+Math.round(_dInitialLongestAxisInclineAngle));
    	int x, y;
    	for (int i=0; i < _cflXsOfShapeVertices.size(); i++) {
    		x = Math.round(_cflXsOfShapeVertices.get(i));
    		y = Math.round(_cflYsOfShapeVertices.get(i));
    		System.out.println(" ("+x+", "+y+")");
    	}*/
	}
	void fIdentifyProperties() {
		if (_bPolygon) {
    		if (_iNumSides == 4) {
    			fRememberMeasurements_Rectangle();
    			
    			if (fbMajorAxisAndMinorAxisAreSameLength()) {
        			_sShapeType = Constants.s_sFunctor_Square;
        		} else {
        			_sShapeType = Constants.s_sFunctor_Rectangle;
        		}
    		} else if (_iNumSides == 3) {
    			fRememberMeasurements_Triangle();
    			
    			_sShapeType = Constants.s_sFunctor_Triangle;
    		} else {
    			_sShapeType = Constants.s_sFunctor_PolygonSides;
    		}
		} else { //_bPolygon == false
			fRememberMeasurements_Oval();
			
    		if (fbMajorAxisAndMinorAxisAreSameLength()) {
    			_sShapeType = Constants.s_sFunctor_Circle;
    		} else {
    			_sShapeType = Constants.s_sFunctor_Oval;
    		}
		}
	}
	void fUpdate(double dClockwiseRotationAngle)
	{
		Double dMaxNormAngle = s_msdMaxNormAnglePerShapeType.get(_sShapeType);
		//System.out.println(" update clockwise angle: "+Math.round(dClockwiseRotationAngle)+" norm max: "+dMaxNormAngle); //DEBUG
		if (dMaxNormAngle != null) {
			_dLongestAxisAngle
				= fdNormalizeAngle(	_dInitialLongestAxisInclineAngle + dClockwiseRotationAngle,
									dMaxNormAngle );
			_dSecondLongestAxisAngle
				= fdNormalizeAngle(	_dInitialSecondLongestAxisInclineAngle + dClockwiseRotationAngle,
									dMaxNormAngle );
			_dShortestAxisAngle
				= fdNormalizeAngle(	_dInitialShortestAxisInclineAngle + dClockwiseRotationAngle,
									dMaxNormAngle );
	    }
		
		_ciShapeArgs.clear();
		if (_bPolygon) {
    		if (_iNumSides == 4) {
    			if (_sShapeType.equals(Constants.s_sFunctor_Square)) {
        			_dSecondLongestAxisAngle = null; //drop redundant "shorter" axis angle (not really necessary, but done for housekeeping)
        			
        			_ciShapeArgs.add((int) Math.round(_dLongestAxisSU));
        			_ciShapeArgs.add((int) Math.round(_dLongestAxisAngle));
        		} else if (_sShapeType.equals(Constants.s_sFunctor_Rectangle)) {
        			_ciShapeArgs.add((int) Math.round(_dLongestAxisSU));
        			_ciShapeArgs.add((int) Math.round(_dLongestAxisAngle));
        			_ciShapeArgs.add((int) Math.round(_dSecondLongestAxisSU));
        		} //else, maybe it's an "unrecognized shape"
    		} else if (_sShapeType.equals(Constants.s_sFunctor_Triangle)) {
    			_ciShapeArgs.add((int) Math.round(_dLongestAxisSU));
    			_ciShapeArgs.add((int) Math.round(_dLongestAxisAngle));
    			_ciShapeArgs.add((int) Math.round(_dSecondLongestAxisSU));
    			_ciShapeArgs.add((int) Math.round(_dSecondLongestAxisAngle));
    			_ciShapeArgs.add((int) Math.round(_dShortestAxisSU));
    			_ciShapeArgs.add((int) Math.round(_dShortestAxisAngle));
    			_ciShapeArgs.add((int) Math.round(_dTriangleArea));
    		} else {
    			_ciShapeArgs.add(_iNumSides);
    		}
		} else { //_bPolygon == false
			if (_sShapeType.equals(Constants.s_sFunctor_Circle)) {
    			_dSecondLongestAxisAngle = null; //drop redundant "shorter" axis angle (not really necessary, but done for housekeeping)
    			
    			_ciShapeArgs.add((int) Math.round(_dLongestAxisSU));
    		} else if (_sShapeType.equals(Constants.s_sFunctor_Oval)) {
    			_ciShapeArgs.add((int) Math.round(_dLongestAxisSU));
    			_ciShapeArgs.add((int) Math.round(_dLongestAxisAngle));
    			_ciShapeArgs.add((int) Math.round(_dSecondLongestAxisSU));
    		} //else, maybe it's an "unrecognized shape"
		}
	}
	static double fdNormalizeAngle(	double dAngle,
									double dMaxDegrees )
	{
		for (;;) {
			if (0.0 <= dAngle && dAngle <= dMaxDegrees) {
				break;
			} else if (dMaxDegrees < dAngle) {
				dAngle -= dMaxDegrees;
			} else if (dAngle < 0.0) {
				dAngle += dMaxDegrees;
			}
		}
		return dAngle;
	}
	CompoundTerm foToCompoundTerm() {
		int iArity = _ciShapeArgs.size();
		if (iArity == 0) {
			return new Atom(_sShapeType);
		}
		Object[] aoTermArgs = new Object[iArity];
		for (int i=0; i < iArity; i++) {
			aoTermArgs[i] = _ciShapeArgs.get(i);
		}
		return new CompoundTermImpl(_sShapeType, aoTermArgs);
	}
	
	
	boolean fbMajorAxisAndMinorAxisAreSameLength() {
		return (Math.abs(_dLongestAxisSU - _dSecondLongestAxisSU) <= _iShapesFudgeFactor);
	}
	void fRememberInitialCoordsOfVertices_Polygon(	StyleChangeRecord oStyleChangeRecord,
													List<StraightEdgeRecord> coStraightEdgeRecords )
	{
		float x, deltaX, y, deltaY;
		
		x = oStyleChangeRecord.getMoveToX() / _flTwipsPerSpatialUnit;
		y = oStyleChangeRecord.getMoveToY() / _flTwipsPerSpatialUnit;
		
		//System.out.println("  X: "+oStyleChangeRecord.getMoveToX()+" / "+_flTwipsPerSpatialUnit+" => "+x); //DEBUG
		//System.out.print("  Y: "+oStyleChangeRecord.getMoveToY()+" / "+_flTwipsPerSpatialUnit+" => "+y); //DEBUG
		
		//We want to change the coord origin from upper left, as it is in SWF files, to lower left
		// So, we flip the sign of y
		y = (float) fdFlipSign(y);
		
		//System.out.println("; flipped: "+y); //DEBUG
		
		_cflXsOfShapeVertices.add(x);
		_cflYsOfShapeVertices.add(y);
		for (StraightEdgeRecord oStraightEdgeRecord : coStraightEdgeRecords) {
			deltaX = oStraightEdgeRecord.getDeltaX() / _flTwipsPerSpatialUnit;
			deltaY = oStraightEdgeRecord.getDeltaY() / _flTwipsPerSpatialUnit;
			
			//System.out.println("    deltaX: "+oStraightEdgeRecord.getDeltaX()+" / "+_flTwipsPerSpatialUnit+" => "+deltaX); //DEBUG
			//System.out.print("    deltaY: "+oStraightEdgeRecord.getDeltaY()+" / "+_flTwipsPerSpatialUnit+" => "+deltaY); //DEBUG
			
			//We want to change the coord origin from upper left, as it is in SWF files, to lower left
			// So, we flip the sign of deltaY
			deltaY = (float) fdFlipSign(deltaY);
			
			//System.out.println("; flipped: "+deltaY); //DEBUG
			
			x = x + deltaX;
			y = y + deltaY;
			
			//System.out.println("  X: "+x); //DEBUG
			//System.out.println("  Y: "+y); //DEBUG
			
			_cflXsOfShapeVertices.add(x);
			_cflYsOfShapeVertices.add(y);
		}
		//The last vertex found above was actually a return to the first vertex, so drop it
		_cflXsOfShapeVertices.remove(_cflXsOfShapeVertices.size()-1);
		_cflYsOfShapeVertices.remove(_cflYsOfShapeVertices.size()-1);
	}
	static double fdFlipSign(double d) {
		return Math.signum(d) * -1.0 * Math.abs(d);
	}
	void fRememberInitialCoordsOfVertices_Oval(	StyleChangeRecord oStyleChangeRecord,
												List<CurvedEdgeRecord> coCurvedEdgeRecords )
	{
		float x, deltaX, y, deltaY;
			
		x = oStyleChangeRecord.getMoveToX() / _flTwipsPerSpatialUnit;
		y = oStyleChangeRecord.getMoveToY() / _flTwipsPerSpatialUnit;
		
		//System.out.println("  X: "+oStyleChangeRecord.getMoveToX()+" / "+_flTwipsPerSpatialUnit+" => "+x); //DEBUG
		//System.out.print("  Y: "+oStyleChangeRecord.getMoveToY()+" / "+_flTwipsPerSpatialUnit+" => "+y); //DEBUG
		
		//We want to change the coord origin from upper left, as it is in SWF files, to lower left
		// So, we flip the sign of y
		y = (float) fdFlipSign(y);
		
		//System.out.println("; flipped: "+y); //DEBUG
		
		_cflXsOfShapeVertices.add(x);
		_cflYsOfShapeVertices.add(y);
		for (CurvedEdgeRecord oCurvedEdgeRecord : coCurvedEdgeRecords) {
			deltaX = (oCurvedEdgeRecord.getControlDeltaX() + oCurvedEdgeRecord.getAnchorDeltaX()) / _flTwipsPerSpatialUnit;
			deltaY = (oCurvedEdgeRecord.getControlDeltaY() + oCurvedEdgeRecord.getAnchorDeltaY()) / _flTwipsPerSpatialUnit;
			
			//System.out.println("    deltaX: ("+oCurvedEdgeRecord.getControlDeltaX()+" + "+oCurvedEdgeRecord.getAnchorDeltaX()+") / "+_flTwipsPerSpatialUnit+" => "+deltaX); //DEBUG
			//System.out.print("    deltaY: ("+oCurvedEdgeRecord.getControlDeltaY()+" + "+oCurvedEdgeRecord.getAnchorDeltaY()+") / "+_flTwipsPerSpatialUnit+" => "+deltaY); //DEBUG
			
			//We want to change the coord origin from upper left, as it is in SWF files, to lower left
			// So, we flip the sign of deltaY
			deltaY = (float) fdFlipSign(deltaY);
			
			//System.out.println("; flipped: "+deltaY); //DEBUG
			
			x = x + deltaX;
			y = y + deltaY;
			
			//System.out.println("  X: "+x); //DEBUG
			//System.out.println("  Y: "+y); //DEBUG
			
			_cflXsOfShapeVertices.add(x);
			_cflYsOfShapeVertices.add(y);
		}
		//The last vertex found above was actually a return to the first vertex, so drop it
		_cflXsOfShapeVertices.remove(_cflXsOfShapeVertices.size()-1);
		_cflYsOfShapeVertices.remove(_cflYsOfShapeVertices.size()-1);
	}
	/*
	 * Returns a list, {length of 1st side, angle of incline of that side}.
	 */
	List<Double> fcdMeasurements_StraightSide(	float flEdgeProjectionOntoX,
												float flEdgeProjectionOntoY )
	{
		double dSideLength = Math.sqrt((	Math.pow(flEdgeProjectionOntoX,2)
										  + Math.pow(flEdgeProjectionOntoY,2) ));
		double dInclineDegrees = Math.toDegrees( Math.atan(flEdgeProjectionOntoY/flEdgeProjectionOntoX) );
		
		List<Double> cdMeasurements = new ArrayList<Double>();
		cdMeasurements.add(dSideLength);
		cdMeasurements.add(dInclineDegrees);
		//System.out.println("  Straight side; length: "+dSideLength+", angle: "+dInclineDegrees+")"); //DEBUG
		return cdMeasurements;
	}
	/*
	 * Stores these values: {length of long edge, angle of incline of long edge,
	 * 						 length of short edge, angle of incline of short edge}.
	 */
	void fRememberMeasurements_Rectangle()
	{
		float	flEdge1ProjectionOntoX = _cflXsOfShapeVertices.get(1) - _cflXsOfShapeVertices.get(0),
				flEdge1ProjectionOntoY = _cflYsOfShapeVertices.get(1) - _cflYsOfShapeVertices.get(0);
		List<Double> cdMeasurement_side1 = fcdMeasurements_StraightSide(	flEdge1ProjectionOntoX,
																			flEdge1ProjectionOntoY );
		float	flEdge2ProjectionOntoX = _cflXsOfShapeVertices.get(2) - _cflXsOfShapeVertices.get(1),
				flEdge2ProjectionOntoY = _cflYsOfShapeVertices.get(2) - _cflYsOfShapeVertices.get(1);
		List<Double> cdMeasurement_side2 = fcdMeasurements_StraightSide(	flEdge2ProjectionOntoX,
																			flEdge2ProjectionOntoY );
		
		double	dSide1Length = cdMeasurement_side1.get(0),
				dSide2Length = cdMeasurement_side2.get(0),
				dMaxNormAngle = s_msdMaxNormAnglePerShapeType.get(Constants.s_sFunctor_Rectangle);
		if (dSide1Length > dSide2Length) {
			_dLongestAxisSU 					= dSide1Length;
			_dInitialLongestAxisInclineAngle	= fdNormalizeAngle(cdMeasurement_side1.get(1), dMaxNormAngle);
			_dSecondLongestAxisSU 				= dSide2Length;
		} else {
			_dLongestAxisSU 					= dSide2Length;
			_dInitialLongestAxisInclineAngle	= fdNormalizeAngle(cdMeasurement_side2.get(1), dMaxNormAngle);
			_dSecondLongestAxisSU 				= dSide1Length;
		}
		_dInitialSecondLongestAxisInclineAngle	= 0.0;
		_dShortestAxisSU						= 0.0;
		_dInitialShortestAxisInclineAngle		= 0.0;
	}
	/*
	 * Stores these values: {length of longest apex-to-opp-side projection,
	 * 					angle of incline of that projection,
	 * 					length of next longest projection,
	 * 					angle of incline of that projection,
	 * 					length of shortest projection,
	 * 					angle of incline of that projection}.
	 * 
	 * Note that some or all of the lengths may be the same.
	 */
	void fRememberMeasurements_Triangle()
	{
		float	x1 = _cflXsOfShapeVertices.get(0),
				y1 = _cflYsOfShapeVertices.get(0),
				x2 = _cflXsOfShapeVertices.get(1),
				y2 = _cflYsOfShapeVertices.get(1),
				x3 = _cflXsOfShapeVertices.get(2),
				y3 = _cflYsOfShapeVertices.get(2);
		Pair<Double,Double> oLengthAndAngle1 = foProjection(x1,y1,x2,y2,x3,y3);
		Pair<Double,Double> oLengthAndAngle2 = foProjection(x2,y2,x3,y3,x1,y1);
		Pair<Double,Double> oLengthAndAngle3 = foProjection(x3,y3,x1,y1,x2,y2);
		
		LinkedList<Double> cdMeasurements = new LinkedList<Double>();
		cdMeasurements.add(oLengthAndAngle1.getFirst());
		cdMeasurements.add(oLengthAndAngle1.getSecond());
		//Put pair2 either in front of or behind pair1
		if (oLengthAndAngle1.getFirst() < oLengthAndAngle2.getFirst()) {
			cdMeasurements.addFirst(oLengthAndAngle2.getSecond());
			cdMeasurements.addFirst(oLengthAndAngle2.getFirst());
		} else {
			cdMeasurements.add(oLengthAndAngle2.getFirst());
			cdMeasurements.add(oLengthAndAngle2.getSecond());
		}
		//Put pair3 either in front, in the middle, or at the end
		double dLengthInFrontPair = cdMeasurements.get(0);
		double dLengthInBackPair = cdMeasurements.get(2);
		if (oLengthAndAngle3.getFirst() > dLengthInFrontPair) {
			cdMeasurements.addFirst(oLengthAndAngle3.getSecond());
			cdMeasurements.addFirst(oLengthAndAngle3.getFirst());
		} else if (oLengthAndAngle3.getFirst() > dLengthInBackPair) {
			cdMeasurements.add(2, oLengthAndAngle3.getFirst());
			cdMeasurements.add(3, oLengthAndAngle3.getSecond());
		} else {
			cdMeasurements.add(oLengthAndAngle3.getFirst());
			cdMeasurements.add(oLengthAndAngle3.getSecond());
		}
		double dMaxNormAngle = s_msdMaxNormAnglePerShapeType.get(Constants.s_sFunctor_Triangle);
		_dLongestAxisSU							= cdMeasurements.get(0);
		_dInitialLongestAxisInclineAngle		= fdNormalizeAngle(cdMeasurements.get(1), dMaxNormAngle);
		
		_dSecondLongestAxisSU					= cdMeasurements.get(2);
		_dInitialSecondLongestAxisInclineAngle	= fdNormalizeAngle(cdMeasurements.get(3), dMaxNormAngle);
		
		_dShortestAxisSU						= cdMeasurements.get(4);
		_dInitialShortestAxisInclineAngle		= fdNormalizeAngle(cdMeasurements.get(5), dMaxNormAngle);
		
		//Calculate area using Heron's Formula, Area = sq rt{s(s - a)(s - b)(s - c)}
		// where s is half the perimeter, and a,b,c are the lengths of the sides
		Double 	dSide1Length = oLengthAndAngle1.getFirst(),
				dSide2Length = oLengthAndAngle2.getFirst(),
				dSide3Length = oLengthAndAngle3.getFirst();
		Double	dS = (dSide1Length + dSide2Length + dSide3Length)/2.0;
		_dTriangleArea = Math.sqrt(dS*(dS-dSide1Length)*(dS-dSide2Length)*(dS-dSide3Length));
	}
	/*
	 * Stores these values: {length of major axis,
	 * 					angle of incline of major axis,
	 * 					length of minor axis,
	 * 					angle of incline of minor axis}.
	 */
	void fRememberMeasurements_Oval()
	{
		float 	flDeltaXOfOppositePts,
				flDeltaYOfOppositePts;
		flDeltaXOfOppositePts = _cflXsOfShapeVertices.get(0) - _cflXsOfShapeVertices.get(4);
		flDeltaYOfOppositePts = _cflYsOfShapeVertices.get(0) - _cflYsOfShapeVertices.get(4);
		List<Double> cdMeasurement_axis1 = fcdMeasurements_StraightSide(	flDeltaXOfOppositePts,
																			flDeltaYOfOppositePts );
		
		flDeltaXOfOppositePts = _cflXsOfShapeVertices.get(1) - _cflXsOfShapeVertices.get(5);
		flDeltaYOfOppositePts = _cflYsOfShapeVertices.get(1) - _cflYsOfShapeVertices.get(5);
		List<Double> cdMeasurement_axis2 = fcdMeasurements_StraightSide(	flDeltaXOfOppositePts,
																			flDeltaYOfOppositePts );
		
		flDeltaXOfOppositePts = _cflXsOfShapeVertices.get(2) - _cflXsOfShapeVertices.get(6);
		flDeltaYOfOppositePts = _cflYsOfShapeVertices.get(2) - _cflYsOfShapeVertices.get(6);
		List<Double> cdMeasurement_axis3 = fcdMeasurements_StraightSide(	flDeltaXOfOppositePts,
																			flDeltaYOfOppositePts );
		
		flDeltaXOfOppositePts = _cflXsOfShapeVertices.get(3) - _cflXsOfShapeVertices.get(7);
		flDeltaYOfOppositePts = _cflYsOfShapeVertices.get(3) - _cflYsOfShapeVertices.get(7);
		List<Double> cdMeasurement_axis4 = fcdMeasurements_StraightSide(	flDeltaXOfOppositePts,
																			flDeltaYOfOppositePts );
		double	dAxis1Length = cdMeasurement_axis1.get(0),
				dAxis2Length = cdMeasurement_axis2.get(0),
				dAxis3Length = cdMeasurement_axis3.get(0),
				dAxis4Length = cdMeasurement_axis4.get(0);
		
		//Find the length of the longest of the 4 axes
		double	dLongestAxis_1 = Math.max(dAxis1Length, dAxis2Length),
				dLongestAxis_2 = Math.max(dAxis3Length, dAxis4Length);
		double	dLongestAxis = Math.max(dLongestAxis_1, dLongestAxis_2);
		double dMaxNormAngle = s_msdMaxNormAnglePerShapeType.get(Constants.s_sFunctor_Oval);
		if (dAxis1Length == dLongestAxis) {
			_dLongestAxisSU 					= dAxis1Length;
			_dInitialLongestAxisInclineAngle	= fdNormalizeAngle(cdMeasurement_axis1.get(1), dMaxNormAngle);
			_dSecondLongestAxisSU 				= dAxis3Length;
		} else if (dAxis2Length == dLongestAxis) {
			_dLongestAxisSU 					= dAxis2Length;
			_dInitialLongestAxisInclineAngle	= fdNormalizeAngle(cdMeasurement_axis2.get(1), dMaxNormAngle);
			_dSecondLongestAxisSU 				= dAxis4Length;
		} else if (dAxis3Length == dLongestAxis) {
			_dLongestAxisSU 					= dAxis3Length;
			_dInitialLongestAxisInclineAngle	= fdNormalizeAngle(cdMeasurement_axis3.get(1), dMaxNormAngle);
			_dSecondLongestAxisSU 				= dAxis1Length;
		} else { //iAxis4Length == iLongestAxis
			_dLongestAxisSU 					= dAxis4Length;
			_dInitialLongestAxisInclineAngle	= fdNormalizeAngle(cdMeasurement_axis4.get(1), dMaxNormAngle);
			_dSecondLongestAxisSU 				= dAxis2Length;
		}
		_dInitialSecondLongestAxisInclineAngle	= 0.0;
		_dShortestAxisSU						= 0.0;
		_dInitialShortestAxisInclineAngle		= 0.0;
	}
	/*
	 * Adapted from
	 * http://www.exaflop.org/docs/cgafaq/cga1.html#Subject%201.02:%20How%20do%20I%20find%20the%20distance%20from%20a%20point%20to%20a%20line?
	 */
	Pair<Double,Double> foProjection(	float x1, float y1,
										float x2, float y2,
										float x3, float y3 )
	{
		double dSquaredLengthFrom2to3 = Math.pow((x2 - x1),2) + Math.pow((y2 - y1),2);
		double dProjRange1 = ((y1 - y3)*(y1 - y2) - (x1 - x3)*(x2 - x1)) / dSquaredLengthFrom2to3;	
		double	xP = x1 + dProjRange1 * (x2 - x1),
				yP = y1 + dProjRange1 * (y2 - y1);
		
		double dRadiansSlopePt3toProjPt = Math.atan((yP - y3)/(xP - x3));
		double dAngleSlopePt3toProjPt = Math.toDegrees( dRadiansSlopePt3toProjPt );

		double dProjRange2 = ((y1 - y3)*(x2 - x1) - (x1 - x3)*(y2 - y1)) / dSquaredLengthFrom2to3;
		double dLengthOfProjectionFromPt3 = dProjRange2 * Math.sqrt(dSquaredLengthFrom2to3);
		
		return new Pair<Double,Double>(dLengthOfProjectionFromPt3, dAngleSlopePt3toProjPt);
	}
}
