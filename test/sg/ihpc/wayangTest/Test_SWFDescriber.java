/*
 * Here are examples of the kinds of shapes we now recognize:

- circle(13)                         - The parameter indicates the diameter in SU
- oval(22, 5, 13)                    - Parameter1 is the longest axis in SU; parameter2 is the incline angle of the major axis; parameter 3 is the shorter axis in SU
- square(13, 80)                     - Parameter1 is the length of a side in SU; parameter2 is the incline angle
- rectangle(44, 143, 25)             - Parameter1 is the length of the longer side; parameter2 is the incline angle of the longer side; param3 is the shorter side in SU
- triangle(22, 45, 12, 298, 12, 332) - Odd-numbered params are the lengths of interior bisectors in SU; even-numbered params are incline angles of those bisectors
- polygonSides(5)                    - Parameter1 is the number of sides the polygon has (always 5 or greater); there is no attempt to represent orientation
- unrecognizedShape                  - Some shape we can't recognize, such as a combination of straight and curved sides; there is no attempt to represent orientation

Note that providing the incline angle of the major axis (always in 2nd parameter) provides a quick indication of the orientation of the figure.

Finally, here is an example of the description of a frame showing how shape descriptions fit in:

frame([timestamp(41), ground(167, 122, color(255, 255, 255)), figure(1, position(60, 72), rectangle(44, 150, 25), color(0, 102, 204)), ...more figures])

- Timestamp is msec since the animation began (calculated using frames-per-sec defined in the SWF; the value is not machine-specific)
- Ground indicates the width and height of the animation space in SU, plus the background color (in RGB values)
- Figure indicates the figure ID, (x,y) position in SU of the figure's center, and the shape and color of one figure
- A frame description includes a description of each figure that appears within that frame
 */
package sg.ihpc.wayangTest;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.List;

import org.testng.annotations.Test;

import sg.ihpc.wayang.CLPUtils;
import sg.ihpc.wayang.swf.SWFDescriber;

import com.parctechnologies.eclipse.CompoundTerm;

public class Test_SWFDescriber {
	
