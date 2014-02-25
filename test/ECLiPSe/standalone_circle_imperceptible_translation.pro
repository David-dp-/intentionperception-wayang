:- compile(['stubsAndUtilsForStandalone.pro', 'settingsForStandalone.pro',
	'../../src/ECLiPSe/Observer/KnowledgeBase_trajectory.ecl']
   ).

:- resetStandalone.

% This replicates what the test would get from circle_imperceptible_translation.swf if
%  it were run embedded in the Java portion of the Wayang framework.
:- storedSettings(StoredSettings),
   assert( inputForDebugging( [ settings(StoredSettings)
								,frame([timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(167, 122), circle(13), color(0, 204, 255))])
								,frame([timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(167, 122), circle(13), color(0, 204, 255))])
							  ])).
							  
:- compile('test_circle_imperceptible_translation.pro').