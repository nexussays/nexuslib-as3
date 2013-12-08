// Copyright 2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package test.nexus.math
{

import asunit.framework.TestCase;
import nexus.math.TinyMersenneTwisterGenerator;

/**
 * ...
 */
public class TinyMTGeneratorTest extends AbstractISeededPRNGTest
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function TinyMTGeneratorTest(testMethod:String = null)
	{
		super(testMethod);
		
	}
	
	//--------------------------------------
	//	SETUP & TEARDOWN
	//--------------------------------------
	
	override protected function setUp():void
	{
		m_algorithm = TinyMersenneTwisterGenerator;
		
		super.setUp();
	}
	
	override protected function tearDown():void
	{
		super.tearDown();
	}
	
	//--------------------------------------
	//	TESTS
	//--------------------------------------
}
	
}