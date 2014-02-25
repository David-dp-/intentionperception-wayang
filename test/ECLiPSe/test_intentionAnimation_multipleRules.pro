intentionAnimation_multipleRules_edgesAreCorrect :-
	populateEdgeSummariesForVerification(intentionAnimation_multipleRules_edgeSummaries),
	processFrames.
	
% The canonical set of completed and incomplete edges for the
% "Intention_full_May_2011_without_control_button.swf" scenario when
% multiple rules are enabled.
%
intentionAnimation_multipleRules_edgeSummaries([]).