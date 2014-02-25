:- compile('KnowledgeBase_trajectory.ecl').

%DOC
%An object that is stationary could be inferred to have noticed another object if the following constraints are met:
% 1) The other object is in close proximity to the stationary object at the start of the period spanned by this rule.
% 2) The stationary object was not stationary prior to the period spanned by this rule.
% 3) The time period that the stationary trajectory spans is within the defined lower and upper limits.
%The second constraint is not implemented as an RHS effect, but rather as a constraint in the contingency list.
%The only RHS effect to match is the stationary trajectory, and the rule will span the same time period that the stationary
%trajectory spans.
%
:- addRule(
   notice,
   <=( cause(  notice(FigureId,
   					  NoticedFigureId,
   					  ElapsedTime1,ElapsedTime2,
   					  CF,
   					  DrawInstrs ),
   			   [figureHasTrajectory( FigureId,
   			   						 StationaryTrajectory,
   			   						 ElapsedTime1,ElapsedTime2,
   			   						 CF1,
   			   						 originally(Shape1,Color1),
   			   						 _DrawInstr2,
   			   						 _BaseRecursiveOrWiggle )
   			   ]
   			),
   	   [1:compute(StationaryTrajectory = stationaryTrajectory(originalPosition(X1,Y1))
   	   			 ),
   	    2:compute((StationaryElapsedTime is ElapsedTime2 - ElapsedTime1,
   	    		   setting(minElapsedTimeOfStationaryTrajectoryForNotice(MinElapsedTimeOfStationaryTrajectoryForNotice)),
   	    		   setting(maxElapsedTimeOfStationaryTrajectoryForNotice(MaxElapsedTimeOfStationaryTrajectoryForNotice)),
   	    		   StationaryElapsedTime >= MinElapsedTimeOfStationaryTrajectoryForNotice,
   	    		   StationaryElapsedTime =< MaxElapsedTimeOfStationaryTrajectoryForNotice
   	    		 )),
   	    3:compute((findAnyCorroboratingEdgeWithCut(_SpanEnd1,_SpanEnd2,
   	    									figureHasTrajectory(FigureId,
   	    														Trajectory2,
   	    														ElapsedTime0,ElapsedTime1,
   	    														CF2,
   	    														_Originally2,
   	    														_DrawInstr3,
   	    														_BaseRecursiveOrWiggle2
   	    													   ),
   	    									CF3,_ParentId,_RHS_parsedParts),
   	    		   Trajectory2 \= stationaryTrajectory(_OriginalPosition2)	
   	    		 )),
   	    4:compute((findAnyCorroboratingEdge(_SpanEnd3,_SpanEnd4,
   	    									[timestamp(ElapsedTime1),
   	    									 figure(NoticedFigureId,position(X2,Y2),_Shape2,_Color2)],
   	    									CF4,_ParentID2,_RHS_parsedParts2),
   	    		   NoticedFigureId \= FigureId,
   	    		   setting(maxDistanceToNoticedObject(MaxDistanceToNoticedObject)),
   	    		   %Constrain the location of the noticed figure to be anywhere within a circle centred at
   	    		   %the location of the noticing figure with a radius of MaxDistanceToNoticedObject
   	    		   %//TODO the location of the noticed figure probably needs to be more restricted
   	    		   positionLiesWithinCircle((X2,Y2),X1,Y1,MaxDistanceToNoticedObject)
   	    		 )),
   	    %Generate draw instrs
   	    5:compute((RuleLHSWithoutDIWithCFReplaced = notice(FigureId,
   					  									   NoticedFigureId,
   					  									   ElapsedTime1,ElapsedTime2,
   					  									   cv),
   				   generatePositionList(FigureId,ElapsedTime1,ElapsedTime2,PositionListForDI),
   				   genDrawInstructions(FigureId,Shape1,Color1,ElapsedTime1,ElapsedTime2,
			  		 				   RuleLHSWithoutDIWithCFReplaced,CF,[PositionListForDI],
			  		 				   [NoticedFigureId],
			  		 				   notice,DrawInstrs)
   	    		 )),
   	    6:compute( CF = CF1 ) %//TODO: properly define the CF function		 	
   	   ])). 	  