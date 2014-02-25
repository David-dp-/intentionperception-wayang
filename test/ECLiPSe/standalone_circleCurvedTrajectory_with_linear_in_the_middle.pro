:- compile(['stubsAndUtilsForStandalone.pro', 'settingsForStandalone.pro', 
	'../../src/ECLiPSe/Observer/KnowledgeBase_curvedTrajectory.ecl']
   ).
   
:- resetStandalone.
							  
:- storedSettings(StoredSettings),
   assert( inputForDebugging( [ settings(StoredSettings)
								,frame([timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(167, 121), circle(26), color(51, 255, 0))])
								,frame([timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(176, 130), circle(26), color(51, 255, 0))])
								,frame([timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(187, 134), circle(26), color(51, 255, 0))])
								,frame([timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(199, 134), circle(26), color(51, 255, 0))])
								,frame([timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(209, 134), circle(26), color(51, 255, 0))])
								,frame([timestamp(205), ground(334, 243, color(255, 255, 255)), figure(1, position(218, 130), circle(26), color(51, 255, 0))])
								,frame([timestamp(246), ground(334, 243, color(255, 255, 255)), figure(1, position(226, 125), circle(26), color(51, 255, 0))])
								,endOfFrames
							  ])).

:- compile('test_circleCurvedTrajectory_with_linear_in_the_middle.pro').