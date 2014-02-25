package sg.ihpc.wayangTest.viz;

import java.io.IOException;
import java.util.Vector;

import javax.swing.JComboBox;

import com.parctechnologies.eclipse.EclipseException;

@SuppressWarnings("serial")
public class VizTestsDropdown extends JComboBox {
	
	private VizWindow _oViz;
	private Vector<VizTestsDropdownItem> _coTestItems
						= new Vector<VizTestsDropdownItem>();
	
	VizTestsDropdown(VizWindow oViz) {
		super();
		
		_oViz = oViz;
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Lone circle moves linearly",
							"src/ECLiPSe/Observer/KnowledgeBase_trajectory.ecl",
							"input/circle15mm_translation.swf",
							"test/ECLiPSe/test_circleTranslation.pro",
							"circleTranslation_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Lone circle moves linearly with noticeable acceleration",
							"src/ECLiPSe/Observer/KnowledgeBase_trajectory.ecl",
							"input/circle15mm_translation_with_noticeable_acceleration.swf",
							"test/ECLiPSe/test_circleTranslation_with_noticeable_acceleration.pro",
							"circleTranslation_with_noticeable_acceleration_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Lone circle moves linearly, with no acceleration, with change of direction",
							"src/ECLiPSe/Observer/KnowledgeBase_trajectory.ecl",
							"input/circle15mm_translation_no_acceleration_change_of_direction.swf",
							"test/ECLiPSe/test_circleTranslation_no_acceleration_with_direction_change.pro",
							"circleTranslation_no_acceleration_with_direction_change_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Imperceptible linear movement of a lone circle",
							"src/ECLiPSe/Observer/KnowledgeBase_trajectory.ecl",
							"input/circle_imperceptible_translation.swf",
							"test/ECLiPSe/test_circle_imperceptible_translation.pro",
							"circle_imperceptible_translation_edgesAreCorrect",
							oViz ));
	
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Circle moves linearly between neighbors",
							"src/ECLiPSe/Observer/KnowledgeBase_trajectory.ecl",
							"input/circle15mm_translation_bookended.swf",
							"test/ECLiPSe/test_bookendedCircleTranslation.pro",
							"bookendedCircleTranslation_edgesAreCorrect",
							oViz ));
	
		_coTestItems.add(
				new VizTestsDropdownItem(
						"Movement attributed to attractive force from neighbor",
						"src/ECLiPSe/Observer/KnowledgeBase_attractiveRepulsive.ecl",
						"input/circle15mm_translation_bookended.swf",
						"test/ECLiPSe/test_attractedOrRepulsed.pro",
						"attractedOrRepulsed_edgesAreCorrect",
						oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
						"Movement attributed to attractive force from neighbor with constantly accelerating object",
						"src/ECLiPSe/Observer/KnowledgeBase_attractiveRepulsive.ecl",
						"input/circle15mm_translation_with_constant_acceleration_with_attractive_circle.swf",
						"test/ECLiPSe/test_attractedOrRepulsed2.pro",
						"attractedOrRepulsed2_edgesAreCorrect",
						oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
						"Movement attributed to repulsive force from neighbor",
						"src/ECLiPSe/Observer/KnowledgeBase_attractiveRepulsive.ecl",
						"input/circle15mm_translation_with_repulsive_circle.swf",
						"test/ECLiPSe/test_repulsed.pro",
						"repulsed_edgesAreCorrect",
						oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
						"Dummy test for multiple triggers",
						"test/ECLiPSe/KnowledgeBase_test.ecl",
						"input/circle15mm_translation.swf",
						"test/ECLiPSe/test_dummyMultipleTriggers.pro",
						"dummyMultipleTriggers_edgesAreCorrect",
						oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
						"Movement attributed to intention to be at a certain position, linear movement",
						"src/ECLiPSe/Observer/KnowledgeBase_intendToBeAtPosition.ecl",
						"input/circle15mm_translation.swf",
						"test/ECLiPSe/test_intendToBeAtPosition.pro",
						"intendToBeAtPosition_edgesAreCorrect",
						oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
						"Movement attributed to intention to be at a certain position, linear followed by stationary movement",
						"src/ECLiPSe/Observer/KnowledgeBase_intendToBeAtPosition.ecl",
						"input/circle15mm_translation_withStopAtTheEnd.swf",
						"test/ECLiPSe/test_intendToBeAtPosition_withStationaryTrajectoryAtTheEnd.pro",
						"intendToBeAtPosition_withStationaryTrajectoryAtTheEnd_edgesAreCorrect",
						oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
						"Movement attributed to intention to be at a certain position, stationary followed by linear movement",
						"src/ECLiPSe/Observer/KnowledgeBase_intendToBeAtPosition.ecl",
						"input/circle15mm_translation_withStopAtTheStart.swf",
						"test/ECLiPSe/test_intendToBeAtPosition_withStationaryTrajectoryAtTheStart.pro",
						"intendToBeAtPosition_withStationaryTrajectoryAtTheStart_edgesAreCorrect",
						oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
						"Movement attributed to intention to approach a neighbor",
						"src/ECLiPSe/Observer/KnowledgeBase_intendToApproachAvoid.ecl",
						"input/circle15mm_translation_bookended.swf",
						"test/ECLiPSe/test_intendToApproachOrAvoid.pro",
						"intendToApproachOrAvoid_edgesAreCorrect",
						oViz ));
				
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Lone circle moves curvilinearly",
							"src/ECLiPSe/Observer/KnowledgeBase_curvedTrajectory.ecl",
							"input/circle15mm_curvedTrajectory.swf",
							"test/ECLiPSe/test_circleCurvedTrajectory.pro",
							"circleCurvedTrajectory_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Lone circle moves curvilinearly with two directions",
							"src/ECLiPSe/Observer/KnowledgeBase_curvedTrajectory.ecl",
							"input/circle15mm_curvedTrajectory_with_two_directions.swf",
							"test/ECLiPSe/test_circleCurvedTrajectory_with_two_directions.pro",
							"circleCurvedTrajectory_with_two_directions_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Lone circle moves curvilinearly with an inflection point",
							"src/ECLiPSe/Observer/KnowledgeBase_curvedTrajectory.ecl",
							"input/circle15mm_curvedTrajectory_with_inflectionPoint.swf",
							"test/ECLiPSe/test_circleCurvedTrajectory_with_inflectionPoint.pro",
							"circleCurvedTrajectory_with_inflectionPoint_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Lone circle moves curvilinearly with a linear portion in the middle",
							"src/ECLiPSe/Observer/KnowledgeBase_curvedTrajectory.ecl",
							"input/circle15mm_curvedTrajectory_with_linear_in_the_middle.swf",
							"test/ECLiPSe/test_circleCurvedTrajectory_with_linear_in_the_middle.pro",
							"circleCurvedTrajectory_with_linear_in_the_middle_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Curved movement attributed to a combination of attractive & repulsive forces from neighbors",
							"src/ECLiPSe/Observer/KnowledgeBase_attractiveRepulsiveCombined.ecl",
							"input/circle15mm_curved_withAttractorRepulsor.swf",
							"test/ECLiPSe/test_attractiveRepulsiveCombined.pro",
							"attractiveRepulsiveCombined_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Curved & linear movement attributed to a combination of attractive & repulsive forces from neighbors",
							"src/ECLiPSe/Observer/KnowledgeBase_attractiveRepulsiveCombined.ecl",
							"input/circle15mm_curved_withAttractorRepulsor_withLinearSegment.swf",
							"test/ECLiPSe/test_attractiveRepulsiveCombined_linearSegment.pro",
							"attractiveRepulsiveCombined_linearSegment_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Curved trajectory with a propeller circle and two neighbors",
							"src/ECLiPSe/Observer/KnowledgeBase_attractiveRepulsiveCombined.ecl",
							"input/circle15mm_curved_withAttractorRepulsor_PropellerCircle.swf",
							"test/ECLiPSe/test_attractiveRepulsiveCombined_PropellerCircle.pro",
							"attractiveRepulsiveCombined_PropellerCircle_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Curved trajectory with two neighbors, invalid attractor location",
							"src/ECLiPSe/Observer/KnowledgeBase_attractiveRepulsiveCombined.ecl",
							"input/circle15mm_curved_withAttractorRepulsor_invalidAttractorLocation.swf",
							"test/ECLiPSe/test_attractiveRepulsiveCombined_invalidAttractorLocation.pro",
							"attractiveRepulsiveCombined_invalidAttractorLocation_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Curved movement attributed to a combination of intention to approach & avoid neighbors",
							"src/ECLiPSe/Observer/KnowledgeBase_intendToApproachAvoidCombined.ecl",
							"input/circle15mm_curved_withAttractorRepulsor.swf",
							"test/ECLiPSe/test_intendToApproachAvoidCombined.pro",
							"intendToApproachAvoidCombined_edgesAreCorrect",
							oViz ));
		
		/*_coTestItems.add(
				new VizTestsDropdownItem(
							"Movement attributed to a change of intention",
							"src/ECLiPSe/Observer/KnowledgeBase_changeOfIntention.ecl",
							"input/circle15mm_translation_withChangeOfDirection.swf",
							"test/ECLiPSe/test_changeOfIntention.pro",
							"changeOfIntention_edgesAreCorrect",
							oViz ));*/
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Wiggle rule on dummy wiggle animation",
							"src/ECLiPSe/Observer/KnowledgeBase_wiggle.ecl",
							"input/circle15mm_dummy_wiggle.swf",
							"test/ECLiPSe/test_dummyWiggle.pro",
							"dummyWiggle_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Wiggle rule on dummy wiggle animation 2",
							"src/ECLiPSe/Observer/KnowledgeBase_wiggle.ecl",
							"input/circle15mm_dummy_wiggle_2.swf",
							"test/ECLiPSe/test_dummyWiggle2.pro",
							"dummyWiggle2_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Wiggle rule on dummy wiggle animation with overlap",
							"src/ECLiPSe/Observer/KnowledgeBase_wiggle.ecl",
							"input/circle15mm_dummy_wiggle_with_overlap.swf",
							"test/ECLiPSe/test_dummyWiggle_with_overlap.pro",
							"dummyWiggle_with_overlap_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Wiggle rule on linear movement part of Intention animation",
							"src/ECLiPSe/Observer/KnowledgeBase_wiggle.ecl",
							"input/Intention_linear_part.swf",
							"test/ECLiPSe/test_wiggleOnLinearPartOfIntentionAnimation.pro",
							"wiggleOnLinearPartOfIntentionAnimation_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Wiggle rule on curved movement part of Intention animation",
							"src/ECLiPSe/Observer/KnowledgeBase_wiggle.ecl",
							"input/Intention_curved_part.swf",
							"test/ECLiPSe/test_wiggleOnCurvedPartOfIntentionAnimation.pro",
							"wiggleOnCurvedPartOfIntentionAnimation_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Noticing",
							"src/ECLiPSe/Observer/KnowledgeBase_notice.ecl",
							"input/circle15mm_translation_withStopAtTheEnd_and_noticedCircle.swf",
							"test/ECLiPSe/test_notice.pro",
							"notice_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Intention to approach augmented with intention to avoid on dummy intention animation",
							"src/ECLiPSe/Observer/KnowledgeBase_intentionToApproachAugmentedWithIntentionToAvoid.ecl",
							"input/circle15mm_dummy_intention.swf",
							"test/ECLiPSe/test_dummyIntentionToApproachAugmentedWithIntentionToAvoid.pro",
							"dummyIntentionToApproachAugmentedWithIntentionToAvoid_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Linear movement part of Intention animation",
							"src/ECLiPSe/Observer/KnowledgeBase_trajectory.ecl",
							"input/Intention_linear_part.swf",
							"test/ECLiPSe/test_intentionAnimation_linearPart.pro",
							"intentionAnimation_linearPart_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Linear movement part of Intention animation, no stationary part, no stationary rules",
							"src/ECLiPSe/Observer/KnowledgeBase_trajectory.ecl", //this test requires stationary rules to be commented out
							"input/Intention_linear_part1.swf",
							"test/ECLiPSe/test_intentionAnimation_linearPart1.pro",
							"intentionAnimation_linearPart1_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Curved movement part of Intention animation with Attractor and Repulsor, multiple rules",
							"src/ECLiPSe/Observer/KnowledgeBaseLoader.pro",
							"input/Intention_curved_part_with_Attractor_Repulsor.swf",
							"test/ECLiPSe/test_intentionAnimation_curvedPart_with_Attractor_Repulsor_multipleRules.pro",
							"intentionAnimation_curvedPart_with_Attractor_Repulsor_multipleRules_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Control animation with trajectory rules",
							"src/ECLiPSe/Observer/KnowledgeBase_trajectory.ecl",
							"input/Control_full_May_2011_without_control_button.swf",
							"test/ECLiPSe/test_controlAnimation.pro",
							"controlAnimation_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Intention animation moving object frames 88-107 with trajectory, wiggle, & intention at position rules",
							"src/ECLiPSe/Observer/KnowledgeBase_trajectory.ecl",
							"input/IntentionAnimationMovingObjectFrames88-107.swf",
							"test/ECLiPSe/test_intentionAnimationMovingObjectFrames88-107.pro",
							"intentionAnimationMovingObjectFrames88to107_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Intention animation with multiple rules",
							"src/ECLiPSe/Observer/KnowledgeBaseLoader.pro",
							"input/Intention_full_May_2011_without_control_button.swf",
							"test/ECLiPSe/test_intentionAnimation_multipleRules.pro",
							"intentionAnimation_multipleRules_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Intention animation with multiple rules, with frame 86 modified",
							"src/ECLiPSe/Observer/KnowledgeBaseLoader.pro",
							"input/Intention_full_May_2011_without_control_button_with_modified_frame86.swf",
							"test/ECLiPSe/test_intentionAnimation_multipleRules_modifiedFrames.pro",
							"intentionAnimation_multipleRules_modifiedFrames_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"First 55 frames of Intention animation with multiple rules",
							"src/ECLiPSe/Observer/KnowledgeBaseLoader.pro",
							"input/Intention_55frames_May_2011_without_control_button.swf",
							"test/ECLiPSe/test_intentionAnimation_55frames_allObjects_multipleRules.pro",
							"intentionAnimation_55frames_allObjects_multipleRules_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Fight minimal",
							"src/ECLiPSe/Observer/KnowledgeBase_trajectory.ecl",
							"input/fight.minimal.nocontrolbutton.swf",
							"test/ECLiPSe/test_fight.pro",
							"fight_edgesAreCorrect",
							oViz ));
		
		_coTestItems.add(
				new VizTestsDropdownItem(
							"Short collision test",
							"src/ECLiPSe/Observer/KnowledgeBase_trajectory.ecl",
							"input/short_collision.swf",
							"test/ECLiPSe/test_short_collision.pro",
							"short_collision_edgesAreCorrect",
							oViz ));
		
		for (VizTestsDropdownItem oItem : _coTestItems) {
			this.addItem(oItem.getDisplayName());
		}
	}
	VizWindow getViz() {
		return _oViz;
	}
	
	void executeTestItem(	int iDropdownPosition ) {
		VizTestsDropdownItem oItem = _coTestItems.elementAt(iDropdownPosition);
		try {
			oItem.execute();
		} catch (EclipseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
