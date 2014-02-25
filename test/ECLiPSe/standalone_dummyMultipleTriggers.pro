:-	compile(['stubsAndUtilsForStandalone.pro', 'settingsForStandalone.pro',
	'KnowledgeBase_test.ecl']
	).
   

:- resetStandalone.

% This replicates what the test would get from circle15mm_translation.swf if
%  it were run embedded in the Java portion of the Wayang framework.
							  
:- storedSettings(StoredSettings),
   assert( inputForDebugging( [ settings(StoredSettings)
								,frame([timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(121, 70), circle(26), color(255, 0, 0))])
								,frame([timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))])
								,frame([timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))])
								,frame([timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))])
								,frame([timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(173, 105), circle(26), color(255, 0, 0))])
								,endOfFrames
							 ])).

:- compile('test_dummyMultipleTriggers.pro').