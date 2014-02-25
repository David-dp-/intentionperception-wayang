package sg.ihpc.wayang.swf;

import java.io.FileInputStream;
import java.io.IOException;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

import sg.ihpc.wayang.Constants;

import com.jswiff.SWFDocument;
import com.jswiff.SWFReader;
import com.jswiff.listeners.SWFDocumentReader;
import com.jswiff.swfrecords.Rect;
import com.jswiff.swfrecords.tags.DefineShape;
import com.jswiff.swfrecords.tags.DefineShape2;
import com.jswiff.swfrecords.tags.DefineShape3;
import com.jswiff.swfrecords.tags.DefineShape4;
import com.jswiff.swfrecords.tags.PlaceObject2;
import com.jswiff.swfrecords.tags.RemoveObject2;
import com.jswiff.swfrecords.tags.Tag;
import com.jswiff.swfrecords.tags.TagConstants;
import com.parctechnologies.eclipse.CompoundTerm;
import com.parctechnologies.eclipse.CompoundTermImpl;

/**
 * Shows how to parse a Flash movie and extract the frame rate and info
 * about each frame.
 */
public class SWFDescriber {
	
	private Integer _iShapesFudgeFactor;
	private Float _flTwipsPerSpatialUnit;
	
	public SWFDescriber(Integer iShapesFudgeFactor,
						Float flTwipsPerSpatialUnit )
	{
		_iShapesFudgeFactor = iShapesFudgeFactor;
		_flTwipsPerSpatialUnit = flTwipsPerSpatialUnit;
	}
	
