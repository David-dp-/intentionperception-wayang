:- lib(ic).
:- compile('KnowledgeBase_intendToBeAtPosition.ecl').
%:- compile('KnowledgeBase_intendToBeNear.ecl').

%DOC
%The rule corresponds to R6 in the manuscript.
%The rule implements the concept of "intention change for no specific reason".

:- addRule(
	changeOfIntention,
	<=( cause( intentionChanged( FigureId,
								 Intention1, ElapsedTime2, Intention2,
								 ElapsedTime1, ElapsedTime3,
								 CF3,
								 []%no draw instrs
							   ),
			   [intend(FigureId,
			   		   Intention1,
			   		   ElapsedTime1, ElapsedTime2,
			   		   CF1,
			   		   _DrawInstrs1
			   		  ),
			   	intend(FigureId,
			   		   Intention2,
			   		   ElapsedTime2, ElapsedTime3,
			   		   CF2,
			   		   _DrawInstrs2
			   		  )
			   ]
			 ),
		[1:compute( delayableNotInstance(Intention1,Intention2)
				  ),
		 2:compute( delayableMin([CF1,CF2],CF3) )
		])).
