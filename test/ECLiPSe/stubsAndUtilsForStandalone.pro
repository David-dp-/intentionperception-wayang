:- dynamic inputForDebugging/1.

:- compile(['../../src/ECLiPSe/utils.pro', '../../src/ECLiPSe/Observer/loader.pro']).

resetStandalone :-
	(retract( inputForDebugging(_) ) ; true),
	(retractall( setting(_) ) ; true).

readTerm(InputTerm) :-
	popFromStack(InputTerm, inputForDebugging).

writeTerm(OutputTerm,_CompletionStatus) :-
	writeln('To stubbed out-queue:'),
	writeArgsOnePerLine(OutputTerm).
	
writeInput(_,_).

writeRowCloserString.

writeLogHeader.

generateDrawingInstruction(	_Id,_SpanStart,_SpanEnd,_LHS,_CF,			%input
							_RHS_parsedParts,_RHS_expectedParts,_ParentIds,
							[] ).										%output