:- compile('../../src/ECLiPSe/Observer/KnowledgeBase_trajectory.ecl').
:- lib(ic).

%DOC - These rules are for test purposes only.

%Dummy rule with multiple LHS triggers.
:- addRule(
   dummyMultipleTriggers,
   <=( cause( [ dummyTrigger1( ElapsedTime1,ElapsedTime2,
   								CF,[]),
   				dummyTrigger2( ElapsedTime1,ElapsedTime2,
   								CF,[])
   			  ],
   			  [figureHasTrajectory(	_ObjectId,
										_Trajectory1,
										ElapsedTime1,ElapsedTime2,
										_CF1,
										originally(Shape1,_Color1),
										_DrawInstrs )
			  ]
			),
		[ 1:compute( CF is 0.9 )
		])). 

%Dummy rule which has as its only RHS a trigger that is in the list of triggers 
%for dummyMultipleTriggers.
:- addRule(
   dummySingleTrigger,
   <=( cause( dummyTrigger3(ElapsedTime1,ElapsedTime2,
   							  CF,[]),
   			  [dummyTrigger1(ElapsedTime1,ElapsedTime2,
   			  				  _CF1,[])
   			  ]
   			),
   		[ 1:compute( CF is 1.0 )
   		])).
  
   							 