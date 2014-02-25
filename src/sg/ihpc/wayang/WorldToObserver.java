// BEGIN LICENSE BLOCK
// Version: CMPL 1.1
//
// The contents of this file are subject to the Cisco-style Mozilla Public
// License Version 1.1 (the "License"); you may not use this file except
// in compliance with the License.  You may obtain a copy of the License
// at www.eclipse-clp.org/license.
// 
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied.  See
// the License for the specific language governing rights and limitations
// under the License. 
// 
// The Original Code is  The ECLiPSe Constraint Logic Programming System. 
// The Initial Developer of the Original Code is  Cisco Systems, Inc. 
// Portions created by the Initial Developer are
// Copyright (C) 2001 - 2006 Cisco Systems, Inc.  All Rights Reserved.
// 
// Contributor(s): Josh Singer, Parc Technologies
// 
// END LICENSE BLOCK

//This file is derived from the following, which was created by Josh Singer:
//Version:      $Id: QueueExample2.java,v 1.1.1.1 2006/09/23 01:54:13 snovello Exp $
package sg.ihpc.wayang;

import java.io.File;
import java.io.IOException;

import com.parctechnologies.eclipse.EclipseEngine;
import com.parctechnologies.eclipse.EclipseEngineOptions;
import com.parctechnologies.eclipse.EclipseException;
import com.parctechnologies.eclipse.Fail;
import com.parctechnologies.eclipse.FromEclipseQueue;
import com.parctechnologies.eclipse.OutOfProcessEclipse;
import com.parctechnologies.eclipse.Throw;
import com.parctechnologies.eclipse.ToEclipseQueue;

public class WorldToObserver {
	
	static EclipseEngineOptions s_oEclipseEngineOptions = new EclipseEngineOptions();
	static EclipseEngine s_oEclipse;

	// Data going out from java
	static ToEclipseQueue s_stJavaToEclipse;
	// Data coming in from eclipse
	static FromEclipseQueue s_stEclipseToJava;
	
	
	public static boolean go(	String sPathToKnowledgeBaseSource,
								String sPathToCLPTestCaseSource,
								String sEntryPredicateInCLPSource,
				  				WorldModel oWorldModel )
	throws EclipseException, IllegalAccessException, IOException
	{
	    //s_oEclipse = EmbeddedEclipse.getInstance(s_oEclipseEngineOptions);
	    s_oEclipse = new OutOfProcessEclipse(s_oEclipseEngineOptions);

	    // Read and compile the part of the Wayang framework code written in ECLiPSe
	    s_oEclipse.compile(new File("src/ECLiPSe/loader.pro"));
	    if (sPathToKnowledgeBaseSource != null) {
		    // Read and compile the knowledge that will be used for reasoning
		    s_oEclipse.compile(new File(sPathToKnowledgeBaseSource));
	    }
	    // Read and compile the test-specific ECLiPSe program that Java will interact with
	    s_oEclipse.compile(new File(sPathToCLPTestCaseSource));
	
	    // Setup a way for Java to provide terms to ECLiPSe whenever ECLiPSe wants one
	    s_stJavaToEclipse = s_oEclipse.getToEclipseQueue("javaToEclipse");
	    s_stJavaToEclipse.setListener(new FrameTermProducer(oWorldModel));
	    
	    // Setup a way for ECLiPSe to pass back a possibly-instantiated version of each term it requested from Java
	    s_stEclipseToJava = s_oEclipse.getFromEclipseQueue("eclipseToJava");
	    s_stEclipseToJava.setListener(new InferredTermConsumer(oWorldModel));
	    
	    System.out.println("Created new OutOfProcessEclipse inference engine");
	
	    /* Pass control to ECLiPSe predicate processFrames/0 (see ObserverToWorld.ecl), which will do the following:
	     * 1. Do any setup it wants to do (i.e., the initialize/0 predicate)
	     * 2. Do the following in a loop:
	     *    a. Request a term from the javaToEclipse queue (which will be fed by FrameTermProducer using WorldModel_SWF)
	     *    b. Check if the term's first arg is "endOfFrames", and if so break out of this loop
	     *    c. Run predicate inferFromTerm/2 on that term, possibly instantiating it in some ways
	     *    d. Put the possibly-updated term on the eclipseToJava queue
	     * 3. Do any tear-down it needs to do after exiting the loop (i.e., the terminate/0 predicate)
	     */
	    boolean bReturnValue = false;
	    try {
	    	s_oEclipse.rpc(sEntryPredicateInCLPSource);
	    	bReturnValue = true;
	    } catch (Fail ex) {
	    	//Presumably, the term containing "endOfFrames" was found at the end of the list and processFrames/0 is exiting normally
	    } catch (Throw ex) {
	    	//An error occurred
	    	ex.printStackTrace();
	    } finally {
		    // Destroy the Eclipse process
		    //((EmbeddedEclipse) s_oEclipse).destroy();
		    ((OutOfProcessEclipse) s_oEclipse).destroy();
		    
		    System.out.println("Destroyed OutOfProcessEclipse inference engine");
	    }
	    return bReturnValue;
	}

}