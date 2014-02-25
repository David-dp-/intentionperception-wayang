intendToApproachOrAvoid_edgesAreCorrect :-
	populateEdgeSummariesForVerification(intendToApproachOrAvoid_edgeSummaries),
	
	processFrames.
	

% The canonical set of completed and incomplete edges for the
%  "circle15mm_translation_bookended.swf" scenario when the
%  'intendToApproachAvoid_baseStep' and 'intendToApproachAvoid_recursiveStep' rules are enabled.

intendToApproachOrAvoid_edgeSummaries([]).