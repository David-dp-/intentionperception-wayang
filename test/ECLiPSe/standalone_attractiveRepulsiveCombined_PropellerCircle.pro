:- compile(['stubsAndUtilsForStandalone.pro', 'settingsForStandalone.pro',
	'../../src/ECLiPSe/Observer/KnowledgeBase_attractiveRepulsiveCombined.ecl']
   ).
  
:- resetStandalone.

% This replicates what the test would get from
%  circle15mm_curved_withAttractorRepulsor_PropellerCircle.swf if it were run embedded in the Java
%  portion of the Wayang framework.
									  
:- storedSettings(StoredSettings),
   assert( inputForDebugging( [ settings(StoredSettings)
										 ,frame([timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(106, 51), circle(26), color(153, 51, 0)), figure(2, position(221, 129), circle(26), color(0, 0, 255)), figure(3, position(172, 58), circle(26), color(51, 255, 0)), figure(4, position(121, 70), circle(26), color(255, 0, 0))])
										 ,frame([timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(106, 51), circle(26), color(153, 51, 0)), figure(2, position(221, 129), circle(26), color(0, 0, 255)), figure(3, position(172, 58), circle(26), color(51, 255, 0)), figure(4, position(128, 88), circle(26), color(255, 0, 0))])
										 ,frame([timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(106, 51), circle(26), color(153, 51, 0)), figure(2, position(221, 129), circle(26), color(0, 0, 255)), figure(3, position(172, 58), circle(26), color(51, 255, 0)), figure(4, position(137, 106), circle(26), color(255, 0, 0))])
										 ,endOfFrames
									   ])).
									 
:- compile('test_attractiveRepulsiveCombined_PropellerCircle.pro').