	public List<CompoundTerm> fcoGenerateFrameTerms(FileInputStream swfInputStream)
	throws IOException {
		List<CompoundTerm> coFrameTerms = new ArrayList<CompoundTerm>();
        
		//Parse the local SWF into a SWFMovieFile
        SWFReader            reader = new SWFReader(swfInputStream);
        SWFDocumentReader docReader = new SWFDocumentReader();
        SWFDocument             doc = null;

        reader.addListener(docReader);
        reader.read();
        System.out.println("...Confirmed that file is SWF formatted.");
        	
        doc = docReader.getDocument();
        if (doc == null) return null;
        
        int iFramesPerSec = doc.getFrameRate();
        Rect oFrameSize = doc.getFrameSize();
        int iFrameCount = doc.getFrameCount();
        long iBackgroundWidthInTwips = oFrameSize.getXMax();
        long iBackgroundHeightInTwips = oFrameSize.getYMax();
        int iSwfVersion = doc.getVersion();
        
        float flMsecBetweenFrames = 1000/iFramesPerSec;
        int iBackgroundWidthInSU = Math.round(iBackgroundWidthInTwips / _flTwipsPerSpatialUnit);
        int iBackgroundHeightInSU = Math.round(iBackgroundHeightInTwips / _flTwipsPerSpatialUnit);
        
        System.out.println("...Properties in SWF header:         SWF version = "+iSwfVersion);
        System.out.println("                                     frame count = "+iFrameCount);
        System.out.println("                                      frame rate = "+iFramesPerSec+"; so, msec between frames = "+flMsecBetweenFrames);
        System.out.println("                                background width = "+iBackgroundWidthInTwips+"twips ~ "+iBackgroundWidthInSU+" spatial units");
        System.out.println("                                          height = "+iBackgroundHeightInTwips+"twips ~ "+iBackgroundHeightInSU+" spatial units");
        System.out.println("                                           color = "+doc.getBackgroundColor());
        
        RGBCombo oBackgroundRGBCombo = new RGBCombo(doc.getBackgroundColor());
        Object[] aoTermArgs = new Object[3];
        aoTermArgs[0] = (oFrameSize == null ? null : new Integer(iBackgroundWidthInSU)); //ground.widthInSU
        aoTermArgs[1] = (oFrameSize == null ? null : new Integer(iBackgroundHeightInSU)); //ground.heightInSU
        aoTermArgs[2] = (oBackgroundRGBCombo.fbErrorPresent() ? null : oBackgroundRGBCombo.foToCompoundTerm()); //ground.color
        CompoundTerm oBackground = new CompoundTermImpl("ground", aoTermArgs);
        
        /*
         * The format of all but the last term sent to the inference engine will always be
         * 
         *   inferred(frame{timeElapsedInMsec:float, figures:[figure{id, xPosInSU, yPosInSU, widthInSU, heightInSU, color:color},...], ground:background{widthInSU, heightInSU, color:color} }, Explanations, Expectations)
         *  
         *  We use the inferred/3 wrapper because it allows us to pass back explanations
         *  and expectations. (Note: Putting a possibly-partially-instantiated version of
         *  the same term on the eclipseToJava queue isn't required; see the queue_example_2.pl
         *  example in the Embedding Guide section about QueueListener's.)
         */   
	    List<Tag> coTags = fcoSwfTags(doc);
	    int iDepth, iNumFramesSoFar = 0;
	    long iFlippedYPos;
	    Integer iCharId;
	    Figure figure = null;
	    DefineShape oDefineShape;
	    DefineShape2 oDefineShape2;
	    DefineShape3 oDefineShape3;
	    DefineShape4 oDefineShape4;
	    PlaceObject2 oPlaceObject2;   int iCount_PlaceObject2 = 0;
	    RemoveObject2 oRemoveObject2; int iCount_RemoveObject2 = 0;
	    //Note: Flash never recycles a charId within an SWF (which is good)
	    Map<Integer,Figure> mioCharIdToFigure = new HashMap<Integer,Figure>();
	    Pair<Integer,Figure> oCharIdFigurePair;
	    Map<Integer,Pair<Integer,Figure> > mioDepthToCharIdAndFigure = new HashMap<Integer,Pair<Integer,Figure> >();
	    List<CompoundTerm> coFrameContents;
	    CompoundTerm oFigure, oTimestamp;
	    Object[] aoPosTermArgs;
	    for (Tag tag : coTags) {
	    	switch (tag.getCode()) {
    			case TagConstants.DEFINE_SPRITE:
    				System.out.println("Ignored DefineSprite tag");
    				break;
    			case TagConstants.REMOVE_OBJECT_2:
    				oRemoveObject2 = (RemoveObject2) tag;
    				iCount_RemoveObject2++;
    				iDepth = oRemoveObject2.getDepth();
    				oCharIdFigurePair = mioDepthToCharIdAndFigure.remove(iDepth);
    				if (oCharIdFigurePair == null) {
    					System.out.println("SUSPICIOUS: "+iCount_RemoveObject2+"th RemoveObject2 tag indicated depth "+iDepth+" but DepthMap had no entry for that value.");
    				}
    				break;
	    		case TagConstants.DEFINE_SHAPE:
	    			oDefineShape = (DefineShape) tag;
	    			iCharId = oDefineShape.getCharacterId();
		        	figure = new Figure(iCharId,
	        							oDefineShape.getShapes(),
	        							_flTwipsPerSpatialUnit,
	        							_iShapesFudgeFactor );
		        	mioCharIdToFigure.put(iCharId, figure);
		        	break;
		    	case TagConstants.DEFINE_SHAPE_2:
		        	oDefineShape2 = (DefineShape2) tag;
	    			iCharId = oDefineShape2.getCharacterId();
		        	figure = new Figure(iCharId,
	        							oDefineShape2.getShapes(),
	        							_flTwipsPerSpatialUnit,
	        							_iShapesFudgeFactor );
		        	mioCharIdToFigure.put(iCharId, figure);
		        	break;
		    	case TagConstants.DEFINE_SHAPE_3:
		        	oDefineShape3 = (DefineShape3) tag;
	    			iCharId = oDefineShape3.getCharacterId();
		        	figure = new Figure(iCharId,
	        							oDefineShape3.getShapes(),
	        							_flTwipsPerSpatialUnit,
	        							_iShapesFudgeFactor );
		        	mioCharIdToFigure.put(iCharId, figure);
		        	break;
		        case TagConstants.DEFINE_SHAPE_4:
		        	oDefineShape4 = (DefineShape4) tag;
	    			iCharId = oDefineShape4.getCharacterId();
		        	figure = new Figure(iCharId,
	        							oDefineShape4.getShapes(),
	        							_flTwipsPerSpatialUnit,
	        							_iShapesFudgeFactor );
		        	mioCharIdToFigure.put(iCharId, figure);
		        	break;
		        case TagConstants.PLACE_OBJECT_2:
		        	oPlaceObject2 = (PlaceObject2) tag;
		        	iCount_PlaceObject2++;
    				iDepth = oPlaceObject2.getDepth();
		        	oCharIdFigurePair = mioDepthToCharIdAndFigure.get(iDepth);
		        	if (oCharIdFigurePair != null) {
		        		figure = oCharIdFigurePair.getSecond();
		        		if (figure != null) {
		        			figure.fUpdate(oPlaceObject2);
		        		} else {
		        			System.out.println("SUSPICIOUS: "+iCount_PlaceObject2+"th PlaceObject2 tag with depth "+iDepth+" had an entry in DepthMap but the entry's figure slot was null.");
		        		}
		        	} else if (oPlaceObject2.hasCharacter()) {
		        		iCharId = oPlaceObject2.getCharacterId();
		        		figure = mioCharIdToFigure.get(iCharId);
		        		if (figure != null) {
			        		figure.fUpdate(oPlaceObject2);
			        		oCharIdFigurePair = new Pair<Integer,Figure>(iCharId, figure);
		        			mioDepthToCharIdAndFigure.put(iDepth, oCharIdFigurePair);
		        		} else {
		        			System.out.println("SUSPICIOUS: "+iCount_PlaceObject2+"th PlaceObject2 tag with depth "+iDepth+" had no DepthMap entry, and the tag's charId "+iCharId+" had no matching entry in CharIdMap.");
		        		}
		        	} else {
    					System.out.println("SUSPICIOUS: "+iCount_PlaceObject2+"th PlaceObject2 tag indicated depth "+iDepth+", but there is no entry in DepthMap, and it doesnt indicate a charId value.");
		        	}
		        	break;
		        case TagConstants.SHOW_FRAME:
		        	coFrameContents = new ArrayList<CompoundTerm>();
		        	
		        	oTimestamp =
		        		new CompoundTermImpl("timestamp",
		        							 new Integer(Math.round(iNumFramesSoFar * flMsecBetweenFrames)) );
		        	coFrameContents.add(oTimestamp);
		        	
		        	coFrameContents.add(oBackground);
		        	
		        	for (Integer iDepth2 : mioDepthToCharIdAndFigure.keySet()) {
		        		oCharIdFigurePair = mioDepthToCharIdAndFigure.get(iDepth2);
		        		if (oCharIdFigurePair != null) {
		        			figure = oCharIdFigurePair.getSecond();
			        		if (figure != null) { //should always succeed
			        			aoPosTermArgs = new Object[2];
			        			aoPosTermArgs[0] = new Integer(Math.round(figure.getXPos() / _flTwipsPerSpatialUnit)); //xPosInSU
			        			//SWFs use upper left as origin instead of lower left, so we have to subtract Y value from frame height
			        			iFlippedYPos = iBackgroundHeightInTwips - figure.getYPos();
			        			aoPosTermArgs[1] = new Integer(Math.round(iFlippedYPos / _flTwipsPerSpatialUnit)); //yPosInSU
			        			
			        			aoTermArgs = new Object[4];
			        			aoTermArgs[0] = new Integer(iDepth2); //id
			        			aoTermArgs[1] = new CompoundTermImpl(Constants.s_sFunctor_Position, aoPosTermArgs);
			        			aoTermArgs[2] = figure.foShapeToCompoundTerm();                                               //shape
			        			aoTermArgs[3] = (figure.fbRGBComboErrorPresent() ? null : figure.foRGBComboToCompoundTerm()); //color
			        			oFigure = new CompoundTermImpl("figure", aoTermArgs);
			        			coFrameContents.add(oFigure);
				        	} else {
				        		System.out.println("SUSPICIOUS: After "+(iNumFramesSoFar+1)+"th ShowFrame tag, looked up pair indexed at depth "+iDepth2+" but indexed figure was null.");
				        	}
		        		} else {
		        			System.out.println("SUSPICIOUS: After "+(iNumFramesSoFar+1)+"th ShowFrame tag, looked for pair indexed at depth "+iDepth2+" but found none.");
				        }
		        	}
		        	iNumFramesSoFar++;
		        	
		        	aoTermArgs = new Object[1];
		        	aoTermArgs[0] = coFrameContents;
		        	coFrameTerms.add(new CompoundTermImpl("frame", aoTermArgs));
		        	
		        	/* The term now looks like this:
		        	 *   frame([timestamp(0), ground(...), figure(1,..), figure(2,..), ...])
		        	 */
		        	
		        	break;
		        default:
		        	System.out.println("...Ignored tag with code>"+tag.getCode()+"<");
	      }
	    }
	    
	    return coFrameTerms;
    }
    
	public Integer extractSWFFrameRate(FileInputStream swfInputStream)
	throws IOException {
		//Parse the local SWF into a SWFMovieFile
        SWFReader            reader = new SWFReader(swfInputStream);
        SWFDocumentReader docReader = new SWFDocumentReader();
        SWFDocument             doc = null;

        reader.addListener(docReader);
        reader.read();
        
        doc = docReader.getDocument();
        if (doc == null) return null;
        
        return new Integer(doc.getFrameRate());
	}
	
    /*
     * I'm not sure how to coerce the List returned by getTags() to be a List<Tag>, so I created this
     * method so I could annotate with @SuppressWarnings("unchecked").
     */
    @SuppressWarnings("unchecked")
	public static List<Tag> fcoSwfTags(SWFDocument doc) {
    	return doc.getTags();
    }
}