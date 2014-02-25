package sg.ihpc.wayangTest.viz;

import java.awt.Color;

public class VizGrapherNode {
	private int _iId;
	
    VizGrapherNode(int id) {
        _iId = id;
    }
    public Color toColor() {
    	return Color.LIGHT_GRAY;
    }
    public String toString() {
        return String.valueOf(_iId); //Used in graph display
    }
}
