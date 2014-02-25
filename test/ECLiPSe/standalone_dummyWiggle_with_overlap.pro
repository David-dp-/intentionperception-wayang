:- compile(['stubsAndUtilsForStandalone.pro', 'settingsForStandalone.pro',
	'../../src/ECLiPSe/Observer/KnowledgeBase_wiggle.ecl']
   ).
   
:- resetStandalone.

% This replicates what the test would get from
%  circle15mm_dummy_wiggle_with_overlap.swf if it were run embedded in the Java
%  portion of the Wayang framework.
%
:- storedSettings(StoredSettings), 
	assert( inputForDebugging( [ settings(StoredSettings)
										 ,frame([timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(70, 98), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(82, 111), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(98, 112), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(112, 123), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(129, 123), circle(13), color(0, 204, 255))])
										 ,endOfFrames
							  			])).
							  
:- compile('test_dummyWiggle_with_overlap.pro').