	private final static String s_sCircle15mmTranslation_terms = "[frame([timestamp(0), ground(167, 122, color(255, 255, 255)), figure(1, position(61, 35), circle(13), color(255, 0, 0))]), frame([timestamp(41), ground(167, 122, color(255, 255, 255)), figure(1, position(67, 39), circle(13), color(255, 0, 0))]), frame([timestamp(82), ground(167, 122, color(255, 255, 255)), figure(1, position(74, 44), circle(13), color(255, 0, 0))]), frame([timestamp(123), ground(167, 122, color(255, 255, 255)), figure(1, position(80, 48), circle(13), color(255, 0, 0))]), frame([timestamp(164), ground(167, 122, color(255, 255, 255)), figure(1, position(87, 52), circle(13), color(255, 0, 0))])]";
	private final static String s_sOval25x15mm_rot45to45withTranslation_terms = "[frame([timestamp(0), ground(167, 122, color(255, 255, 255)), figure(1, position(61, 35), oval(22, 45, 13), color(255, 0, 0))]), frame([timestamp(41), ground(167, 122, color(255, 255, 255)), figure(1, position(66, 39), oval(22, 5, 13), color(255, 0, 0))]), frame([timestamp(82), ground(167, 122, color(255, 255, 255)), figure(1, position(72, 43), oval(22, 145, 13), color(255, 0, 0))]), frame([timestamp(123), ground(167, 122, color(255, 255, 255)), figure(1, position(78, 47), oval(22, 105, 13), color(255, 0, 0))]), frame([timestamp(164), ground(167, 122, color(255, 255, 255)), figure(1, position(84, 50), oval(22, 65, 13), color(255, 0, 0))]), frame([timestamp(205), ground(167, 122, color(255, 255, 255)), figure(1, position(89, 54), oval(22, 25, 13), color(255, 0, 0))]), frame([timestamp(246), ground(167, 122, color(255, 255, 255)), figure(1, position(95, 58), oval(22, 165, 13), color(255, 0, 0))]), frame([timestamp(287), ground(167, 122, color(255, 255, 255)), figure(1, position(101, 62), oval(22, 125, 13), color(255, 0, 0))]), frame([timestamp(328), ground(167, 122, color(255, 255, 255)), figure(1, position(107, 66), oval(22, 85, 13), color(255, 0, 0))]), frame([timestamp(369), ground(167, 122, color(255, 255, 255)), figure(1, position(113, 70), oval(22, 45, 13), color(255, 0, 0))])]";
	private final static String s_sSquare15mm_rot90to90counterClockwiseWithTranslation_terms = "[frame([timestamp(0), ground(167, 122, color(255, 255, 255)), figure(1, position(61, 35), square(13, 90), color(255, 0, 0))]), frame([timestamp(41), ground(167, 122, color(255, 255, 255)), figure(1, position(66, 39), square(13, 40), color(255, 0, 0))]), frame([timestamp(82), ground(167, 122, color(255, 255, 255)), figure(1, position(72, 43), square(13, 80), color(255, 0, 0))]), frame([timestamp(123), ground(167, 122, color(255, 255, 255)), figure(1, position(78, 46), square(13, 30), color(255, 0, 0))]), frame([timestamp(164), ground(167, 122, color(255, 255, 255)), figure(1, position(84, 50), square(13, 70), color(255, 0, 0))]), frame([timestamp(205), ground(167, 122, color(255, 255, 255)), figure(1, position(89, 54), square(13, 20), color(255, 0, 0))]), frame([timestamp(246), ground(167, 122, color(255, 255, 255)), figure(1, position(95, 58), square(13, 60), color(255, 0, 0))]), frame([timestamp(287), ground(167, 122, color(255, 255, 255)), figure(1, position(101, 62), square(13, 10), color(255, 0, 0))]), frame([timestamp(328), ground(167, 122, color(255, 255, 255)), figure(1, position(107, 66), square(13, 50), color(255, 0, 0))]), frame([timestamp(369), ground(167, 122, color(255, 255, 255)), figure(1, position(113, 70), square(13, 90), color(255, 0, 0))])]";
	private final static String s_sRectangle44x25mm_rot150to83_terms = "[frame([timestamp(0), ground(167, 122, color(255, 255, 255)), figure(1, position(60, 72), rectangle(44, 150, 25), color(0, 102, 204))]), frame([timestamp(41), ground(167, 122, color(255, 255, 255)), figure(1, position(60, 72), rectangle(44, 143, 25), color(0, 102, 204))]), frame([timestamp(82), ground(167, 122, color(255, 255, 255)), figure(1, position(60, 72), rectangle(44, 135, 25), color(0, 102, 204))]), frame([timestamp(123), ground(167, 122, color(255, 255, 255)), figure(1, position(60, 72), rectangle(44, 128, 25), color(0, 102, 204))]), frame([timestamp(164), ground(167, 122, color(255, 255, 255)), figure(1, position(60, 72), rectangle(44, 120, 25), color(0, 102, 204))]), frame([timestamp(205), ground(167, 122, color(255, 255, 255)), figure(1, position(60, 72), rectangle(44, 113, 25), color(0, 102, 204))]), frame([timestamp(246), ground(167, 122, color(255, 255, 255)), figure(1, position(60, 72), rectangle(44, 105, 25), color(0, 102, 204))]), frame([timestamp(287), ground(167, 122, color(255, 255, 255)), figure(1, position(60, 72), rectangle(44, 98, 25), color(0, 102, 204))]), frame([timestamp(328), ground(167, 122, color(255, 255, 255)), figure(1, position(60, 72), rectangle(44, 90, 25), color(0, 102, 204))]), frame([timestamp(369), ground(167, 122, color(255, 255, 255)), figure(1, position(60, 72), rectangle(44, 83, 25), color(0, 102, 204))])]";
	private final static String s_sIsoscelesTriangle25x15mm_rot45to45WithTranslation_terms = "[frame([timestamp(0), ground(167, 122, color(255, 255, 255)), figure(1, position(61, 35), triangle(22, 45, 12, 298, 12, 332, 66), color(255, 0, 0))]), frame([timestamp(41), ground(167, 122, color(255, 255, 255)), figure(1, position(66, 39), triangle(22, 5, 12, 258, 12, 292, 66), color(255, 0, 0))]), frame([timestamp(82), ground(167, 122, color(255, 255, 255)), figure(1, position(72, 43), triangle(22, 325, 12, 218, 12, 252, 66), color(255, 0, 0))]), frame([timestamp(123), ground(167, 122, color(255, 255, 255)), figure(1, position(78, 46), triangle(22, 285, 12, 178, 12, 212, 66), color(255, 0, 0))]), frame([timestamp(164), ground(167, 122, color(255, 255, 255)), figure(1, position(84, 50), triangle(22, 245, 12, 138, 12, 172, 66), color(255, 0, 0))]), frame([timestamp(205), ground(167, 122, color(255, 255, 255)), figure(1, position(89, 54), triangle(22, 205, 12, 98, 12, 132, 66), color(255, 0, 0))]), frame([timestamp(246), ground(167, 122, color(255, 255, 255)), figure(1, position(95, 58), triangle(22, 165, 12, 58, 12, 92, 66), color(255, 0, 0))]), frame([timestamp(287), ground(167, 122, color(255, 255, 255)), figure(1, position(101, 62), triangle(22, 125, 12, 18, 12, 52, 66), color(255, 0, 0))]), frame([timestamp(328), ground(167, 122, color(255, 255, 255)), figure(1, position(107, 66), triangle(22, 85, 12, 338, 12, 12, 66), color(255, 0, 0))]), frame([timestamp(369), ground(167, 122, color(255, 255, 255)), figure(1, position(113, 70), triangle(22, 45, 12, 298, 12, 332, 66), color(255, 0, 0))])]";
	private final static String s_sIrregularPentagon_translation_terms = "[frame([timestamp(0), ground(167, 122, color(255, 255, 255)), figure(1, position(61, 35), polygonSides(5), color(255, 0, 0))]), frame([timestamp(41), ground(167, 122, color(255, 255, 255)), figure(1, position(67, 39), polygonSides(5), color(255, 0, 0))]), frame([timestamp(82), ground(167, 122, color(255, 255, 255)), figure(1, position(74, 44), polygonSides(5), color(255, 0, 0))]), frame([timestamp(123), ground(167, 122, color(255, 255, 255)), figure(1, position(80, 48), polygonSides(5), color(255, 0, 0))]), frame([timestamp(164), ground(167, 122, color(255, 255, 255)), figure(1, position(87, 52), polygonSides(5), color(255, 0, 0))])]";
	private final static String s_sUnrecognizableShape_terms = "[frame([timestamp(0), ground(167, 122, color(255, 255, 255)), figure(1, position(61, 35), unrecognizedShape, color(255, 0, 0))]), frame([timestamp(41), ground(167, 122, color(255, 255, 255)), figure(1, position(61, 35), unrecognizedShape, color(255, 0, 0))]), frame([timestamp(82), ground(167, 122, color(255, 255, 255)), figure(1, position(61, 35), unrecognizedShape, color(255, 0, 0))]), frame([timestamp(123), ground(167, 122, color(255, 255, 255)), figure(1, position(61, 35), unrecognizedShape, color(255, 0, 0))]), frame([timestamp(164), ground(167, 122, color(255, 255, 255)), figure(1, position(61, 35), unrecognizedShape, color(255, 0, 0))])]";
	
