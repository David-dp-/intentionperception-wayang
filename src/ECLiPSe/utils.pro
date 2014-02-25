:- dynamic edgeSummariesForVerification/1.
:- dynamic lastGensym/1.
:- dynamic traceParser/0. %Used to turn debug tracing on and off for writers that monitor this assertion pred.

% We use several stacks - a stack of figure matches, one of figure mismatches (expectation failures), a few others,
% and finally one for the 'inferred' statements that we put on the output queue. All stacks have the same number
% of members by the time we push onto the output queue, because we push one item, usually a list, onto each stack
% for each input frame.
%
pushOntoStack(NewTop, StackPredicate) :-
	( (CurrentStackTerm =.. [StackPredicate, OldStack],
	   retract(CurrentStackTerm) )
	 ; OldStack = []),
	NewStackTerm =.. [StackPredicate, [NewTop|OldStack]],
	assert(NewStackTerm).
	
popFromStack(OldTop, StackPredicate) :-
	CurrentStackTerm =.. [StackPredicate, [OldTop|OldTail]],!,
	retract(CurrentStackTerm),
	NewStackTerm =.. [StackPredicate, OldTail],
	assert(NewStackTerm),!.
	
peekAtStack(CurrentTop, StackPredicate) :-
	CurrentStackTerm =.. [StackPredicate, [CurrentTop|_CurrentTail]],!,
	call(CurrentStackTerm),!.

%DOC
% Similar to Lisp's gensym() in that it creates new id's, but unlike gensym there is no check first to
% ensure the new id isn't already in use
%
newEdgeId(NewId) :-
	(retract(lastGensym(Count)) ; Count is 1),
	sprintf(NewIdAsString, "edge%d", [Count]),
	atom_string(NewId, NewIdAsString),
	Count2 is Count + 1,
	assert(lastGensym(Count2)).
	
resetEdgeIds :- retractall( lastGensym(_) ). %FWIW, there should be only one match
	
%DOC
% Similar to subset/2, but we allow the 1st and 2nd args to be vars or terms containing vars,
% and we want to find all the ways that the 1st arg items can be a subset of 2nd arg items.
%
%  findAllCovers([t(X),f(Y)], [t(0),f(a),f(b)], Covers), Covers = [[t(0), f(a)], [t(0), f(b)]]
%	findAllCovers(dummyEffect1(X,Y),[dummyEffect1(a,b),dummyEffect2(c,d)], Covers), Covers = [[dummyEffect1(a,b)]]
%
% findAllCovers will give a cover containing vars when 1st arg doesn't contain 
% vars & 2nd arg contains vars:
%  findAllCovers([f(1)], [f(B)], [[f(B)]]).
% This behavior is inherited from findAllCovers1. In Wayang, normally 
% findAllCovers will be called with no vars in the second arg.
% This is because the 2nd arg is the LHS of an inactive edge. Hence this behavior 
% should not be an issue.
%//TODO When there are no covers, return [] instead of failing

findAllCovers(TemplateItems, GroundItems, Covers) :-
	findAllCovers1(TemplateItems, GroundItems, [], Covers1),
	(foreach(Cover1,Covers1),foreach(Cover,Covers) do Cover1 = [Cover|_LeftoverGrounds]).

%DOC
% findAllCovers1 will give a cover containing vars when 1st arg doesn't contain 
% vars & 2nd arg contains vars:
%   findAllCovers1([f(1)], [f(B), g(1), f(2), g(2), f(3), f(4)], [],[[[f(B)], g(1), f(2), g(2), f(3), f(4)]]).	
%
findAllCovers1(_TemplateItems, [], _SkippedGrounds, []) :- !.
findAllCovers1([], _GroundItems, _SkippedGrounds, []).
findAllCovers1(TemplateItem, TemplateItem, [], [[TemplateItem]]) :-
	TemplateItem \= [_|_].

