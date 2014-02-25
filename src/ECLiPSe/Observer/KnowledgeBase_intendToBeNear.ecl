/*
:- addRule(
	intendToBeNear_baseStep,
	<=(	cause(	intend(	ApproacherId,
						isNear(ApproacherId, TargetId),
						ElapsedTime1,ElapsedTime2,
						CF3 ),
				[figureHasTrajectory(	ApproacherId,
										Trajectory1,
										ElapsedTime1,ElapsedTime2,
										CF1,
										originally(Shape1,Color1) )
				]
			),
		[%The approacher and the approached/target must be different objects
		 1:compute( TargetId #\= ApproacherId ),
		 
		 %We will be embedding the 'isNear' expression below in several of the
		 % other conditions in this rule, so for convenience we assign
		 % NearnessCondition1 to it because vars are easier to paste in where
		 % needed.
		 2:compute( NearnessCondition1
					= isNear(obj1(ApproacherId,position(X1,Y1),Shape1),
		 					 obj2(TargetId,Position2,Shape2) )),
		 					 
		 %If the approacher wants to be near the target, then it should aim to
		 % be near where it thinks the target is going to be next (unless the
		 % approacher is currently trapped, in which case we might expect it to
		 % move as close as it can to where it expects the target to be, even if
		 % if has no hope of actually getting near). There are many cases to
		 % consider:
		 % 1. Target is moving away from approacher and without regard for
		 %    approacher;
		 % 2. Target is moving toward approacher but shows no sign of stopping,
		 %    so approacher may need to act to avoid collision;
		 % 3. Target and approacher are moving in parallel;
		 % 4. Approacher believes it's trapped and cannot reach the target;
		 
		 % Note that the approacher might initially view the target as animate
		 %  and aware of the approacher but events might reveal that it's more
		 %  likely that the target isn't aware of it, or that the target isn't 
		 %  even animate. In that case, the approacher's behavior should change
		 %  accordingly. Similarly, the approacher might initially assume the
		 %  opposite, that the target is inanimate, and then find reason to
		 %  doubt that.
		 
		 
		 
		 					 
		 %If the approacher is moving, then for it to have an intent to be
		 % near the target, the target must NOT be nearby. If the approacher
		 % is stationary, then for it to have an intent to be near the target,
		 % the target must be nearby. %//FIXME Note that there are exceptions
		 % not covered here:
		 % 1. An object is barreling toward the approacher and he temporarily
		 %    moves away from the target to avoid being hit; this would violate
		 %    case 2 below.
		 % 2. The target is nearby but moving and it might keep moving. The
		 %    condition below would require the approacher to be stationary in
		 %    this case, but a smarter approacher would try to ascertain if
		 %    the target will stop while nearby and if that seems unlikely then
		 %    the smarter approacher should actually move in this case.
		 %    Another bad rejection is the case where the two are moving in
		 %    parallel while maintaining nearness -- this condition would fail
		 %    to recognize that as possibly intentional.
		 3:compute( (Trajectory1 = linearMovingTrajectory(
									lastPosition(X1,Y1),
									magnitude(XMagn1,YMagn1) ),
					 NearnessCondition = not NearnessCondition1 )
					;
					(Trajectory1 = stationaryTrajectory(
									originalPosition(X1,Y1) ),
					 NearnessCondition = NearnessCondition1 )),
		 
		 %For every other figure (i.e. figures other than ApproacherId), look up
		 % its current trajectory to determine its position and size, and if it's
		 % not already nearby, check if it would be on an intercept course for
		 % the known trajectory of ApproacherId. The target can either be moving
		 % or stationary, but must be on an intercept course for the approacher.
		 %Note that the start time of the target's trajectory doesn't have to be
		 % the same as the start time of the approacher's trajectory.
		 4:figureHasTrajectory(	TargetId,
								Trajectory2,
								ElapsedTime1b,ElapsedTime2,
								CF2,
								originally(Shape2,Color2) ),
		 5:extractPositionFromTrajectory(Trajectory2,Position2),
		 6:compute( NearnessCondition ),
		 7:compute( onInterceptCourse(Shape1,Trajectory1, Shape2,Trajectory2) ),
		 
		 8:compute( combineConfidenceFactors([CF1,CF2],CF3) )
		])).
		
:- addRule(
	intendToBeNear_recursiveStep,
	<=(	cause(	intend(	ApproacherId,
						isNear(ApproacherId, TargetId),
						ElapsedTime1,ElapsedTime3,
						CF4 ),
				[%We require the intent on the first span and the trajectory on
				 % the second span, even though the ordering doesn't matter
				 % conceptually, because doing so prevents this rule from
				 % firing (and prematurely using CPU cycles) until after the
				 % base step rule above yields an initial intent.
				 %
				 intend(ApproacherId,
						isNear(ApproacherId, TargetId),
						ElapsedTime1,ElapsedTime2,
						CF1 ),
				 figureHasTrajectory(	ApproacherId,
									Trajectory1,
									ElapsedTime2,ElapsedTime3,
									CF3,
									originally(Shape1,Color1) )
				]
			),
		[%The approacher and the approached/target must be different objects
		 1:compute( TargetId #\= ApproacherId ),
		 
		 %We will be embedding the 'isNear' expression below in several of the
		 % other conditions in this rule, so for convenience we assign
		 % NearnessCondition1 to it because vars are easier to paste in where
		 % needed.
		 2:compute( NearnessCondition1
					= isNear(obj1(ApproacherId,position(X1,Y1),Shape1),
		 					 obj2(TargetId,Position2,Shape2) )),
		 					 
		 %If the approacher is moving, then for it to have an intent to be
		 % near the target, the target must NOT be nearby. If the approacher
		 % is stationary, then for it to have an intent to be near the target,
		 % the target must be nearby. %//FIXME Note that there are exceptions
		 % not covered here:
		 % 1. An object is barreling toward the approacher and he temporarily
		 %    moves away from the target to avoid being hit;
		 % 2. The target is nearby but moving and it might keep moving. The
		 %    condition below would require the approacher to be stationary in
		 %    this case, but a smarter approacher would try to ascertain if
		 %    the target will stop while nearby and if that seems unlikely then
		 %    the smarter approacher should actually move in this case.
		 %    Another bad rejection is the case where the two are moving in
		 %    parallel while maintaining nearness -- this condition would fail
		 %    to recognize that as possibly intentional.
		 3:compute( (Trajectory1 = linearMovingTrajectory(
									lastPosition(X1,Y1),
									magnitude(XMagn1,YMagn1) ),
					 NearnessCondition = not NearnessCondition1 )
					;
					(Trajectory1 = stationaryTrajectory(
									originalPosition(X1,Y1) ),
					 NearnessCondition = NearnessCondition1 )),
		 
		 %For every other figure (i.e. figures other than ApproacherId), look up
		 % its current trajectory to determine its position and size, and if it's
		 % not already nearby, check if it would be on an intercept course for
		 % the known trajectory of ApproacherId. The target can either be moving
		 % or stationary, but must be on an intercept course for the approacher.
		 %Note that the start time of the target's trajectory doesn't have to be
		 % the same as the start time of the approacher's trajectory.
		 4:figureHasTrajectory(	TargetId,
								Trajectory2,
								ElapsedTime2b,ElapsedTime3,
								CF2,
								originally(Shape2,Color2) ),
		 5:extractPositionFromTrajectory(Trajectory2,Position2),
		 6:compute( NearnessCondition ),
		 7:compute( onInterceptCourse(Shape1,Trajectory1, Shape2,Trajectory2) ),
		 
		 8:compute( combineConfidenceFactors([CF1,CF2,CF3],CF4) )
		])).
*/