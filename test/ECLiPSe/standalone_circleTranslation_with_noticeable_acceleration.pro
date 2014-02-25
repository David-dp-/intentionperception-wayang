:- compile(['stubsAndUtilsForStandalone.pro', 'settingsForStandalone.pro',%incl src/ECLiPSe/Observer/loader.pro
	'../../src/ECLiPSe/Observer/KnowledgeBase_trajectory.ecl']
   ).

:- resetStandalone.

% This replicates what the test would get from circle15mm_translation_with_noticeable_acceleration.swf if
%  it were run embedded in the Java portion of the Wayang framework.
%

:- storedSettings(StoredSettings),
   assert( inputForDebugging( [ settings(StoredSettings)
								,frame([timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(27, 21), circle(26), color(255, 0, 0))])
								,frame([timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(34, 26), circle(26), color(255, 0, 0))])
								,frame([timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(52, 37), circle(26), color(255, 0, 0))])
								,frame([timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(98, 66), circle(26), color(255, 0, 0))])
								,frame([timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(212, 137), circle(26), color(255, 0, 0))])
								,endOfFrames
							  ])).
							  
:- compile('test_circleTranslation_with_noticeable_acceleration.pro').