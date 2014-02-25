package sg.ihpc.wayangTest.viz;

import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.Font;

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

import sg.ihpc.wayang.ControlState;
import sg.ihpc.wayang.IControlState;
import sg.ihpc.wayangTest.TestEnvironment;


public class VizWindow implements IVizWindow { //uses Singleton pattern
	
	static private JFrame s_oFrame;
	
	static private TestEnvironment s_oEnv;
	
	//Component listeners set values in this object, and methods in the world
	// model read those values, allowing the GUI to control the inference engine.
	static private ControlState s_oControlState;
	
	static private JTextField s_oTestOutcomeIndicator;
	
	static private VizPlayerNextFrameGuard s_oNextFrameGuard;
	static private VizPlayerNextFrameButton s_oNextFrameButton;
	static private VizPlayerIFrame s_oPlayerIFrame;
	
	static private JPanel s_oGrapherPanel;
	static private VizGrapherPanel s_oGraphSubPanel;
	
	static private VizWindow s_oViz;
	private VizWindow(TestEnvironment oEnv) {
		s_oEnv = oEnv;
		s_oControlState = new ControlState();
		s_oNextFrameGuard = new VizPlayerNextFrameGuard();
		
		//Based on http://download.oracle.com/javase/tutorial/uiswing/layout/box.html
		
		JPanel 	contentPanel		= new JPanel(),
				testSelectionPanel	= new JPanel(),
				twoViewsPanel		= new JPanel();
		
		testSelectionPanel.setAlignmentX(Component.LEFT_ALIGNMENT);
		twoViewsPanel.setAlignmentX(Component.LEFT_ALIGNMENT);
		
		s_oFrame = new JFrame("Wayang Visualizer");
	    s_oFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	    s_oFrame.setContentPane(contentPanel);
	    
	    contentPanel.setLayout(new BoxLayout(contentPanel, BoxLayout.Y_AXIS));
	    contentPanel.add(Box.createRigidArea(new Dimension(0,5)));
	    contentPanel.add(testSelectionPanel);
	    contentPanel.add(Box.createRigidArea(new Dimension(0,5)));
	    contentPanel.add(twoViewsPanel);
	    contentPanel.add(Box.createRigidArea(new Dimension(0,5)));
	    
	    //Based on http://download.oracle.com/javase/tutorial/uiswing/components/combobox.html
	    	    
	    JComboBox testsDropdown = new VizTestsDropdown(this);
	    testsDropdown.setAlignmentX(Component.LEFT_ALIGNMENT);
	    testsDropdown.addActionListener(new VizTestsDropdownListener());
	    
	    VizTestsStopBeforeNextFrame stopAfterEachFrame = new VizTestsStopBeforeNextFrame(this);
	    stopAfterEachFrame.setAlignmentX(Component.LEFT_ALIGNMENT);
	    stopAfterEachFrame.addItemListener(new VizTestsStopBeforeNextFrameListener());
	    
	    JPanel testOutcomePane = new JPanel();
	    testOutcomePane.setAlignmentX(Component.LEFT_ALIGNMENT);
	    testOutcomePane.setLayout(new BoxLayout(testOutcomePane,BoxLayout.X_AXIS));
	    JLabel outcomeLabel = new JLabel("Outcome: ");
	    testOutcomePane.add(outcomeLabel);
	    s_oTestOutcomeIndicator = new JTextField("");
	    s_oTestOutcomeIndicator.setEditable(false);
	    s_oTestOutcomeIndicator.setForeground(Color.BLACK);
	    testOutcomePane.add(s_oTestOutcomeIndicator);
	    
	    testSelectionPanel.setLayout(new BoxLayout(testSelectionPanel,BoxLayout.Y_AXIS));
	    testSelectionPanel.setBorder( BorderFactory.createTitledBorder("Desired test case") );
	    testSelectionPanel.add(stopAfterEachFrame); //Dropdown listener enforces this choice
	    testSelectionPanel.add(testsDropdown);
	    testSelectionPanel.add(Box.createRigidArea(new Dimension(0,5)));
	    testSelectionPanel.add(testOutcomePane);
	    testSelectionPanel.add(Box.createRigidArea(new Dimension(0,5)));
	    
	    JPanel	playerPanel	= new JPanel();
	    s_oGrapherPanel 	= new JPanel();
	    
	    twoViewsPanel.setLayout(new BoxLayout(twoViewsPanel,BoxLayout.X_AXIS));
	    twoViewsPanel.add(playerPanel);
	    twoViewsPanel.add(Box.createRigidArea(new Dimension(10, 0)));
	    twoViewsPanel.add(s_oGrapherPanel);
	    
	    s_oNextFrameButton = new VizPlayerNextFrameButton(this);
	    s_oPlayerIFrame = VizPlayerIFrame.getInstance();
	    playerPanel.setLayout(new BoxLayout(playerPanel, BoxLayout.Y_AXIS));
	    playerPanel.setBorder( BorderFactory.createTitledBorder("Player") );
	    playerPanel.add(s_oPlayerIFrame);
	    playerPanel.add(Box.createRigidArea(new Dimension(0,10)));
	    playerPanel.add(s_oNextFrameButton);
	    
	    s_oGrapherPanel.setLayout(new BoxLayout(s_oGrapherPanel, BoxLayout.Y_AXIS));
	    s_oGrapherPanel.setBorder( BorderFactory.createTitledBorder("Grapher") );
	    newGraph(); //FIXME called instead in VizTestsDropdownListener
	    
	    s_oFrame.pack(); //set window size to accommodate its contents
	    s_oFrame.setVisible(true);       
	}
	//To permit components to set values
	/*
	static ControlState getControlState () {
		return s_oControlState;
	}
	static VizNextFrameButton getNextFrameButton() {
		return s_oNextFrameButton;
	}
	*/
	
	
	//These are the only methods accessible outside this package, by design
	
	
	
	
	static public VizWindow getInstance(TestEnvironment oEnv) {
		if (s_oViz == null) {
			s_oViz = new VizWindow(oEnv);
		}
		return s_oViz;
	}
	public VizPlayerNextFrameGuard getNextFrameGuard() {
		return s_oNextFrameGuard;
	}
	public void considerEnablingNextFrameButton(boolean bEnoughFramesToJustifyPause) {
		boolean bEnableNextFrameButton
				= ( bEnoughFramesToJustifyPause &&
					s_oControlState.getStopAfterEachFrame() &&
					!s_oControlState.getAdvanceAtNextFrameRequest() );
			
		s_oNextFrameButton.setEnabled(bEnableNextFrameButton);
	}
	public IControlState getIControlState () {
		return (IControlState)s_oControlState;
	}
	public void indicateTestOutcomeNotYetKnown(boolean bWaiting) {
		s_oTestOutcomeIndicator.setBackground(Color.WHITE);
	    Font sameFontButItalic
			= new Font(	s_oTestOutcomeIndicator.getFont().getName(),
			    		Font.ITALIC,
			    		s_oTestOutcomeIndicator.getFont().getSize());
	    s_oTestOutcomeIndicator.setFont(sameFontButItalic);
		s_oTestOutcomeIndicator.setText((bWaiting ? "Waiting for next frame (Press the 'Next frame' button)" : "Processing"));
		s_oTestOutcomeIndicator.validate();
	}
	public void indicateTestOutcome(boolean bTestSucceeded) {
		s_oTestOutcomeIndicator.setBackground(bTestSucceeded ? Color.GREEN : Color.RED);
	    Font sameFontButBold
			= new Font(	s_oTestOutcomeIndicator.getFont().getName(),
			    		Font.BOLD,
			    		s_oTestOutcomeIndicator.getFont().getSize());
	    s_oTestOutcomeIndicator.setFont(sameFontButBold);
		s_oTestOutcomeIndicator.setText(bTestSucceeded ? "Passed" : "FAILED");
		s_oTestOutcomeIndicator.validate();
	}
	public void drawStationary(	Integer iXCentroid,
								Integer iYCentroid,
								Integer iFigureId,
								//CompoundTerm oShapeTerm,
								Integer iElapsedTime )
	{
		((VizPlayerGlassPane)s_oPlayerIFrame.getGlassPane()).drawStationary(iXCentroid, iYCentroid, iFigureId, iElapsedTime);
	}
	public void drawLinear(	Integer iXCentroid,
							Integer iYCentroid,
							Double dXMagnitude,
							Double dYMagnitude,
							Integer iFigureId,
							//CompoundTerm oShapeTerm,
							Integer iElapsedTime )
	{
		((VizPlayerGlassPane)s_oPlayerIFrame.getGlassPane()).drawLinear(iXCentroid, iYCentroid, dXMagnitude, dYMagnitude, iFigureId, iElapsedTime);
	}
	public void drawForce(	Integer iXCentroid,
							Integer iYCentroid,
							Double dXMagnitude,
							Double dYMagnitude,
							String sDirection,
							Integer iFigureId,
							//CompoundTerm oShapeTerm,
							Integer iElapsedTime )
	{
		((VizPlayerGlassPane)s_oPlayerIFrame.getGlassPane()).drawForce(iXCentroid, iYCentroid, dXMagnitude, dYMagnitude, sDirection, iFigureId, iElapsedTime);
	}
	public void drawCurved (Integer iXCentroid,
							Integer iYCentroid,
							Integer iXCentroid2,
							Integer iYCentroid2,
							Integer iElapsedTime1,
							Integer iElapsedTime2,
							Double  iXCentroidC,
							Double  iYCentroidC,
							Double  Radius,
							//CompoundTerm oShapeTerm,
							Integer iFigureId ) 
	{
		//TODO
	}
	public void drawIntendAtPositionStationary( Integer iXCentroid,
												Integer iYCentroid,
												Integer iFigureId,
												//CompoundTerm oShapeTerm,
												Integer iElapsedTime)
	{
		//TODO
	}
	public void drawIntendAtPositionLinear( Integer iXCentroid,
											Integer iYCentroid,
											Double dXMagnitude,
											Double dYMagnitude,
											Integer iFigureId,
											//CompoundTerm oShapeTerm,
											Integer iElapsedTime)
	{
		//TODO
	}
	public void addEdge(	int iIdOfSourceNode,
							int iIdOfDestinationNode,
							VizGrapherArc.Predicate ePredicate,
							VizGrapherArc.Completion eCompletion,
							VizGrapherArc.AMismatch eAMismatch,
							String sDescription )
	{
		s_oGraphSubPanel.addEdge(	iIdOfSourceNode, iIdOfDestinationNode,
									ePredicate, eCompletion, eAMismatch,
									sDescription );
	}
	void setSWFPath(String sSWFPath) {
		VizPlayerIFrame.getInstance().setSWFPath(sSWFPath);
	}
	void newGraph() {
		if (s_oGraphSubPanel != null) {
			s_oGrapherPanel.remove(s_oGraphSubPanel);
		}
		s_oGraphSubPanel = new VizGrapherPanel(s_oEnv);
	    s_oGrapherPanel.add(s_oGraphSubPanel);
	    s_oGrapherPanel.validate();
	}
	void resetGraph() {
		//VizPlayerIFrame.resetPlayer();
		
		//s_oGraphSubPanel.resetGraph(); //bug: leads to ConcurrentModificationException
		//newGraph(); //bug: old graph contents appear in new one
		s_oGraphSubPanel.removeAll(); //bug: old graph contents appear in new one
	}
	
}
