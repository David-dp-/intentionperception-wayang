:- compile(['stubsAndUtilsForStandalone.pro', 'settingsForStandalone.pro',
	'../../src/ECLiPSe/Observer/KnowledgeBase_wiggle.ecl']
   ).
   
:- resetStandalone.

% This replicates what the test would get from
%  Intention_curved_part.swf if it were run embedded in the Java
%  portion of the Wayang framework.
%
:- storedSettings(StoredSettings), 
	assert( inputForDebugging( [ settings(StoredSettings)
                    				 ,frame([timestamp(0), ground(304, 243, color(255, 255, 255)), figure(1, position(146, 130), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(41), ground(304, 243, color(255, 255, 255)), figure(1, position(146, 131), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(82), ground(304, 243, color(255, 255, 255)), figure(1, position(146, 131), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(123), ground(304, 243, color(255, 255, 255)), figure(1, position(146, 131), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(164), ground(304, 243, color(255, 255, 255)), figure(1, position(146, 132), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(205), ground(304, 243, color(255, 255, 255)), figure(1, position(147, 133), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(246), ground(304, 243, color(255, 255, 255)), figure(1, position(147, 134), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(287), ground(304, 243, color(255, 255, 255)), figure(1, position(148, 136), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(328), ground(304, 243, color(255, 255, 255)), figure(1, position(149, 137), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(369), ground(304, 243, color(255, 255, 255)), figure(1, position(149, 139), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(410), ground(304, 243, color(255, 255, 255)), figure(1, position(150, 141), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(451), ground(304, 243, color(255, 255, 255)), figure(1, position(152, 143), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(492), ground(304, 243, color(255, 255, 255)), figure(1, position(152, 146), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(533), ground(304, 243, color(255, 255, 255)), figure(1, position(153, 149), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(574), ground(304, 243, color(255, 255, 255)), figure(1, position(154, 151), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(615), ground(304, 243, color(255, 255, 255)), figure(1, position(155, 154), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(656), ground(304, 243, color(255, 255, 255)), figure(1, position(156, 158), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(697), ground(304, 243, color(255, 255, 255)), figure(1, position(158, 161), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(738), ground(304, 243, color(255, 255, 255)), figure(1, position(160, 164), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(779), ground(304, 243, color(255, 255, 255)), figure(1, position(163, 168), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(820), ground(304, 243, color(255, 255, 255)), figure(1, position(166, 171), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(861), ground(304, 243, color(255, 255, 255)), figure(1, position(169, 175), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(902), ground(304, 243, color(255, 255, 255)), figure(1, position(172, 179), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(943), ground(304, 243, color(255, 255, 255)), figure(1, position(174, 183), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(984), ground(304, 243, color(255, 255, 255)), figure(1, position(178, 187), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1025), ground(304, 243, color(255, 255, 255)), figure(1, position(183, 190), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1066), ground(304, 243, color(255, 255, 255)), figure(1, position(188, 191), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1107), ground(304, 243, color(255, 255, 255)), figure(1, position(189, 193), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1148), ground(304, 243, color(255, 255, 255)), figure(1, position(194, 196), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1189), ground(304, 243, color(255, 255, 255)), figure(1, position(198, 198), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1230), ground(304, 243, color(255, 255, 255)), figure(1, position(203, 200), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1271), ground(304, 243, color(255, 255, 255)), figure(1, position(207, 201), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1312), ground(304, 243, color(255, 255, 255)), figure(1, position(211, 202), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1353), ground(304, 243, color(255, 255, 255)), figure(1, position(215, 202), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1394), ground(304, 243, color(255, 255, 255)), figure(1, position(219, 203), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1435), ground(304, 243, color(255, 255, 255)), figure(1, position(223, 204), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1476), ground(304, 243, color(255, 255, 255)), figure(1, position(226, 206), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1517), ground(304, 243, color(255, 255, 255)), figure(1, position(229, 207), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1558), ground(304, 243, color(255, 255, 255)), figure(1, position(232, 208), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1599), ground(304, 243, color(255, 255, 255)), figure(1, position(235, 208), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1640), ground(304, 243, color(255, 255, 255)), figure(1, position(238, 208), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1681), ground(304, 243, color(255, 255, 255)), figure(1, position(241, 209), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1722), ground(304, 243, color(255, 255, 255)), figure(1, position(244, 209), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1763), ground(304, 243, color(255, 255, 255)), figure(1, position(246, 209), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1804), ground(304, 243, color(255, 255, 255)), figure(1, position(249, 210), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1845), ground(304, 243, color(255, 255, 255)), figure(1, position(251, 210), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1886), ground(304, 243, color(255, 255, 255)), figure(1, position(253, 211), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1927), ground(304, 243, color(255, 255, 255)), figure(1, position(254, 211), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(1968), ground(304, 243, color(255, 255, 255)), figure(1, position(256, 211), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(2009), ground(304, 243, color(255, 255, 255)), figure(1, position(257, 212), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(2050), ground(304, 243, color(255, 255, 255)), figure(1, position(258, 212), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(2091), ground(304, 243, color(255, 255, 255)), figure(1, position(259, 212), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(2132), ground(304, 243, color(255, 255, 255)), figure(1, position(259, 212), circle(13), color(0, 204, 255))])
                               ,frame([timestamp(2173), ground(304, 243, color(255, 255, 255)), figure(1, position(259, 212), circle(13), color(0, 204, 255))]) 						 
										 ,endOfFrames
							  			])).
							  
:- compile('test_wiggleOnCurvedPartOfIntentionAnimation.pro').