// Copyright 2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package test.nexus.math
{

import asunit.framework.TestCase;
import nexus.math.LehmerGenerator;

/**
 * ...
 */
public class LehmerGeneratorTest extends AbstractIPRNGTest
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
	
	public function LehmerGeneratorTest(testMethod:String = null)
	{
		super(testMethod);
		
	}
	
	//--------------------------------------
	//	SETUP & TEARDOWN
	//--------------------------------------
	
	override protected function setUp():void
	{
		super.setUp();
		m_algorithm = LehmerGenerator;
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