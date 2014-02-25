intentionAnimation_linearPart_edgesAreCorrect :-
	populateEdgeSummariesForVerification(intentionAnimation_linearPart_edgeSummaries),
	processFrames.
	
% The canonical set of completed and incomplete edges for the
% "Intention_linear_part.swf" scenario when the
%  stationary and linear trajectory rules are enabled.
%
intentionAnimation_linearPart_edgeSummaries(
[]
).