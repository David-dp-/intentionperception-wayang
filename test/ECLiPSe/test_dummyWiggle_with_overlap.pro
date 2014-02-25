dummyWiggle_with_overlap_edgesAreCorrect :-
	populateEdgeSummariesForVerification(dummyWiggle_with_overlap_edgeSummaries),
	
	processFrames.
	
% The canonical set of completed and incomplete edges for the
%  "circle15mm_dummy_wiggle_with_overlap.swf" scenario when the
%  wiggle rules are enabled.
%
dummyWiggle_with_overlap_edgeSummaries([]). %//TODO populate edge summaries.