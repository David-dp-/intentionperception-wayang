:- compile('KnowledgeBase_intendToApproachAvoidCombined.ecl').
:- compile('KnowledgeBase_intendToApproachAvoid.ecl').
:- compile('KnowledgeBase_notice.ecl').

%DOC
%These rules link a single intention to approach that is either directly followed by
%combined intentions to approach and avoid, or followed by noticing of the avoided
%object, then followed by combined intentions to approach and avoid.
%The intention to approach exists throughout the transition, whereas the
%intention to avoid is added after the transition to the combined intentions.
%

%First rule deals with a direct transition without noticing.
%
:- addRule(
	intentionToApproachAugmentedWithIntentionToAvoid_withoutNotice,
	<=( cause(augmented([ intend( FigureId,
								  approach,
								  ApproachedObjectId,
								  ElapsedTime1,ElapsedTime3,
								  CF,
								  DrawInstrs ),
						  intend( FigureId,
						  		  avoid,
								  ThreatObjectId,
								  ElapsedTime2,ElapsedTime3,
								  CF,
								  [] ) %DrawInstrs in 1st conjunct
			  			]),
			  [ intend( FigureId,
			  			approach,
			  			ApproachedObjectId,
			  			_LinearTrajectory,
			  			originally(Shape1,Color1),
			  			ElapsedTime1,ElapsedTime2,
			  			CF1,
			  			_DrawInstrs3,
			  			_BaseOrRecursive ),
			  	conjunction([ intend( FigureId,
			  			  			  avoid,
			  			  			  ThreatObjectId,
			  			  			  _CurvedTrajectory,
			  			  			  _LinearSegment,
			  			  			  originally(Shape2,Color2),
			  			  			  ElapsedTime2,ElapsedTime3,
			  			  			  CF2,
			  			  			  _DrawInstrs4 ),
			  	  			  intend( FigureId,
			  	  		  			  approach,
			  	  		  			  ApproachedObjectId,
			  	  		  			  _CurvedTrajectory,
			  	  		  			  _LinearSegment,
			  	  		  			  originally(Shape2,Color2),
			  	  		  			  ElapsedTime2,ElapsedTime3,
			  	  		  			  CF2,
			  	  		  			  _DrawInstrs5 )
			  				])
			  ]
			 ),
		[1:compute(combineConfidenceFactors([CF1,CF2],CF) %//TODO properly calculate CF
				  ),
		 %Attempt to reduce duplicates that are due to the component RHS effects possibly having duplicates
		 %themselves.
		 %Check whether there's already an existing edge covering the same time period with a higher CF value.
		 %The constraint is satisfied if and only if there's no such edge.
		 2:compute((Constraint = 
		 		    findall(CF3,
		 				    (findAnyCorroboratingEdge(_SpanEnd1,_SpanEnd2,
		 				   							  augmented([intend(FigureId,
		 				   							 				    approach,
		 				   							 				    ApproachedObjectId,
								  									    ElapsedTime1,ElapsedTime3,
								  									    CF3,
								  									    _DrawInstrs6),
								  								 intend(FigureId,
								  								    	avoid,
								  									    ThreatObjectId,
								  									    ElapsedTime2,ElapsedTime3,
								  									    CF3,
								  									    _DrawInstrs7)
								  							    ]
								  							   ),
								  					  _CF4,_ParentId1,_RHS_parsedParts1
								  					 ),
							 %We don't want to compare bounded reals, float/2 will convert the CFs to float values if the
 	 				  		 %CFs are indeed bounded reals.
 	 				  		 FloatCF3 is float(CF3),
 	 				  		 FloatCF is float(CF),
 	 				  		 FloatCF3 > FloatCF
 	 				  		),
 	 				  		[]
 	 				  	   ),
 	 				delayableDisjunctedCalls([CF],Constraint)
 	 			  )),
 	 	 %Generate draw instrs
 	 	 3:compute((RuleLHSWithoutDIWithCFReplaced = augmented([ intend( FigureId,
								  										 approach,
								  										 ApproachedObjectId,
								  										 ElapsedTime1,ElapsedTime3,
								  										 cv),
						  										 intend( FigureId,
						  		  										 avoid,
								  									   	 ThreatObjectId,
								  										 ElapsedTime2,ElapsedTime3,
								  										 cv)
			  												  ]),
			  		generatePositionList(FigureId,ElapsedTime1,ElapsedTime3,PositionListForDI),
			  		genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime3,
			  		 					RuleLHSWithoutDIWithCFReplaced,CF,[PositionListForDI],
			  		 					[ApproachedObjectId,ThreatObjectId,ElapsedTime2],
			  		 					intentionToApproachAugmentedWithIntentionToAvoid,DrawInstrs) 
 	 	 		  ))	  		
		])).
										