findAllCovers1(TemplateItem, [GroundHead|GroundTail], SkippedGrounds, Covers) :-
	TemplateItem \= [_|_],
	findAllCovers1([TemplateItem], [GroundHead|GroundTail], SkippedGrounds, Covers1),
	removeEncasingListFromCoverHeads(Covers1,Covers).

findAllCovers1([TemplateItem], [GroundHead|GroundTail], SkippedGrounds, [[[GroundHead]|LeftoverGrounds]|Covers]) :-
	copy_term(TemplateItem, TItem),
	copy_term(GroundHead, GHead),
	%((TItem = GHead) -> V=true; V=false), condPrintf(traceParser,"\nFAC1 unifiable? %w: %w = %w\n  Leftovers: %w\n", [V, TItem, GHead, append(SkippedGrounds, GroundTail, LeftoverGrounds)]), %//DEBUG
	TItem = GHead,!,
	append(SkippedGrounds, GroundTail, LeftoverGrounds),
	findAllCovers1([TemplateItem], GroundTail, [GroundHead|SkippedGrounds], Covers).
findAllCovers1([TemplateItem], [GroundHead|GroundTail], SkippedGrounds, Covers) :-
	findAllCovers1([TemplateItem], GroundTail, [GroundHead|SkippedGrounds], Covers).
% Previously the signature was:
%   findAllCovers1([TemplateHead1|TemplateTail], [GroundHead|GroundTail], SkippedGrounds, Covers)
% This can cause an infinite loop of choicepoints due to a single member list 
% matching this pattern as well. E.g. findAllCovers1([f(A)],[g(1)],[],Covers) 
% will succeed via the 2nd last clause but will leave a choicepoint due to
% the last clause. The last clause will get instantiated into 
% findAllCovers([f(A)|[]],[g(1)|[]],[],Covers) and will spawn a new set of 
% choicepoints when it calls findAllCovers1 again in the body.
% 
findAllCovers1([TemplateHead1,TemplateHead2|TemplateTail], [GroundHead|GroundTail], SkippedGrounds, Covers) :-
	findAllCovers1([TemplateHead1], [GroundHead|GroundTail], SkippedGrounds, Covers1),
	findAllCovers2(Covers1, [TemplateHead2|TemplateTail], Covers).
	
%DOC
% findAllCovers2([[[t(0)], f(a), f(b)]], [f(Y)], Covers), Covers = [[[t(0), f(a)], f(b)], [[t(0), f(b)], f(a)]]
%
findAllCovers2([], _TemplateTail, []).
findAllCovers2([[[GHead]|LeftoverGrounds]|CoversTailIn], TemplateTail, Covers) :-
	findAllCovers1(TemplateTail, LeftoverGrounds, [], Covers2),
	findAllCovers3(Covers2, GHead, Covers3),
	findAllCovers2(CoversTailIn, TemplateTail, Covers4),
	append(Covers3, Covers4, Covers).
	
%DOC
% findAllCovers3([[[f(a)], f(b)], [[f(b)], f(a)]], t(0), Covers), Covers = [[[t(0), f(a)], f(b)], [[t(0), f(b)], f(a)]]
%
findAllCovers3([], _GroundItem, []).
findAllCovers3([[[GHead1|GTail1]|LeftoverGrounds]|CoversTailIn], GroundItem, [[[GroundItem|[GHead1|GTail1]]|LeftoverGrounds2]|Covers2]) :-
	(memberChkRemainder(GroundItem, LeftoverGrounds, LeftoverGrounds2)
	 ; LeftoverGrounds2 = LeftoverGrounds ),
	findAllCovers3(CoversTailIn, GroundItem, Covers2).
	
%DOC
% memberChkRemainder(b, [a,b,c], [a, c])
%
memberChkRemainder(X, [X|ListWithoutX], ListWithoutX) :- !.
memberChkRemainder(X, [Y|ListTail], [Y|ListTailWithoutX]) :-
	memberChkRemainder(X, ListTail, ListTailWithoutX).

