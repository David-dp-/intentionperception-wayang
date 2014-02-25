:- compile(['stubsAndUtilsForStandalone.pro', 'settingsForStandalone.pro', %incl src/ECLiPSe/Observer/loader.pro
	'../../src/ECLiPSe/Observer/KnowledgeBase_attractiveRepulsive.ecl']
   ).

:- resetStandalone.

% This replicates what the test would get from
%  circle15mm_translation_with_repulsive_circle.swf if it were run embedded in the Java
%  portion of the Wayang framework.
%

:- storedSettings(StoredSettings),
   assert( inputForDebugging( [ settings(StoredSettings)
									,frame([timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(121, 70), circle(26), color(255, 0, 0)), figure(2, position(85, 46), circle(26), color(51, 255, 0))])
									,frame([timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0)), figure(2, position(85, 46), circle(26), color(51, 255, 0))])
									,frame([timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0)), figure(2, position(85, 46), circle(26), color(51, 255, 0))])
									,frame([timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0)), figure(2, position(85, 46), circle(26), color(51, 255, 0))])
									,frame([timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(173, 105), circle(26), color(255, 0, 0)), figure(2, position(85, 46), circle(26), color(51, 255, 0))])
									,endOfFrames
								  ])).

:- compile('test_repulsed.pro').
