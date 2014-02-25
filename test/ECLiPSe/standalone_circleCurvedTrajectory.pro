:- compile(['stubsAndUtilsForStandalone.pro', 'settingsForStandalone.pro',
	'../../src/ECLiPSe/Observer/KnowledgeBase_curvedTrajectory.ecl']
   ).
   
:- resetStandalone.
							  
:- storedSettings(StoredSettings),
   assert( inputForDebugging( [ settings(StoredSettings)
								,frame([timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(167, 121), circle(13), color(51, 255, 0))])
								,frame([timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(176, 130), circle(13), color(51, 255, 0))])
								,frame([timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(188, 134), circle(13), color(51, 255, 0))])
								,frame([timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(200, 130), circle(13), color(51, 255, 0))])
								,frame([timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(209, 121), circle(13), color(51, 255, 0))])
								,endOfFrames
							  ])).

:- compile('test_circleCurvedTrajectory.pro').