%Second rule deals with a transition with noticing in between.
%
:- addRule(
	intentionToApproachAugmentedWithIntentionToAvoid_withNotice,
	<=( cause(augmented([ intend( FigureId,
								  approach,
								  ApproachedObjectId,
								  ElapsedTime1,ElapsedTime4,
								  CF,
								  DrawInstrs ),
						  intend( FigureId,
						  		  avoid,
								  ThreatObjectId,
								  ElapsedTime3,ElapsedTime4,
								  CF,
								  [] ) %DrawInstrs in 1st conjunct
			  		    ]),
			  [ intend( FigureId,
			  			approach,
			  			ApproachedObjectId,
			  			_LinearTrajectory,
			  			originally(Shape1,Color1),
			  			ElapsedTime1,ElapsedTime2,
			  			CF1,
			  			_DrawInstrs3,
			  			_BaseOrRecursive ),
			  	notice( FigureId,
			  			ThreatObjectId,
			  			ElapsedTime2,ElapsedTime3,
			  			CF2,
			  			_DrawInstrs4 ),
			  	conjunction([ intend( FigureId,
			  			  			  avoid,
			  			  			  ThreatObjectId,
			  			  			  _CurvedTrajectory,
			  			  			  _LinearSegment,
			  			  			  originally(Shape2,Color2),
			  			  			  ElapsedTime3,ElapsedTime4,
			  			  			  CF3,
			  			  			  _DrawInstrs5 ),
			  	  			  intend( FigureId,
			  	  		  			  approach,
			  	  		  			  ApproachedObjectId,
			  	  		  			  _CurvedTrajectory,
			  	  		  			  _LinearSegment,
			  	  		  			  originally(Shape2,Color2),
			  	  		  			  ElapsedTime3,ElapsedTime4,
			  	  		  			  CF3,
			  	  		  			  _DrawInstrs6 )
			  				])
			  ]
			 ),
		[1:compute(combineConfidenceFactors([CF1,CF2,CF3],CF) %//TODO properly calculate CF
				  ),
		 %Attempt to reduce duplicates that are due to the component RHS effects (except for notice) possibly having duplicates
		 %themselves.
		 %Check whether there's already an existing edge covering the same time period with a higher CF value.
		 %The constraint is satisfied if and only if there's no such edge.
		 2:compute((Constraint = 
		 		    findall(CF4,
		 				    (findAnyCorroboratingEdge(_SpanEnd1,_SpanEnd2,
		 				   							  augmented([intend(FigureId,
		 				   							 				    approach,
		 				   							 				    ApproachedObjectId,
								  									    ElapsedTime1,ElapsedTime4,
								  									    CF4,
								  									    _DrawInstrs7),
								  								 intend(FigureId,
								  								    	avoid,
								  									    ThreatObjectId,
								  									    ElapsedTime3,ElapsedTime4,
								  									    CF4,
								  									    _DrawInstrs8)
								  							    ]
								  							   ),
								  					  _CF5,_ParentId1,_RHS_parsedParts1
								  					 ),
							 %We don't want to compare bounded reals, float/2 will convert the CFs to float values if the
 	 				  		 %CFs are indeed bounded reals.
 	 				  		 FloatCF4 is float(CF4),
 	 				  		 FloatCF is float(CF),
 	 				  		 FloatCF4 > FloatCF
 	 				  		),
 	 				  		[]
 	 				  	   ),
 	 				delayableDisjunctedCalls([CF],Constraint)
 	 			  )),
 	 	 %Generate draw instrs
 	 	 3:compute((RuleLHSWithoutDIWithCFReplaced = augmented([ intend( FigureId,
								  										 approach,
								  										 ApproachedObjectId,
								  										 ElapsedTime1,ElapsedTime4,
								  										 cv),
						  										 intend( FigureId,
						  		  										 avoid,
								  									   	 ThreatObjectId,
								  										 ElapsedTime3,ElapsedTime4,
								  										 cv)
			  												  ]),
			  		generatePositionList(FigureId,ElapsedTime1,ElapsedTime4,PositionListForDI),
			  		genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime4,
			  		 					RuleLHSWithoutDIWithCFReplaced,CF,[PositionListForDI],
			  		 					[ApproachedObjectId,ThreatObjectId,ElapsedTime3],
			  		 					intentionToApproachAugmentedWithIntentionToAvoid,DrawInstrs)
 	 	 		  ))	  		
		])).											   