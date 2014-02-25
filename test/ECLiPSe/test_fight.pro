fight_edgesAreCorrect :-
	populateEdgeSummariesForVerification(fight_edgeSummaries),
	processFrames.
	
% The canonical set of completed and incomplete edges for the
% fight animation when the
% linear & stationary trajectory rules are enabled.
%
fight_edgeSummaries(
[]
).