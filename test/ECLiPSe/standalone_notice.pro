:- compile(['stubsAndUtilsForStandalone.pro', 'settingsForStandalone.pro',
	'../../src/ECLiPSe/Observer/KnowledgeBase_notice.ecl']
   ).
  
:- resetStandalone.

% This replicates what the test would get from
%  "circle15mm_translation_withStopAtTheEnd_and_noticedCircle.swf" if it were run embedded in the Java
%  portion of the Wayang framework.

:- storedSettings(StoredSettings),
   assert( inputForDebugging([ settings(StoredSettings)
										,frame([timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(150, 141), circle(13), color(0, 204, 255)), figure(2, position(199, 167), circle(13), color(255, 128, 0))])
										,frame([timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(157, 145), circle(13), color(0, 204, 255)), figure(2, position(199, 167), circle(13), color(255, 128, 0))])
										,frame([timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(163, 148), circle(13), color(0, 204, 255)), figure(2, position(199, 167), circle(13), color(255, 128, 0))])
										,frame([timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(170, 151), circle(13), color(0, 204, 255)), figure(2, position(199, 167), circle(13), color(255, 128, 0))])
										,frame([timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(177, 155), circle(13), color(0, 204, 255)), figure(2, position(199, 167), circle(13), color(255, 128, 0))])
										,frame([timestamp(205), ground(334, 243, color(255, 255, 255)), figure(1, position(177, 155), circle(13), color(0, 204, 255)), figure(2, position(199, 167), circle(13), color(255, 128, 0))])
										,frame([timestamp(246), ground(334, 243, color(255, 255, 255)), figure(1, position(177, 155), circle(13), color(0, 204, 255)), figure(2, position(199, 167), circle(13), color(255, 128, 0))])
										,frame([timestamp(287), ground(334, 243, color(255, 255, 255)), figure(1, position(177, 155), circle(13), color(0, 204, 255)), figure(2, position(199, 167), circle(13), color(255, 128, 0))])
										,endOfFrames
									  ])).
									  
:- compile('test_notice.pro').