%DOC
% memberChkRemainder1 is just like memberChkRemainder, but without the cut.
% Used by bindCovererUsingCovered1/2. memberChkRemainder1 allows alternative
% solutions in case there's more than 1 occurences of the element to filter out
% from the list.
%
memberChkRemainder1(X, [X|ListWithoutX], ListWithoutX).
memberChkRemainder1(X, [Y|ListTail], [Y|ListTailWithoutX]) :-
	memberChkRemainder1(X, ListTail, ListTailWithoutX).
	
%DOC
% removeEncasingListFromCoverHeads( [[[f(2)],g(1)],[[f(3)],g(1),f(2)]] , [[f(2),g(1)],[f(3),g(1),f(2)]] ).
% This predicate is meant to be used by the special case of findAllCovers1 
% handled by the following clause:
%   findAllCovers1(TemplateItem, [GroundHead|GroundTail], SkippedGrounds, Covers)
% This handles the special case of findAllCovers in which we check a single, 
% non-list term against a list. This special case is needed when checking
% a single effect against a list of multiple triggers. We remove the extra
% enclosing list that will cause unification failure later on.
removeEncasingListFromCoverHeads([],[]).
removeEncasingListFromCoverHeads([Head|Tail],[[Head1|Tail1]|Tail2]) :-
	Head = [[Head1]|Tail1],
	removeEncasingListFromCoverHeads(Tail,Tail2).
	 
%DOC
% Tests whether Coverer is a subset of Covered, regardless of whether the elements are in the same order,
%  and where "same" means "unifiable while conforming to constraints".
%
% Warning: May not work if either argument contains variables or sublists
%
covers(Coverer, Covered) :-
	condPrintf(traceParser," >>covers? %w\n           %w\n", [Coverer, Covered]),
	((listp(Coverer), listp(Covered))
	 -> bindCovererUsingCovered(Coverer, Covered)
	 ;  ((not(listp(Coverer)), listp(Covered))
	 	  -> covers([Coverer],Covered)
	 	  ;  covers([Coverer], [Covered]) 
	    )
	).


%DOC
%Ensure that there is a non-empty intersection between Coverer and Covered
% (unless both are empty), and that everything in the Coverer list can be bound
% to something in the Covered list (although the converse need not be true).
% In the process, bind Coverer as much as possible by using Covered values.
bindCovererUsingCovered([], []).
bindCovererUsingCovered([Head|Tail], L2) :-
	bindCovererUsingCovered1([Head|Tail], L2).
bindCovererUsingCovered1([], _).
bindCovererUsingCovered1([Head|Tail], L2) :-
	memberChkRemainder1(Head, L2, L2Remainder),
	bindCovererUsingCovered1(Tail, L2Remainder).
/*		 
bindCovererUsingCovered([], [], []).
bindCovererUsingCovered([Head|Tail], L2, [Head|BoundTail]) :-
	memberChkRemainder(Head, L2, L2Remainder),
	!,bindCovererUsingCovered(Tail, L2Remainder, BoundTail).
*/	 
listp(Item) :-
	Item = [] ; Item = [_|_].
	 

writeOneElementPerLine([Head|Tail]) :-
	writeOneElementPerLine1(Head),
	writeOneElementPerLine(Tail).
writeOneElementPerLine(Term) :-
	writeOneElementPerLine1(Term).
writeOneElementPerLine1(Term) :-
	type_of(Term,Type),
	writeL(['writeOEPL ',Type,': ',Term]).
	
writeArgsOnePerLine(OutputTerm) :-
	OutputTerm =.. [Pred|ArgList],
	writeL(['writeAOPL pred: ',Pred]),
	writeOneElementPerLine(ArgList).
writeArgsOnePerLine(_OutputTerm).

removeDuplicates([],[]).
removeDuplicates([Head|Tail],ListWithNoDupes) :-
	removeDuplicates(Tail, TailWithNoDupes),
	(memberchk(Head, TailWithNoDupes)
	 -> ListWithNoDupes = TailWithNoDupes
	 ; ListWithNoDupes = [Head|TailWithNoDupes] ).

