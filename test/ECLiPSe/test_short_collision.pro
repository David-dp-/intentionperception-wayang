short_collision_edgesAreCorrect :-
	populateEdgeSummariesForVerification(short_collision_edgeSummaries),
	
	processFrames.
	
% The canonical set of completed and incomplete edges for the "short_collision.swf" scenario.
%

short_collision_edgeSummaries([]).