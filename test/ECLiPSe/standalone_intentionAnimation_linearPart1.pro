:- compile(['stubsAndUtilsForStandalone.pro', 'settingsForStandalone.pro',
	'../../src/ECLiPSe/Observer/KnowledgeBase_trajectory.ecl']
   ).
  
:- resetStandalone.

% This replicates what the test would get from
%  Intention_linear_part1.swf if it were run embedded in the Java
%  portion of the Wayang framework.

:- storedSettings(StoredSettings),
   assert( inputForDebugging( [ settings(StoredSettings)
										,frame([timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(33, 49), circle(13), color(0, 204, 255))])
										,frame([timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(33, 50), circle(13), color(0, 204, 255))])
										,frame([timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(36, 51), circle(13), color(0, 204, 255))])
										,frame([timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(38, 53), circle(13), color(0, 204, 255))])
										,frame([timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(41, 56), circle(13), color(0, 204, 255))])
										,frame([timestamp(205), ground(334, 243, color(255, 255, 255)), figure(1, position(43, 57), circle(13), color(0, 204, 255))])
										,frame([timestamp(246), ground(334, 243, color(255, 255, 255)), figure(1, position(46, 59), circle(13), color(0, 204, 255))])
										,frame([timestamp(287), ground(334, 243, color(255, 255, 255)), figure(1, position(48, 60), circle(13), color(0, 204, 255))])
										,frame([timestamp(328), ground(334, 243, color(255, 255, 255)), figure(1, position(51, 62), circle(13), color(0, 204, 255))])
										,frame([timestamp(369), ground(334, 243, color(255, 255, 255)), figure(1, position(54, 65), circle(13), color(0, 204, 255))])
										,frame([timestamp(410), ground(334, 243, color(255, 255, 255)), figure(1, position(57, 67), circle(13), color(0, 204, 255))])
										,frame([timestamp(451), ground(334, 243, color(255, 255, 255)), figure(1, position(60, 70), circle(13), color(0, 204, 255))])
										,frame([timestamp(492), ground(334, 243, color(255, 255, 255)), figure(1, position(63, 72), circle(13), color(0, 204, 255))])
										,frame([timestamp(533), ground(334, 243, color(255, 255, 255)), figure(1, position(66, 74), circle(13), color(0, 204, 255))])
										,frame([timestamp(574), ground(334, 243, color(255, 255, 255)), figure(1, position(69, 75), circle(13), color(0, 204, 255))])
										,frame([timestamp(615), ground(334, 243, color(255, 255, 255)), figure(1, position(72, 77), circle(13), color(0, 204, 255))])
										,frame([timestamp(656), ground(334, 243, color(255, 255, 255)), figure(1, position(75, 79), circle(13), color(0, 204, 255))])
										,frame([timestamp(697), ground(334, 243, color(255, 255, 255)), figure(1, position(79, 82), circle(13), color(0, 204, 255))])
										,frame([timestamp(738), ground(334, 243, color(255, 255, 255)), figure(1, position(82, 85), circle(13), color(0, 204, 255))])
										,frame([timestamp(779), ground(334, 243, color(255, 255, 255)), figure(1, position(85, 88), circle(13), color(0, 204, 255))])
										,frame([timestamp(820), ground(334, 243, color(255, 255, 255)), figure(1, position(89, 90), circle(13), color(0, 204, 255))])
										,frame([timestamp(861), ground(334, 243, color(255, 255, 255)), figure(1, position(92, 92), circle(13), color(0, 204, 255))])
										,frame([timestamp(902), ground(334, 243, color(255, 255, 255)), figure(1, position(96, 93), circle(13), color(0, 204, 255))])
										,frame([timestamp(943), ground(334, 243, color(255, 255, 255)), figure(1, position(100, 96), circle(13), color(0, 204, 255))])
										,frame([timestamp(984), ground(334, 243, color(255, 255, 255)), figure(1, position(103, 100), circle(13), color(0, 204, 255))])
										,frame([timestamp(1025), ground(334, 243, color(255, 255, 255)), figure(1, position(107, 102), circle(13), color(0, 204, 255))])
										,frame([timestamp(1066), ground(334, 243, color(255, 255, 255)), figure(1, position(111, 104), circle(13), color(0, 204, 255))])
										,frame([timestamp(1107), ground(334, 243, color(255, 255, 255)), figure(1, position(115, 107), circle(13), color(0, 204, 255))])
										,frame([timestamp(1148), ground(334, 243, color(255, 255, 255)), figure(1, position(119, 111), circle(13), color(0, 204, 255))])
										,endOfFrames
									  ])).
									  
:- compile('test_intentionAnimation_linearPart1.pro').