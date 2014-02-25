:- compile(['stubsAndUtilsForStandalone.pro', 'settingsForStandalone.pro',
	'../../src/ECLiPSe/Observer/KnowledgeBaseLoader.pro']
   ).
  
:- resetStandalone.

% This replicates what the test would get from
%  circle15mm_dummy_intention.swf if it were run embedded in the Java
%  portion of the Wayang framework.

:- storedSettings(StoredSettings),
   assert( inputForDebugging([ settings(StoredSettings)
										,frame([timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(104, 19), circle(13), color(0, 204, 255)), figure(2, position(166, 70), circle(13), color(255, 128, 0)), figure(3, position(179, 121), circle(13), color(204, 102, 255))])
										,frame([timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(112, 30), circle(13), color(0, 204, 255)), figure(2, position(166, 70), circle(13), color(255, 128, 0)), figure(3, position(179, 121), circle(13), color(204, 102, 255))])
										,frame([timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(121, 41), circle(13), color(0, 204, 255)), figure(2, position(166, 70), circle(13), color(255, 128, 0)), figure(3, position(179, 121), circle(13), color(204, 102, 255))])
										,frame([timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(129, 53), circle(13), color(0, 204, 255)), figure(2, position(166, 70), circle(13), color(255, 128, 0)), figure(3, position(179, 121), circle(13), color(204, 102, 255))])
										,frame([timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(129, 53), circle(13), color(0, 204, 255)), figure(2, position(166, 70), circle(13), color(255, 128, 0)), figure(3, position(179, 121), circle(13), color(204, 102, 255))])
										,frame([timestamp(205), ground(334, 243, color(255, 255, 255)), figure(1, position(129, 53), circle(13), color(0, 204, 255)), figure(2, position(166, 70), circle(13), color(255, 128, 0)), figure(3, position(179, 121), circle(13), color(204, 102, 255))])
										,frame([timestamp(246), ground(334, 243, color(255, 255, 255)), figure(1, position(129, 53), circle(13), color(0, 204, 255)), figure(2, position(166, 70), circle(13), color(255, 128, 0)), figure(3, position(179, 121), circle(13), color(204, 102, 255))])
										,frame([timestamp(287), ground(334, 243, color(255, 255, 255)), figure(1, position(129, 53), circle(13), color(0, 204, 255)), figure(2, position(166, 70), circle(13), color(255, 128, 0)), figure(3, position(179, 121), circle(13), color(204, 102, 255))])
										,frame([timestamp(328), ground(334, 243, color(255, 255, 255)), figure(1, position(125, 66), circle(13), color(0, 204, 255)), figure(2, position(166, 70), circle(13), color(255, 128, 0)), figure(3, position(179, 121), circle(13), color(204, 102, 255))])
										,frame([timestamp(369), ground(334, 243, color(255, 255, 255)), figure(1, position(126, 81), circle(13), color(0, 204, 255)), figure(2, position(166, 70), circle(13), color(255, 128, 0)), figure(3, position(179, 121), circle(13), color(204, 102, 255))])
										,frame([timestamp(410), ground(334, 243, color(255, 255, 255)), figure(1, position(136, 91), circle(13), color(0, 204, 255)), figure(2, position(166, 70), circle(13), color(255, 128, 0)), figure(3, position(179, 121), circle(13), color(204, 102, 255))])
										,frame([timestamp(451), ground(334, 243, color(255, 255, 255)), figure(1, position(148, 99), circle(13), color(0, 204, 255)), figure(2, position(166, 70), circle(13), color(255, 128, 0)), figure(3, position(179, 121), circle(13), color(204, 102, 255))])
										,frame([timestamp(492), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 107), circle(13), color(0, 204, 255)), figure(2, position(166, 70), circle(13), color(255, 128, 0)), figure(3, position(179, 121), circle(13), color(204, 102, 255))])
										,endOfFrames
									  ])).
									  
:- compile('test_dummyIntentionAnimation_multipleRules.pro').