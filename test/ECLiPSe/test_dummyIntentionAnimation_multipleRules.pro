dummyIntentionAnimation_multipleRules_edgesAreCorrect :-
	populateEdgeSummariesForVerification(dummyIntentionAnimation_multipleRules_edgeSummaries),
	
	processFrames.
	

% The canonical set of completed and incomplete edges for the
% "circle15mm_dummy_intention.swf" scenario when 
% multiple rules are enabled.
%
dummyIntentionAnimation_multipleRules_edgeSummaries([]).