package sg.ihpc.wayang;

import java.util.Collection;

import com.parctechnologies.eclipse.Atom;
import com.parctechnologies.eclipse.CompoundTerm;

public class CLPUtils {
	
	public static String toString(Collection<Object> L) {
		StringBuffer sb = new StringBuffer();
		sb = addToStringBuffer_Collection(L, sb);
		return sb.toString();
	}
	public static String toString(CompoundTerm oTerm) {
		StringBuffer sb = new StringBuffer();
		sb = addToStringBuffer_Term(oTerm, sb);
		return sb.toString();
	}
	static StringBuffer addToStringBuffer_Collection(	Collection<Object> L,
														StringBuffer sb )
	{
		sb.append("[");
		boolean bFirst = true;
		for (Object o : L) {
			if (!bFirst) sb.append(", ");
			bFirst = false;
			
			if (o instanceof CompoundTerm) {
				sb = addToStringBuffer_Term((CompoundTerm)o, sb);
			} else if (o instanceof Collection) {
				sb = addToStringBuffer_Collection((Collection)o, sb);
			} else {
				sb.append(o);
			}
		}
		sb.append("]");
		return sb;
	}
	static StringBuffer addToStringBuffer_Term(	CompoundTerm o,
												StringBuffer sb )
	{
		sb.append(o.functor());
		int iArity = o.arity();
		if (iArity > 0) {
			sb.append("(");
			Object oArg;
			boolean bFirst = true;
			for(int i=1; i <= iArity; i++) {
				if (!bFirst) sb.append(", ");
				bFirst = false;
				
				oArg = o.arg(i);
				if (oArg == null) {
					sb.append("VAR");
				} else if (oArg instanceof Atom) {
					sb = addToStringBuffer_Term((Atom)oArg, sb);
				} else if (oArg instanceof Collection) {
					sb = addToStringBuffer_Collection((Collection)oArg, sb);
				} else if (	(oArg instanceof Integer) ||
							(oArg instanceof Float) ||
							(oArg instanceof Double) ||
							(oArg instanceof String) )
				{
					sb.append(oArg);
				} else {
					sb = addToStringBuffer_Term((CompoundTerm)oArg, sb);
				}
			}
			sb.append(")");
		}
		return sb;
	}
}