	private static TestEnvironment s_oEnv;
	private static SWFDescriber s_oSWFDescriber;
	static {
		try {
			s_oEnv = TestEnvironment.getInstance();
		    
		    s_oSWFDescriber = new SWFDescriber(	s_oEnv.getShapesFudgeFactor(),
		    									s_oEnv.getTwipsPerSpatialUnit() );
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	@Test
	public void SWFDescriber_createdOkay() {
		assert s_oEnv != null && s_oSWFDescriber != null;
	}

	List<CompoundTerm> fcoGenerateFrameTerms(String sLocalPathToSwf) throws IOException {
		FileInputStream inputStream = new FileInputStream( sLocalPathToSwf );
        System.out.println("...LocalPathToSWF = "+sLocalPathToSwf);
    	
        return s_oSWFDescriber.fcoGenerateFrameTerms(inputStream);
	}
	void assertEqualStrings(String sCandidate,
							String sTemplate )
	{
		if ((sTemplate == null && sCandidate == null) ||
			(sTemplate != null && sTemplate.equals(sCandidate)) ) {
			//do nothing
			return;
		} else if (sCandidate == null) {
			System.out.println("FAIL: assertEqualStrings -- 1st arg is null");
		} else if (sTemplate == null) {
			System.out.println("FAIL: assertEqualStrings -- 2nd arg is null");
		} else {
			//March through both strings and stop at the first difference
			int iMaxPosition = Math.min(sCandidate.length(), sTemplate.length());
			int i=0;
			for ( ; i < iMaxPosition; i++) {
				if (sCandidate.charAt(i) != sTemplate.charAt(i)) break;
			}
			System.out.println("FAIL: assertEqualStrings found difference at "+i+"th position...");
			System.out.println(sTemplate);
			System.out.println(sCandidate);
			
			StringBuilder sb = new StringBuilder(i+1);
			for (int j=0; j < i; j++) {
				sb.append(" ");
			}
			String sIndent = sb.toString();
			
			System.out.println(sIndent+"^");
			System.out.println(sIndent+"|");
		}
		assert false;
	}

	// Circle
	//
	@Test(dependsOnMethods = {"SWFDescriber_createdOkay"})
	public void circle15mm_translation_termsAreCorrect() throws IOException {
		List<CompoundTerm> coTerms = fcoGenerateFrameTerms("input/circle15mm_translation.swf");
		
		//System.out.println("NUM TERMS: "+coTerms.size()); //DEBUG
		assert (coTerms.size() == 5);
		
		String sGeneratedTerms = CLPUtils.toString((List)coTerms);
		//System.out.println("TERMS: "+sGeneratedTerms); //DEBUG
		assertEqualStrings(sGeneratedTerms, s_sCircle15mmTranslation_terms);
	}
	// Oval
	//
	@Test(dependsOnMethods = {"SWFDescriber_createdOkay"})
	public void oval25x15mm_rot45to45withTranslation_termsAreCorrect() throws IOException {
		List<CompoundTerm> coTerms = fcoGenerateFrameTerms("input/oval25x15mm_rot45to45withTranslation.swf");
		
		//System.out.println("NUM TERMS: "+coTerms.size()); //DEBUG
		assert (coTerms.size() == 10);
		
		String sGeneratedTerms = CLPUtils.toString((List)coTerms);
		//System.out.println("TERMS: "+sGeneratedTerms); //DEBUG
		assertEqualStrings(sGeneratedTerms, s_sOval25x15mm_rot45to45withTranslation_terms);
	}
	// Square
	//
	@Test(dependsOnMethods = {"SWFDescriber_createdOkay"})
	public void square15mm_rot90to90counterClockwiseWithTranslation_termsAreCorrect() throws IOException {
		List<CompoundTerm> coTerms = fcoGenerateFrameTerms("input/square15mm_rot90to90counterClockwiseWithTranslation.swf");
		
		//System.out.println("NUM TERMS: "+coTerms.size()); //DEBUG
		assert (coTerms.size() == 10);
		
		String sGeneratedTerms = CLPUtils.toString((List)coTerms);
		System.out.println("TERMS: "+sGeneratedTerms); //DEBUG
		assertEqualStrings(sGeneratedTerms, s_sSquare15mm_rot90to90counterClockwiseWithTranslation_terms);
	}
	// Rectangle
	//
	@Test(dependsOnMethods = {"SWFDescriber_createdOkay"})
	public void rectangle44x25mm_rot150to83_termsAreCorrect() throws IOException {
		List<CompoundTerm> coTerms = fcoGenerateFrameTerms("input/rectangle44x25mm_rot150to83.swf");
		
		//System.out.println("NUM TERMS: "+coTerms.size()); //DEBUG
		assert (coTerms.size() == 10);
		
		String sGeneratedTerms = CLPUtils.toString((List)coTerms);
		System.out.println("TERMS: "+sGeneratedTerms); //DEBUG
		assertEqualStrings(sGeneratedTerms, s_sRectangle44x25mm_rot150to83_terms);
	}
	// Triangle
	//
	@Test(dependsOnMethods = {"SWFDescriber_createdOkay"})
	public void isoscelesTriangle25x15mm_rot45to45WithTranslation_termsAreCorrect() throws IOException {
		List<CompoundTerm> coTerms = fcoGenerateFrameTerms("input/isoscelesTriangle25x15mm_rot45to45WithTranslation.swf");
		
		//System.out.println("NUM TERMS: "+coTerms.size()); //DEBUG
		assert (coTerms.size() == 10);
		
		String sGeneratedTerms = CLPUtils.toString((List)coTerms);
		System.out.println("TERMS: "+sGeneratedTerms); //DEBUG
		assertEqualStrings(sGeneratedTerms, s_sIsoscelesTriangle25x15mm_rot45to45WithTranslation_terms);
	}
	// Other Polygon
	//
	@Test(dependsOnMethods = {"SWFDescriber_createdOkay"})
	public void irregularPentagon_translation_termsAreCorrect() throws IOException {
		List<CompoundTerm> coTerms = fcoGenerateFrameTerms("input/irregularPentagon_translation.swf");
		
		//System.out.println("NUM TERMS: "+coTerms.size()); //DEBUG
		assert (coTerms.size() == 5);
		
		String sGeneratedTerms = CLPUtils.toString((List)coTerms);
		System.out.println("TERMS: "+sGeneratedTerms); //DEBUG
		assertEqualStrings(sGeneratedTerms, s_sIrregularPentagon_translation_terms);
	}
	// Unrecognized Shape
	//
	@Test(dependsOnMethods = {"SWFDescriber_createdOkay"})
	public void unrecognizableShape_termsAreCorrect() throws IOException {
		List<CompoundTerm> coTerms = fcoGenerateFrameTerms("input/unrecognizableShape.swf");
		
		System.out.println("NUM TERMS: "+coTerms.size()); //DEBUG
		assert (coTerms.size() == 5);
		
		String sGeneratedTerms = CLPUtils.toString((List)coTerms);
		System.out.println("TERMS: "+sGeneratedTerms); //DEBUG
		assertEqualStrings(sGeneratedTerms, s_sUnrecognizableShape_terms);
	}

}
