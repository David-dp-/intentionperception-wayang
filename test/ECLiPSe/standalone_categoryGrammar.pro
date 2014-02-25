:- dynamic rule/2.

:- assert( rule(np, ['MediCenter']) ).
%:- assert( rule(np, ['John','Brown']) ).
:- assert( rule(np, [nurses]) ).
:- assert( rule(tv, [employed]) ).
:- assert( rule(iv, [died]) ).

:- assert( rule(np, [elephant]) ).
:- assert( rule(np, [pajamas]) ).
:- assert( rule(np, [stripes]) ).
:- assert( rule(prep, [with]) ).
:- assert( rule(prep, [in]) ).

:- assert( rule(s, [np, vp]) ).
:- assert( rule(vp, [iv]) ).
:- assert( rule(vp, [tv, np]) ).

:- assert( rule(np, [np, pp]) ).
:- assert( rule(pp, [prep, np]) ).

:- compile('../../src/ECLiPSe/utils.pro', '../../src/ECLiPSe/Observer/IncrementalParser.ecl').

testParser1 :- setupParserTest(['MediCenter',employed,nurses]).

testParser2 :- setupParserTest([elephant,in,pajamas]).

testParser3 :- setupParserTest([elephant,in,pajamas,with,stripes]).

setupParserTest(InputTokens) :-
	initializeParser,
	(foreach(InputToken,InputTokens) do processToken(InputToken)),
	writeParsingReport.
	
processToken(InputToken) :-
	fetchAndIncrementCurrentSpanEnd(CurrentSpanEnd, NextSpanEnd),
	%writeL(['Work done for input token: ',InputToken]),
	forEachMatchDo(rule(LHS0to2,[InputToken|ExpectedTokens]), 
					addEdge(CurrentSpanEnd, NextSpanEnd, LHS0to2, 1.0, [LHS0to2,InputToken], ExpectedTokens)).

getSomeRule(Rule,someGrammarEntry) :-
	rule(LHS, [RHSHead | RHSTail]),
	Rule = rule(LHS, [RHSHead | RHSTail]).
	
locateRHSHead(Rule, RHSHead) :-
	Rule = rule(_LHS, [RHSHead | _RHSTail]).
	
verifyRule(	Rule, _RHSHeadInst,							%data in
			LHS2, CF2, ExpectedFrameItems) :-		%data out
	Rule = rule(LHS2, [_RHSHead | ExpectedFrameItems]),
	CF2 = 1.0.
	
/* After loading this file and querying 'testParser1', you should see the following:
 *
 *	Work done for input token: MediCenter
 *	 .Added edge(1, 2, np, [MediCenter], [])
 *	 _Added edge(1, 1, s, [s], [np, vp])
 *	 _Added edge(1, 2, s, [[MediCenter], s], [vp])
 *	Work done for input token: employed
 *	 .Added edge(2, 3, tv, [employed], [])
 *	 _Added edge(2, 2, vp, [vp], [tv, np])
 *	 _Added edge(2, 3, vp, [[employed], vp], [np])
 *	Work done for input token: nurses
 *	 .Added edge(3, 4, np, [nurses], [])
 *	 _Added edge(3, 3, s, [s], [np, vp])
 *	 _Added edge(3, 4, s, [[nurses], s], [vp])
 *	 .Added edge(2, 4, vp, [[nurses], [employed], vp], [])
 *	 .Added edge(1, 4, s, [[[nurses], [employed], vp], [MediCenter], s], [])
 *	Parses at the time writeParsingReport/0 was called:
 *	  [[[nurses], [employed], vp], [MediCenter], s]
 *	  [[nurses], [employed], vp]
 *	  [nurses]
 *	  [employed]
 *	  [MediCenter]
 *
 * The parses here don't indicate the part-of-speech (POS) of each word, although Gazdar and Mellish's code did.
 * There is no equivalent to POS in our domain, as far as I can tell, so the parser has been changed so that
 * there is no first step of trying to identify all the possible POS's for an input word.
 */
	
sendSummaryToTestFramework :- true.