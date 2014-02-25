controlAnimation_edgesAreCorrect :-
	populateEdgeSummariesForVerification(controlAnimation_edgeSummaries),
	processFrames.
	
% The canonical set of completed and incomplete edges for the
% control animation (Control_full_May_2011_without_control_button.swf) when the
% 'intendToBeAtPosition_baseStep' and 'intendToBeAtPosition_recursiveStep' 
% rules are enabled.
%
controlAnimation_edgeSummaries(
[]
).