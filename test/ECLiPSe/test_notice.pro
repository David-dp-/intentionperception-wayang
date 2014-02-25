notice_edgesAreCorrect :-
	populateEdgeSummariesForVerification(notice_edgeSummaries),
	
	processFrames.
	
% The canonical set of completed and incomplete edges for the 
% "circle15mm_translation_withStopAtTheEnd_and_noticedCircle.swf" scenario
% with the notice rule activated.
%

notice_edgeSummaries([]).