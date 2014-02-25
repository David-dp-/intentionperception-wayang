dummyWiggle_edgesAreCorrect :-
	populateEdgeSummariesForVerification(dummyWiggle_edgeSummaries),
	
	processFrames.
	
% The canonical set of completed and incomplete edges for the
%  "circle15mm_dummy_wiggle.swf" scenario when the
%  wiggle rules are enabled.
%
dummyWiggle_edgeSummaries([]). %//TODO populate edge summaries.