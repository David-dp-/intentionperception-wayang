:- compile(['stubsAndUtilsForStandalone.pro', 'settingsForStandalone.pro', %incl src/ECLiPSe/Observer/loader.pro
				'../../src/ECLiPSe/Observer/KnowledgeBase_intendToBeAtPosition.ecl',
				'../../src/ECLiPSe/Observer/KnowledgeBase_wiggle.ecl']
   ).

:- resetStandalone.

:- storedSettings(StoredSettings), 
	assert( inputForDebugging( [ settings(StoredSettings)
										 ,frame([timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(146, 132), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 133), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 134), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(148, 136), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(149, 137), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(205), ground(334, 243, color(255, 255, 255)), figure(1, position(149, 139), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(246), ground(334, 243, color(255, 255, 255)), figure(1, position(150, 141), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(287), ground(334, 243, color(255, 255, 255)), figure(1, position(152, 143), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(328), ground(334, 243, color(255, 255, 255)), figure(1, position(152, 146), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(369), ground(334, 243, color(255, 255, 255)), figure(1, position(153, 149), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(410), ground(334, 243, color(255, 255, 255)), figure(1, position(154, 151), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(451), ground(334, 243, color(255, 255, 255)), figure(1, position(155, 154), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(492), ground(334, 243, color(255, 255, 255)), figure(1, position(156, 158), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(533), ground(334, 243, color(255, 255, 255)), figure(1, position(158, 161), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(574), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 164), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(615), ground(334, 243, color(255, 255, 255)), figure(1, position(163, 168), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(656), ground(334, 243, color(255, 255, 255)), figure(1, position(166, 171), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(697), ground(334, 243, color(255, 255, 255)), figure(1, position(169, 175), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(738), ground(334, 243, color(255, 255, 255)), figure(1, position(172, 179), circle(13), color(0, 204, 255))])
										 ,frame([timestamp(779), ground(334, 243, color(255, 255, 255)), figure(1, position(174, 183), circle(13), color(0, 204, 255))])
										 ,endOfFrames
							  			])).
							  
:- compile('test_IntentionAnimationMovingObjectFrames88-107.pro').