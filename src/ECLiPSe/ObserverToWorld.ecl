%%
%% ObserverToWorld.ecl, part of the Wayang project of cogsys.ihpc.a-star.edu.sg
%%

/* Because these methods use read_exdr/2 and write_exdr/2, which refer to queues created by our Java code,
 * they cannot be run in CLP as a standalone app. So, we isolate them here so that we can debug the CLP
 * code using stubs for these in a CLP debugger.
 */
 
readTerm(InputTerm) :-
	read_exdr(javaToEclipse, InputTerm).
	
writeTerm(OutputTerm,CompletionStatus) :-
	setting(loggingLevel(LoggingLevel)),
	((LoggingLevel = "performanceData"
	 ;
	  LoggingLevel = "completedEdges",
	  CompletionStatus = incomplete
	 ),
	 OutputTerm \= mismatch(_,_),
	 OutputTerm \= sawEndOfFrames
	 ->
		OutputString = ""
	;
		term_string(OutputTerm,OutputString1),
		append_strings("TERM OUT: ",OutputString1,OutputString2),
		append_strings(OutputString2,"\n",OutputString)
	),
	writeLog(OutputString),
	%write('TERM OUT: '),myTermToString1(OutputTerm,OutputTerm1),writeln(OutputTerm1), %//DEBUG
	write_exdr(eclipseToJava, OutputTerm),
	flush(eclipseToJava).
	
writeInput(CurrentSpanEnd,frame(FrameItems)) :-
	setting(loggingLevel(LoggingLevel)),
	(LoggingLevel = "performanceData" ->
		figureCounter(frame(FrameItems),TotalFigures),
		term_string(TotalFigures,TotalFiguresString),
		term_string(CurrentSpanEnd,CurrentSpanEndString),
		append_strings(CurrentSpanEndString,",",OutputString1),
		append_strings(OutputString1,TotalFiguresString,OutputString2),
		append_strings(OutputString2,",",OutputString)
	;
		term_string(frame(FrameItems),FrameString),
		append_strings("TERM IN: ",FrameString,OutputString1),
		append_strings(OutputString1,"\n",OutputString)	
	),
	writeLog(OutputString).

writeRowCloserString :-
	setting(loggingLevel(LoggingLevel)),
	(LoggingLevel = "performanceData" ->
		totalIncompleteEdges(TotalIncompleteEdges),
		totalCompletedEdges(TotalCompletedEdges),
		term_string(TotalIncompleteEdges,TotalIncompleteEdgesString),
		term_string(TotalCompletedEdges,TotalCompletedEdgesString),
		append_strings(TotalIncompleteEdgesString,",",TotalIncompleteEdgesStringWithComma),
		append_strings(TotalCompletedEdgesString,",",TotalCompletedEdgesStringWithComma),
		StatisticsKeywords = [session_time,shared_heap_allocated,shared_heap_used,control_stack_allocated,
				control_stack_used,control_stack_peak,private_heap_allocated,private_heap_used,global_stack_allocated,
				global_stack_used,global_stack_peak,local_stack_allocated,local_stack_used,local_stack_peak,
				trail_stack_allocated,trail_stack_used,trail_stack_peak],
		writeStatisticsValues(StatisticsKeywords,StatisticsValueStrings),
		append_strings(TotalIncompleteEdgesStringWithComma,TotalCompletedEdgesStringWithComma,RowCloserString1),
		append_strings(RowCloserString1,StatisticsValueStrings,RowCloserString2),
		append_strings(RowCloserString2,"\n",RowCloserString)
	;
		RowCloserString = ""
	),
	writeLog(RowCloserString).

writeStatisticsValues([LastKeyword],ValueString) :-
	statistics(LastKeyword,Value),
	term_string(Value,ValueString),
	!.
writeStatisticsValues([Keyword|Keywords],ValueStrings) :-
	statistics(Keyword,Value),
	term_string(Value,ValueString),
	append_strings(ValueString,",",ValueStringWithComma),
	writeStatisticsValues(Keywords,ValueStrings1),
	append_strings(ValueStringWithComma,ValueStrings1,ValueStrings).

writeLog(LogMessage) :-
	setting(loggingMethod(LoggingMethod)),
	((LoggingMethod = "consoleAndLogfile" ; LoggingMethod = "logfileOnly") ->
		write(outputLog,LogMessage),
		flush(outputLog),
		(LoggingMethod = "consoleAndLogfile" ->
			write(LogMessage),
			flush(stdout)
		;
			true
		)
	;
		write(LogMessage),
		flush(stdout)
	).
	
writeLogHeader :-
	setting(loggingMethod(LoggingMethod)),
	setting(loggingLevel(LoggingLevel)),
	((LoggingMethod = "consoleAndLogfile" ; LoggingMethod = "logfileOnly") ->
		get_flag(unix_time, T), local_time_string(T, "%c", S),
		get_flag(hostname,Hostname),
		append_strings("#Logged on ", S, LogHeaderString1),
		append_strings(LogHeaderString1, " on ", LogHeaderString2),
		append_strings(LogHeaderString2, Hostname, LogHeaderString),
		writeln(outputLog,LogHeaderString),
		(LoggingLevel = "performanceData" ->
			writeln(outputLog,
			 "Input frame number, Count of figures perceptible, Count of incomplete edges, Count of complete edges, Seconds since CLP instance spawned, Shared heap allocated(bytes), Shared heap used, Control stack allocated, Control stack used, Control stack peak, Private heap allocated, Private heap used, Global stack allocated, Global stack used, Global stack peak, Local stack allocated, Local stack used, Local stack peak, Trail stack allocated, Trail stack used, Trail stack peak")
		;
			true
		)
	;
		true
	).	
	
myTermToString1([Head|Tail],[HeadAsString|TailAsString]) :-
	myTermToString1(Head,HeadAsString),
	myTermToString1(Tail,TailAsString).	
myTermToString1(Term,String) :-
	string(Term),
	sprintf(String,"\"%w\"",[Term]).
myTermToString1([],[]). %Surprisingly, [] ==.. [Pred|Args] succeeds, so we have to add this fact here
myTermToString1(Term,String) :-
	Term =.. [Pred|Args],
	myTermToString1(Args,ArgsAsStrings),
	Term1 =.. [Pred|ArgsAsStrings],
	sprintf(String,"%w",[Term1]).
myTermToString1(Term,String) :-
	sprintf(String,"%w",[Term]).
