:- compile(['stubsAndUtilsForStandalone.pro', 'settingsForStandalone.pro', 
	'../../src/ECLiPSe/Observer/KnowledgeBase_curvedTrajectory.ecl']
   ).
   
:- resetStandalone.
							  
:- storedSettings(StoredSettings),
   assert( inputForDebugging( [ settings(StoredSettings)
								,frame([timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(167, 121), circle(13), color(0, 204, 255))])
								,frame([timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(176, 130), circle(13), color(0, 204, 255))])
								,frame([timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(188, 134), circle(13), color(0, 204, 255))])
								,frame([timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(200, 130), circle(13), color(0, 204, 255))])
								,frame([timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(209, 121), circle(13), color(0, 204, 255))])
								,frame([timestamp(205), ground(334, 243, color(255, 255, 255)), figure(1, position(214, 113), circle(13), color(0, 204, 255))])
								,frame([timestamp(246), ground(334, 243, color(255, 255, 255)), figure(1, position(229, 107), circle(13), color(0, 204, 255))])
								,frame([timestamp(287), ground(334, 243, color(255, 255, 255)), figure(1, position(245, 111), circle(13), color(0, 204, 255))])
								,frame([timestamp(328), ground(334, 243, color(255, 255, 255)), figure(1, position(257, 122), circle(13), color(0, 204, 255))])
								,endOfFrames
							  ])).

:- compile('test_circleCurvedTrajectory_with_two_directions.pro').