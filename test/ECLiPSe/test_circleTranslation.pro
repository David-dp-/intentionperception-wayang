
circleTranslation_edgesAreCorrect :-
	populateEdgeSummariesForVerification(circleTranslation_edgeSummaries),
	
	processFrames.
	

% The canonical set of completed and incomplete edges for the "circle15mm_translation.swf" scenario.
%
circleTranslation_edgeSummaries(
[/*edgeSummary("edge1", [], 1, 1, "list", "completed", "[[timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(121, 70), circle(26), color(255, 0, 0))], 1.0, [[timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(121, 70), circle(26), color(255, 0, 0))]], []]")
,edgeSummary("edge2", ["edge1"], 1, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X2, Y2), magnitude(XMagn, YMagn)), 0, ElapsedTime2, 0.65, originally(circle(26), color(255, 0, 0))), 0.65, [], [[timestamp(0), figure(1, position(121, 70), circle(26), color(255, 0, 0))], [timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge3", ["edge2", "edge1"], 1, 1, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X2, Y2), magnitude(XMagn, YMagn)), 0, ElapsedTime2, 0.65, originally(circle(26), color(255, 0, 0))), 0.65, [[timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(121, 70), circle(26), color(255, 0, 0))]], [[timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge4", ["edge1"], 1, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, stationaryTrajectory(originalPosition(121, 70)), 0, ElapsedTime2, 0.7, originally(circle(26), color(255, 0, 0))), 0.7, [], [[timestamp(0), figure(1, position(121, 70), circle(26), color(255, 0, 0))], [timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge5", ["edge4", "edge1"], 1, 1, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, stationaryTrajectory(originalPosition(121, 70)), 0, ElapsedTime2, 0.7, originally(circle(26), color(255, 0, 0))), 0.7, [[timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(121, 70), circle(26), color(255, 0, 0))]], [[timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge6", [], 2, 2, "list", "completed", "[[timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))], 1.0, [[timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))]], []]")
,edgeSummary("edge7", ["edge6"], 2, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X2, Y2), magnitude(XMagn, YMagn)), 41, ElapsedTime2, 0.65, originally(circle(26), color(255, 0, 0))), 0.65, [], [[timestamp(41), figure(1, position(134, 79), circle(26), color(255, 0, 0))], [timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge8", ["edge7", "edge6"], 2, 2, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X2, Y2), magnitude(XMagn, YMagn)), 41, ElapsedTime2, 0.65, originally(circle(26), color(255, 0, 0))), 0.65, [[timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))]], [[timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge9", ["edge6"], 2, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, stationaryTrajectory(originalPosition(134, 79)), 41, ElapsedTime2, 0.7, originally(circle(26), color(255, 0, 0))), 0.7, [], [[timestamp(41), figure(1, position(134, 79), circle(26), color(255, 0, 0))], [timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge10", ["edge9", "edge6"], 2, 2, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, stationaryTrajectory(originalPosition(134, 79)), 41, ElapsedTime2, 0.7, originally(circle(26), color(255, 0, 0))), 0.7, [[timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))]], [[timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge11", ["edge6", "edge3"], 1, 2, "figureHasTrajectory", "completed", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(134, 79), magnitude(0.317073170731707, 0.219512195121951)), 0, 41, 0.65, originally(circle(26), color(255, 0, 0))), 0.65, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(134, 79), magnitude(0.317073170731707, 0.219512195121951)), 0, 41, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(121, 70), circle(26), color(255, 0, 0))]], [[timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))]]], []]")
,edgeSummary("edge12", ["edge11"], 1, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 0, ElapsedTime3, 0.866666666666667, originally(circle(26), color(255, 0, 0))), 0.866666666666667, [], [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(134, 79), magnitude(0.317073170731707, 0.219512195121951)), 0, 41, 0.65, originally(circle(26), color(255, 0, 0))), [timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge13", ["edge12", "edge11"], 1, 2, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 0, ElapsedTime3, 0.866666666666667, originally(circle(26), color(255, 0, 0))), 0.866666666666667, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(134, 79), magnitude(0.317073170731707, 0.219512195121951)), 0, 41, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(121, 70), circle(26), color(255, 0, 0))]], [[timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))]]], [[timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge14", [], 3, 3, "list", "completed", "[[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))], 1.0, [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]], []]")
,edgeSummary("edge15", ["edge14"], 3, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X2, Y2), magnitude(XMagn, YMagn)), 82, ElapsedTime2, 0.65, originally(circle(26), color(255, 0, 0))), 0.65, [], [[timestamp(82), figure(1, position(147, 87), circle(26), color(255, 0, 0))], [timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge16", ["edge15", "edge14"], 3, 3, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X2, Y2), magnitude(XMagn, YMagn)), 82, ElapsedTime2, 0.65, originally(circle(26), color(255, 0, 0))), 0.65, [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]], [[timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge17", ["edge14"], 3, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, stationaryTrajectory(originalPosition(147, 87)), 82, ElapsedTime2, 0.7, originally(circle(26), color(255, 0, 0))), 0.7, [], [[timestamp(82), figure(1, position(147, 87), circle(26), color(255, 0, 0))], [timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge18", ["edge17", "edge14"], 3, 3, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, stationaryTrajectory(originalPosition(147, 87)), 82, ElapsedTime2, 0.7, originally(circle(26), color(255, 0, 0))), 0.7, [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]], [[timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge19", ["edge14", "edge13"], 1, 3, "figureHasTrajectory", "completed", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(147, 87), magnitude(0.317073170731707, 0.195121951219512)), 0, 82, 0.866666666666667, originally(circle(26), color(255, 0, 0))), 0.866666666666667, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(147, 87), magnitude(0.317073170731707, 0.195121951219512)), 0, 82, 0.866666666666667, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(134, 79), magnitude(0.317073170731707, 0.219512195121951)), 0, 41, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(121, 70), circle(26), color(255, 0, 0))]], [[timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))]]], [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]]], []]")
,edgeSummary("edge20", ["edge19"], 1, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 0, ElapsedTime3, 0.896551724137931, originally(circle(26), color(255, 0, 0))), 0.896551724137931, [], [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(147, 87), magnitude(0.317073170731707, 0.195121951219512)), 0, 82, 0.866666666666667, originally(circle(26), color(255, 0, 0))), [timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge21", ["edge20", "edge19"], 1, 3, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 0, ElapsedTime3, 0.896551724137931, originally(circle(26), color(255, 0, 0))), 0.896551724137931, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(147, 87), magnitude(0.317073170731707, 0.195121951219512)), 0, 82, 0.866666666666667, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(134, 79), magnitude(0.317073170731707, 0.219512195121951)), 0, 41, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(121, 70), circle(26), color(255, 0, 0))]], [[timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))]]], [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]]], [[timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge22", ["edge14", "edge8"], 2, 3, "figureHasTrajectory", "completed", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(147, 87), magnitude(0.317073170731707, 0.195121951219512)), 41, 82, 0.65, originally(circle(26), color(255, 0, 0))), 0.65, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(147, 87), magnitude(0.317073170731707, 0.195121951219512)), 41, 82, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))]], [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]]], []]")
,edgeSummary("edge23", ["edge22"], 2, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 41, ElapsedTime3, 0.866666666666667, originally(circle(26), color(255, 0, 0))), 0.866666666666667, [], [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(147, 87), magnitude(0.317073170731707, 0.195121951219512)), 41, 82, 0.65, originally(circle(26), color(255, 0, 0))), [timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge24", ["edge23", "edge22"], 2, 3, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 41, ElapsedTime3, 0.866666666666667, originally(circle(26), color(255, 0, 0))), 0.866666666666667, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(147, 87), magnitude(0.317073170731707, 0.195121951219512)), 41, 82, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))]], [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]]], [[timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge25", [], 4, 4, "list", "completed", "[[timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))], 1.0, [[timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))]], []]")
,edgeSummary("edge26", ["edge25"], 4, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X2, Y2), magnitude(XMagn, YMagn)), 123, ElapsedTime2, 0.65, originally(circle(26), color(255, 0, 0))), 0.65, [], [[timestamp(123), figure(1, position(160, 96), circle(26), color(255, 0, 0))], [timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge27", ["edge26", "edge25"], 4, 4, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X2, Y2), magnitude(XMagn, YMagn)), 123, ElapsedTime2, 0.65, originally(circle(26), color(255, 0, 0))), 0.65, [[timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))]], [[timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge28", ["edge25"], 4, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, stationaryTrajectory(originalPosition(160, 96)), 123, ElapsedTime2, 0.7, originally(circle(26), color(255, 0, 0))), 0.7, [], [[timestamp(123), figure(1, position(160, 96), circle(26), color(255, 0, 0))], [timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge29", ["edge28", "edge25"], 4, 4, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, stationaryTrajectory(originalPosition(160, 96)), 123, ElapsedTime2, 0.7, originally(circle(26), color(255, 0, 0))), 0.7, [[timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))]], [[timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge30", ["edge25", "edge24"], 2, 4, "figureHasTrajectory", "completed", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(160, 96), magnitude(0.317073170731707, 0.219512195121951)), 41, 123, 0.866666666666667, originally(circle(26), color(255, 0, 0))), 0.866666666666667, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(160, 96), magnitude(0.317073170731707, 0.219512195121951)), 41, 123, 0.866666666666667, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(147, 87), magnitude(0.317073170731707, 0.195121951219512)), 41, 82, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))]], [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]]], [[timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))]]], []]")
,edgeSummary("edge31", ["edge30"], 2, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 41, ElapsedTime3, 0.896551724137931, originally(circle(26), color(255, 0, 0))), 0.896551724137931, [], [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(160, 96), magnitude(0.317073170731707, 0.219512195121951)), 41, 123, 0.866666666666667, originally(circle(26), color(255, 0, 0))), [timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge32", ["edge31", "edge30"], 2, 4, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 41, ElapsedTime3, 0.896551724137931, originally(circle(26), color(255, 0, 0))), 0.896551724137931, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(160, 96), magnitude(0.317073170731707, 0.219512195121951)), 41, 123, 0.866666666666667, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(147, 87), magnitude(0.317073170731707, 0.195121951219512)), 41, 82, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))]], [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]]], [[timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))]]], [[timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge33", ["edge25", "edge21"], 1, 4, "figureHasTrajectory", "completed", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(160, 96), magnitude(0.317073170731707, 0.219512195121951)), 0, 123, 0.896551724137931, originally(circle(26), color(255, 0, 0))), 0.896551724137931, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(160, 96), magnitude(0.317073170731707, 0.219512195121951)), 0, 123, 0.896551724137931, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(147, 87), magnitude(0.317073170731707, 0.195121951219512)), 0, 82, 0.866666666666667, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(134, 79), magnitude(0.317073170731707, 0.219512195121951)), 0, 41, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(121, 70), circle(26), color(255, 0, 0))]], [[timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))]]], [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]]], [[timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))]]], []]")
,edgeSummary("edge34", ["edge33"], 1, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 0, ElapsedTime3, 0.899653979238754, originally(circle(26), color(255, 0, 0))), 0.899653979238754, [], [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(160, 96), magnitude(0.317073170731707, 0.219512195121951)), 0, 123, 0.896551724137931, originally(circle(26), color(255, 0, 0))), [timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge35", ["edge34", "edge33"], 1, 4, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 0, ElapsedTime3, 0.899653979238754, originally(circle(26), color(255, 0, 0))), 0.899653979238754, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(160, 96), magnitude(0.317073170731707, 0.219512195121951)), 0, 123, 0.896551724137931, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(147, 87), magnitude(0.317073170731707, 0.195121951219512)), 0, 82, 0.866666666666667, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(134, 79), magnitude(0.317073170731707, 0.219512195121951)), 0, 41, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(121, 70), circle(26), color(255, 0, 0))]], [[timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))]]], [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]]], [[timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))]]], [[timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge36", ["edge25", "edge16"], 3, 4, "figureHasTrajectory", "completed", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(160, 96), magnitude(0.317073170731707, 0.219512195121951)), 82, 123, 0.65, originally(circle(26), color(255, 0, 0))), 0.65, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(160, 96), magnitude(0.317073170731707, 0.219512195121951)), 82, 123, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]], [[timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))]]], []]")
,edgeSummary("edge37", ["edge36"], 3, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 82, ElapsedTime3, 0.866666666666667, originally(circle(26), color(255, 0, 0))), 0.866666666666667, [], [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(160, 96), magnitude(0.317073170731707, 0.219512195121951)), 82, 123, 0.65, originally(circle(26), color(255, 0, 0))), [timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge38", ["edge37", "edge36"], 3, 4, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 82, ElapsedTime3, 0.866666666666667, originally(circle(26), color(255, 0, 0))), 0.866666666666667, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(160, 96), magnitude(0.317073170731707, 0.219512195121951)), 82, 123, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]], [[timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))]]], [[timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge39", [], 5, 5, "list", "completed", "[[timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(173, 105), circle(26), color(255, 0, 0))], 1.0, [[timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(173, 105), circle(26), color(255, 0, 0))]], []]")
,edgeSummary("edge40", ["edge39"], 5, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X2, Y2), magnitude(XMagn, YMagn)), 164, ElapsedTime2, 0.65, originally(circle(26), color(255, 0, 0))), 0.65, [], [[timestamp(164), figure(1, position(173, 105), circle(26), color(255, 0, 0))], [timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge41", ["edge40", "edge39"], 5, 5, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X2, Y2), magnitude(XMagn, YMagn)), 164, ElapsedTime2, 0.65, originally(circle(26), color(255, 0, 0))), 0.65, [[timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(173, 105), circle(26), color(255, 0, 0))]], [[timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge42", ["edge39"], 5, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, stationaryTrajectory(originalPosition(173, 105)), 164, ElapsedTime2, 0.7, originally(circle(26), color(255, 0, 0))), 0.7, [], [[timestamp(164), figure(1, position(173, 105), circle(26), color(255, 0, 0))], [timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge43", ["edge42", "edge39"], 5, 5, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, stationaryTrajectory(originalPosition(173, 105)), 164, ElapsedTime2, 0.7, originally(circle(26), color(255, 0, 0))), 0.7, [[timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(173, 105), circle(26), color(255, 0, 0))]], [[timestamp(ElapsedTime2), figure(1, position(X2, Y2), Shape2, Color2)]]]")
,edgeSummary("edge44", ["edge39", "edge38"], 3, 5, "figureHasTrajectory", "completed", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(173, 105), magnitude(0.317073170731707, 0.219512195121951)), 82, 164, 0.866666666666667, originally(circle(26), color(255, 0, 0))), 0.866666666666667, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(173, 105), magnitude(0.317073170731707, 0.219512195121951)), 82, 164, 0.866666666666667, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(160, 96), magnitude(0.317073170731707, 0.219512195121951)), 82, 123, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]], [[timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))]]], [[timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(173, 105), circle(26), color(255, 0, 0))]]], []]")
,edgeSummary("edge45", ["edge44"], 3, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 82, ElapsedTime3, 0.896551724137931, originally(circle(26), color(255, 0, 0))), 0.896551724137931, [], [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(173, 105), magnitude(0.317073170731707, 0.219512195121951)), 82, 164, 0.866666666666667, originally(circle(26), color(255, 0, 0))), [timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge46", ["edge45", "edge44"], 3, 5, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 82, ElapsedTime3, 0.896551724137931, originally(circle(26), color(255, 0, 0))), 0.896551724137931, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(173, 105), magnitude(0.317073170731707, 0.219512195121951)), 82, 164, 0.866666666666667, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(160, 96), magnitude(0.317073170731707, 0.219512195121951)), 82, 123, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]], [[timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))]]], [[timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(173, 105), circle(26), color(255, 0, 0))]]], [[timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge47", ["edge39", "edge35"], 1, 5, "figureHasTrajectory", "completed", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(173, 105), magnitude(0.317073170731707, 0.219512195121951)), 0, 164, 0.899653979238754, originally(circle(26), color(255, 0, 0))), 0.899653979238754, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(173, 105), magnitude(0.317073170731707, 0.219512195121951)), 0, 164, 0.899653979238754, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(160, 96), magnitude(0.317073170731707, 0.219512195121951)), 0, 123, 0.896551724137931, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(147, 87), magnitude(0.317073170731707, 0.195121951219512)), 0, 82, 0.866666666666667, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(134, 79), magnitude(0.317073170731707, 0.219512195121951)), 0, 41, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(121, 70), circle(26), color(255, 0, 0))]], [[timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))]]], [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]]], [[timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))]]], [[timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(173, 105), circle(26), color(255, 0, 0))]]], []]")
,edgeSummary("edge48", ["edge47"], 1, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 0, ElapsedTime3, 0.899965385946694, originally(circle(26), color(255, 0, 0))), 0.899965385946694, [], [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(173, 105), magnitude(0.317073170731707, 0.219512195121951)), 0, 164, 0.899653979238754, originally(circle(26), color(255, 0, 0))), [timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge49", ["edge48", "edge47"], 1, 5, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 0, ElapsedTime3, 0.899965385946694, originally(circle(26), color(255, 0, 0))), 0.899965385946694, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(173, 105), magnitude(0.317073170731707, 0.219512195121951)), 0, 164, 0.899653979238754, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(160, 96), magnitude(0.317073170731707, 0.219512195121951)), 0, 123, 0.896551724137931, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(147, 87), magnitude(0.317073170731707, 0.195121951219512)), 0, 82, 0.866666666666667, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(134, 79), magnitude(0.317073170731707, 0.219512195121951)), 0, 41, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(0), ground(334, 243, color(255, 255, 255)), figure(1, position(121, 70), circle(26), color(255, 0, 0))]], [[timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))]]], [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]]], [[timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))]]], [[timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(173, 105), circle(26), color(255, 0, 0))]]], [[timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge50", ["edge39", "edge32"], 2, 5, "figureHasTrajectory", "completed", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(173, 105), magnitude(0.317073170731707, 0.219512195121951)), 41, 164, 0.896551724137931, originally(circle(26), color(255, 0, 0))), 0.896551724137931, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(173, 105), magnitude(0.317073170731707, 0.219512195121951)), 41, 164, 0.896551724137931, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(160, 96), magnitude(0.317073170731707, 0.219512195121951)), 41, 123, 0.866666666666667, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(147, 87), magnitude(0.317073170731707, 0.195121951219512)), 41, 82, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))]], [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]]], [[timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))]]], [[timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(173, 105), circle(26), color(255, 0, 0))]]], []]")
,edgeSummary("edge51", ["edge50"], 2, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 41, ElapsedTime3, 0.899653979238754, originally(circle(26), color(255, 0, 0))), 0.899653979238754, [], [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(173, 105), magnitude(0.317073170731707, 0.219512195121951)), 41, 164, 0.896551724137931, originally(circle(26), color(255, 0, 0))), [timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge52", ["edge51", "edge50"], 2, 5, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 41, ElapsedTime3, 0.899653979238754, originally(circle(26), color(255, 0, 0))), 0.899653979238754, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(173, 105), magnitude(0.317073170731707, 0.219512195121951)), 41, 164, 0.896551724137931, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(160, 96), magnitude(0.317073170731707, 0.219512195121951)), 41, 123, 0.866666666666667, originally(circle(26), color(255, 0, 0))), [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(147, 87), magnitude(0.317073170731707, 0.195121951219512)), 41, 82, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(41), ground(334, 243, color(255, 255, 255)), figure(1, position(134, 79), circle(26), color(255, 0, 0))]], [[timestamp(82), ground(334, 243, color(255, 255, 255)), figure(1, position(147, 87), circle(26), color(255, 0, 0))]]], [[timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))]]], [[timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(173, 105), circle(26), color(255, 0, 0))]]], [[timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge53", ["edge39", "edge27"], 4, 5, "figureHasTrajectory", "completed", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(173, 105), magnitude(0.317073170731707, 0.219512195121951)), 123, 164, 0.65, originally(circle(26), color(255, 0, 0))), 0.65, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(173, 105), magnitude(0.317073170731707, 0.219512195121951)), 123, 164, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))]], [[timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(173, 105), circle(26), color(255, 0, 0))]]], []]")
,edgeSummary("edge54", ["edge53"], 4, spanEndForABottomUpRuleEdge, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 123, ElapsedTime3, 0.866666666666667, originally(circle(26), color(255, 0, 0))), 0.866666666666667, [], [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(173, 105), magnitude(0.317073170731707, 0.219512195121951)), 123, 164, 0.65, originally(circle(26), color(255, 0, 0))), [timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")
,edgeSummary("edge55", ["edge54", "edge53"], 4, 5, "figureHasTrajectory", "incomplete", "[figureHasTrajectory(1, linearMovingTrajectory(lastPosition(X3, Y3), magnitude(XMagn2, YMagn2)), 123, ElapsedTime3, 0.866666666666667, originally(circle(26), color(255, 0, 0))), 0.866666666666667, [figureHasTrajectory(1, linearMovingTrajectory(lastPosition(173, 105), magnitude(0.317073170731707, 0.219512195121951)), 123, 164, 0.65, originally(circle(26), color(255, 0, 0))), [[timestamp(123), ground(334, 243, color(255, 255, 255)), figure(1, position(160, 96), circle(26), color(255, 0, 0))]], [[timestamp(164), ground(334, 243, color(255, 255, 255)), figure(1, position(173, 105), circle(26), color(255, 0, 0))]]], [[timestamp(ElapsedTime3), figure(1, position(X3, Y3), Shape3, Color3)]]]")*/
]).