:- compile(['stubsAndUtilsForStandalone.pro', 'settingsForStandalone.pro', %incl src/ECLiPSe/Observer/loader.pro
	'../../src/ECLiPSe/Observer/KnowledgeBase_attractiveRepulsive.ecl']
   ).

:- resetStandalone.

% This replicates what the test would get from
%  circle15mm_translation_with_constant_acceleration_with_attractive_circle.swf if it were run embedded in the Java
%  portion of the Wayang framework.
%
:- storedSettings(StoredSettings),  
   assert( inputForDebugging( [ settings(StoredSettings)
										 ,frame([timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(174, 117), circle(26), color(0, 0, 255)), figure(2, position(121, 70), circle(26), color(255, 0, 0))])
										 ,frame([timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(174, 117), circle(26), color(0, 0, 255)), figure(2, position(123, 72), circle(26), color(255, 0, 0))])
										 ,frame([timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(174, 117), circle(26), color(0, 0, 255)), figure(2, position(126, 75), circle(26), color(255, 0, 0))])
										 ,frame([timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(174, 117), circle(26), color(0, 0, 255)), figure(2, position(132, 80), circle(26), color(255, 0, 0))])
										 ,frame([timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(174, 117), circle(26), color(0, 0, 255)), figure(2, position(139, 87), circle(26), color(255, 0, 0))])
										 ,frame([timestamp(205), ground(334, 243, color(255, 255, 255)), figure(1, position(174, 117), circle(26), color(0, 0, 255)), figure(2, position(147, 96), circle(26), color(255, 0, 0))])
										 ,endOfFrames
							  			])).
							  
:- compile('test_attractedOrRepulsed2.pro').