%DOC
% The built-in unification doesn't recognize when two floats or doubles have the same displayed digits. This means
% that if one wants to use unification to check if two compound terms are identical, it may give a false negative
% if there's a chance that the terms contain floats or doubles.
% This method supports such comparisons by allowing the user to indicate how many digits are significant for the
% comparison.
%
unifyUsingNumberPrecision(X,Y,NumSignificantDigitsAfterDecimal) :-
	%If both X and Y are non-natural numbers, then normalize them to an
	% equivalent natural number form of the indicated precision so they can
	% be unified (i.e., in this case, tested for identity).
	((number(X), not integer(X), number(Y), not integer(Y))
	 -> (alteredPrecisionToInt(X,NumSignificantDigitsAfterDecimal,NormResult),
	     alteredPrecisionToInt(Y,NumSignificantDigitsAfterDecimal,NormResult) )
	     
	 ;  %Else, simulate the built-in unification predicate =/2, but if X or Y
	    % is a list or compound, make sure any non-natural number subparts can
	    % be compared using the indicated precision.
		((var(X) ; var(Y))
		 -> X = Y
		 ;  (integer(X)
			 -> unify1(integer, ==, X,Y)
			 ;  (string(X)
				 -> unify1(string, ==, X,Y)
				 ;  (atom(X)
					 -> unify1(atom, =, X,Y)
					 ;  (X = [XH|XT]
						 -> (Y = [YH|YT]
							 -> unifyUsingNumberPrecision(XH,YH,NumSignificantDigitsAfterDecimal),
							 	unifyUsingNumberPrecision(XT,YT,NumSignificantDigitsAfterDecimal)
							 ;  !,fail
							)
						 ;  (X =.. [XPred|XArgs] %X is a compound
							 -> (Y =.. [YPred|YArgs] %Y is a compound
								 -> (unifyUsingNumberPrecision(XPred,YPred,NumSignificantDigitsAfterDecimal),
									 unifyUsingNumberPrecision(XArgs,YArgs,NumSignificantDigitsAfterDecimal)
									)
								 ;  !,fail
								)
							 ;  type_of(X,Type),condPrintf(traceParser,"META: Need to define case for type|%w| which applies to 1st arg element: %w\n", [Type,X]),
							 	!,fail
							)
						)
					)
				)
			)
		)
	).

%DOC Helper predicates for unifyUsingNumberPrecision/3
unify1(Type,Pred,X,Y) :-
	type_of(Y, Type),
 	Goal =.. [Pred,X,Y],
 	!,call(Goal).
unify1(Type,Pred,Y,X2,Y2) :-
	type_of(Y, Type),
 	Goal =.. [Pred,X2,Y2],
 	!,call(Goal).
 	 
%DOC
% If X is a float, then NumSignificantDigitsAfterDecimal can be used to indicate how many digits are significant,
% and it sets X2 to an integer having those ordered digits. So, this pred can be used as part of comparing if
% two floats are the same, by first converting both to integers with the right ordered digits.
%
alteredPrecisionToInt(X,NumSignificantDigitsAfterDecimal,X2) :-
	^(10,NumSignificantDigitsAfterDecimal,TenPowered),
	X3 is X * TenPowered,
	floor(X3, X4),
	integer(X4, X2).

%DOC
% Finds the first element of the first list that doesn't appear in the second list, and puts it in the last parameter.
% The third parameter helps with lists that may contain floats.
% 	 
findFirstMissingUsingFloatPrecision([], _L2, _NumSignificantDigitsAfterDecimal, []).
findFirstMissingUsingFloatPrecision([Head|Tail], L2, NumSignificantDigitsAfterDecimal, L3) :-
        memberchkUsingFloatPrecision(Head, L2, NumSignificantDigitsAfterDecimal),
        !,
        findFirstMissingUsingFloatPrecision(Tail, L2, NumSignificantDigitsAfterDecimal, L3).
findFirstMissingUsingFloatPrecision([Head|_Tail], _L2, _NumSignificantDigitsAfterDecimal, Head).

