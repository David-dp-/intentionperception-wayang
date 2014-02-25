package sg.ihpc.wayang.swf;

class Pair<A, B> {
	private A _xFirst;
	private B _xSecond;
	
	Pair(A xFirst, B xSecond) {
		_xFirst = xFirst;
		_xSecond = xSecond;
	}
	
	public A getFirst() {
		return _xFirst;
	}
	public B getSecond() {
		return _xSecond;
	}
}
