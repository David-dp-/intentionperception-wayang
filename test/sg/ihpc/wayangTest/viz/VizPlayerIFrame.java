package sg.ihpc.wayangTest.viz;

import java.awt.Dimension;

import javax.swing.BorderFactory;
import javax.swing.JEditorPane;
import javax.swing.JInternalFrame;

@SuppressWarnings("serial")
class VizPlayerIFrame extends JInternalFrame {
	
	/*The job of this class is to provide a content pane that can render a
	 * Flash SWF file that we can advance stepwise programmatically, and
	 * a glass pane on which we can programmatically draw overlays.
	 * 
	 *We haven't been able to find any cross-platform SWF container for Java.
	 * (JFlashPlayer is Windows-specific and requires purchase.)
	 *For the content pane, ideally we would use JWebPane, a feature that Sun
	 * has been touting since 2008 for rendering of web content -- although it's
	 * not clear if that would also include SWF content. But as of Dec 23 2010,
	 * JWebPane still isn't part of Java SE 1.6.
	 *The search for an alternative is made somewhat easier by the existence of
	 * Gordon, https://github.com/tobeytailor/gordon/wiki/, a pure-Javascript
	 * SWF player that allows control over playback. Although it doesn't yet
	 * support all SWF versions, it does support the tags that Wayang SWFs use.
	 * Unfortunately, it doesn't actually work for at least one Wayang SWF, as
	 * demo'd here: http://wooden-robot.net/fun/gordon-demo.htm. David wrote
	 * to the developer at schneider@uxebu.com asking for help.
	 *Some alternate Java-based web renderers are described here:
	 * http://www.informit.com/guides/content.aspx?g=java&seqNum=521
	 * David tried JEditorPane by downloading an modifying the tutorial at
	 * http://download.oracle.com/
	 *  javase/tutorial/uiswing/components/editorpane.html
	 * but it didn't work for Gordon demo at 
	 *  http://gordonjs.s3.amazonaws.com/trip.html. David then tried the Lobo
	 * browser, but it also failed; its console indicated
	 * "org.mozilla.javascript.EcmaError: TypeError: Cannot find function
	 *  addEventListener. (http://gordonjs.s3.amazonaws.com/gordon.js#70"
	 * David posted this error to the Lobo help forum here:
	 * https://sourceforge.net/projects/xamj/forums/forum/467020/topic/4024179
	 * and also notified the Gordon developer because the same problem occurs
	 * in the DJ Native Swing browser, http://djproject.sourceforge.net/ns/
	 * Remaining options to be tried are:
	 * - HotJava browser
	 * - ICESoft's ICE browser
	 * - Mozilla Web Client http://www.mozilla.org/projects/blackwood/webclient/ref_guides/Developer_guide/index.htm
	 * - Wait for fixes to Gordon or Lobo, or the arrival of JWebPane
	 * 
	 *For the glass pane...TBD
	 */
	
	static private JEditorPane s_oSWFPane;
	static private VizPlayerGlassPane s_oGlassPane;
	
	static private VizPlayerIFrame s_oIFrame; //singleton pattern
	private VizPlayerIFrame() {
		super(); //Creates a non-resizable, non-closable, non-maximizable, non-iconifiable JInternalFrame with no title.
		this.hideTitleBar();
		this.setBorder(BorderFactory.createEmptyBorder());
		s_oSWFPane = createPlayerHtmlPanel();
		this.getContentPane().add(s_oSWFPane);
		this.setGlassPane(s_oGlassPane = new VizPlayerGlassPane());
		this.setSize(800, 600);
		this.show();
	}
	
	static VizPlayerIFrame getInstance() {
		if (s_oIFrame == null) {
			s_oIFrame = new VizPlayerIFrame();
		}
		return s_oIFrame;
	}
	static void resetPlayer() {
		//TODO
	}
	void setSWFPath(String sSWFPath) {
		StringBuilder sb = new StringBuilder();
        sb.append("<HTML><HEAD></HEAD><BODY>");
        sb.append("<P>SWF path: ");
        sb.append(sSWFPath);
        sb.append("</P>");
        //sb.append("<A HREF='file:///C:/Documents%20and%20Settings/pautlerd/Desktop/bookended1.png'>frame1.png</A>&nbsp;");
        //sb.append("<A HREF='file:///C:/Documents%20and%20Settings/pautlerd/Desktop/bookended2.png'>frame2.png</A>&nbsp;");
        //sb.append("<A HREF='file:///C:/Documents%20and%20Settings/pautlerd/Desktop/bookended3.png'>frame3.png</A>");
        sb.append("<IMG SRC='file:///C:/Documents%20and%20Settings/pautlerd/Desktop/bookended1.png'/>");
        sb.append("</BODY></HTML>");
        
        s_oSWFPane.setText(sb.toString());
        validate();
	}
	void drawStationary(	Integer iXCentroid,
							Integer iYCentroid,
							Integer iFigureId,
							//CompoundTerm oShapeTerm,
							Integer iElapsedTime )
	{
		s_oGlassPane.drawStationary(iXCentroid, iYCentroid,
									iFigureId, iElapsedTime );
	}
	void drawLinear(	Integer iXCentroid,
						Integer iYCentroid,
						Double dXMagnitude,
						Double dYMagnitude,
						Integer iFigureId,
						//CompoundTerm oShapeTerm,
						Integer iElapsedTime )
	{
		s_oGlassPane.drawLinear(iXCentroid, iYCentroid,
								dXMagnitude, dYMagnitude,
								iFigureId, iElapsedTime );
	}
	void drawForce(	Integer iXCentroid,
					Integer iYCentroid,
					Double dXMagnitude,
					Double dYMagnitude,
					String sDirection,
					Integer iFigureId,
					//CompoundTerm oShapeTerm,
					Integer iElapsedTime )
	{
		s_oGlassPane.drawForce(	iXCentroid, iYCentroid,
								dXMagnitude, dYMagnitude,
								sDirection, iFigureId, iElapsedTime );
	}
	
	private void hideTitleBar() {
		//Adapted from http://www.rgagnon.com/javadetails/java-0333.html
		( (javax.swing.plaf.basic.BasicInternalFrameUI)this.getUI() ).setNorthPane(null);
	}
	private JEditorPane createPlayerHtmlPanel() {
        JEditorPane playerHtmlPanel = new JEditorPane();
        playerHtmlPanel.setEditable(false);
        playerHtmlPanel.setContentType("text/html");
        playerHtmlPanel.setMinimumSize(new Dimension(750,500));

        return playerHtmlPanel;
    }
}