%DOC
% Finds all elements in the first list that don't appear in the second list, and puts them in the last parameter.
% The third parameter helps with lists that may contain floats.
% 	 
subtractListUsingFloatPrecision([], _L2, _NumSignificantDigitsAfterDecimal, []).
subtractListUsingFloatPrecision([Head|Tail], L2, NumSignificantDigitsAfterDecimal, L3) :-
        memberchkUsingFloatPrecision(Head, L2, NumSignificantDigitsAfterDecimal),
        !,
        subtractListUsingFloatPrecision(Tail, L2, NumSignificantDigitsAfterDecimal, L3).
subtractListUsingFloatPrecision([Head|Tail1], L2, NumSignificantDigitsAfterDecimal, [Head|Tail3]) :-
		writeL(['SD no match for ',Head]),
        subtractListUsingFloatPrecision(Tail1, L2, NumSignificantDigitsAfterDecimal, Tail3).
        
%DOC
% Just like built-in memberchk, but the third parameter helps with lists that may contain floats.
% 	 
memberchkUsingFloatPrecision(X,[Y|_],NumSignificantDigitsAfterDecimal) :-
	unifyUsingNumberPrecision(X,Y,NumSignificantDigitsAfterDecimal).
memberchkUsingFloatPrecision(X,[Y|T],NumSignificantDigitsAfterDecimal):-
	(memberchkUsingFloatPrecision(X,T,NumSignificantDigitsAfterDecimal)
	 -> true
	 ;  writeL([' MD failed with ',Y]),
	 	showWhereTheyFailToUnify(X,Y," "),
	    fail ).
	 	 
showWhereTheyFailToUnify(X,Y,ParentIndent) :-
	concat_string([ParentIndent," "], Indent),
	(type_of(X, integer)
	 -> showIfTheyFailToUnify(integer, ==, X,Y,Indent)
	 ;  (type_of(X, float)
		 -> showIfTheyFailToUnify(float, ==, X,Y,Indent)
		 ;  (type_of(X, double)
			 -> showIfTheyFailToUnify(double, ==, X,Y,Indent)
			 ;  (type_of(X, string)
				 -> showIfTheyFailToUnify(string, ==, X,Y,Indent)
				 ;  (type_of(X, atom)
					 -> showIfTheyFailToUnify(atom, =, X,Y,Indent)
					 ;  (X = [XH|XT]
						 -> (Y = [YH|YT]
							 -> (showWhereTheyFailToUnify(XH,YH,Indent) ; showWhereTheyFailToUnify(XT,YT,Indent))
							 ;  condPrintf(traceParser,"%w1st arg is a nonempty list, %w, but 2nd arg isnt: %w\n", [Indent,X,Y])
							)
						 ;  (type_of(X, compound)
							 -> (type_of(Y, compound)
								 -> (X =.. [XPred|XArgs],
									 Y =.. [YPred|YArgs],
									 (showWhereTheyFailToUnify(XPred,YPred,Indent) ; showWhereTheyFailToUnify(XArgs,YArgs,Indent))
									)
								 ;  condPrintf(traceParser,"%w1st arg is a compound, %w, but 2nd arg isnt: %w\n", [Indent,X,Y])
								)
							 ;  type_of(X,Type),condPrintf(traceParser,"%wMETA: Need to define case for type|%w| which applies to 1st arg element: %w\n", [Indent,Type,X])
							)
						)
					)
				)
			)
		)
	).
	    
/* We return true from this pred only if we find a point where unification fails.
 */
showIfTheyFailToUnify(Type,Pred,X,Y,Indent) :-
	ground(Type),
	(type_of(Y, Type)
 	 -> ((Goal =.. [Pred,X,Y], call(Goal), !, fail)
 	 	 ; condPrintf(traceParser,"%wThese %ws arent %w |%w| and |%w|\n", [Indent,Type,Pred,X,Y])
 	 	)
 	 ;	condPrintf(traceParser,"%w1st arg is a %w, %w, but 2nd arg isnt: %w\n", [Indent,Type,X,Y])
 	).