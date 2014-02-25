:- compile(['stubsAndUtilsForStandalone.pro', 'settingsForStandalone.pro',
	'../../src/ECLiPSe/Observer/KnowledgeBase_wiggle.ecl']
   ).
  
:- resetStandalone.

:- storedSettings(StoredSettings),
   assert( inputForDebugging([ settings(StoredSettings)
                              ,frame([timestamp(0), ground(304, 243, color(255, 255, 255)), figure(2, position(146, 130), circle(13), color(0, 204, 255))])
                              ,frame([timestamp(41), ground(304, 243, color(255, 255, 255)), figure(2, position(146, 131), circle(13), color(0, 204, 255))])
                              ,frame([timestamp(82), ground(304, 243, color(255, 255, 255)), figure(2, position(146, 132), circle(13), color(0, 204, 255))])
                              ,frame([timestamp(123), ground(304, 243, color(255, 255, 255)), figure(2, position(147, 133), circle(13), color(0, 204, 255))])
                              ,frame([timestamp(164), ground(304, 243, color(255, 255, 255)), figure(2, position(147, 134), circle(13), color(0, 204, 255))])
                              ,frame([timestamp(205), ground(304, 243, color(255, 255, 255)), figure(2, position(148, 136), circle(13), color(0, 204, 255))])
                              ,frame([timestamp(246), ground(304, 243, color(255, 255, 255)), figure(2, position(149, 137), circle(13), color(0, 204, 255))])
                              ,frame([timestamp(287), ground(304, 243, color(255, 255, 255)), figure(2, position(149, 139), circle(13), color(0, 204, 255))])
                              ,frame([timestamp(328), ground(304, 243, color(255, 255, 255)), figure(2, position(150, 141), circle(13), color(0, 204, 255))])
                              ,frame([timestamp(369), ground(304, 243, color(255, 255, 255)), figure(2, position(152, 143), circle(13), color(0, 204, 255))])
                              ,frame([timestamp(410), ground(304, 243, color(255, 255, 255)), figure(2, position(152, 146), circle(13), color(0, 204, 255))])
                              ,frame([timestamp(451), ground(304, 243, color(255, 255, 255)), figure(2, position(153, 149), circle(13), color(0, 204, 255))])
                              ,frame([timestamp(492), ground(304, 243, color(255, 255, 255)), figure(2, position(154, 151), circle(13), color(0, 204, 255))])
                              ,endOfFrames
                             ])).
                             