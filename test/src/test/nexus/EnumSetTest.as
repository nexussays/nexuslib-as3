// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package test.nexus
{

import asunit.framework.TestCase;
import mock.*;
import nexus.*;

/**
 * ...
 */
public class EnumSetTest extends TestCase
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
	
	public function EnumSetTest(testMethod:String = null)
	{
		super(testMethod);
	}
	
	//--------------------------------------
	//	SETUP & TEARDOWN
	//--------------------------------------
	
	override protected function setUp():void
	{
		
	}
	
	override protected function tearDown():void
	{
		
	}
	
	//--------------------------------------
	//	TESTS
	//--------------------------------------
	
	public function test_intersects():void
	{
		assertTrue(MockEnum.All.intersects(MockEnum.Value1));
		assertTrue(MockEnum.All.intersects(MockEnum.Value2));
		assertTrue(MockEnum.All.intersects(MockEnum.Value3));
		
		assertTrue(MockEnum.All.intersects([MockEnum.Value1, MockEnum.Value2]));
		assertTrue(MockEnum.All.intersects([MockEnum.Value1, MockEnum.Value3]));
		assertTrue(MockEnum.All.intersects([MockEnum.Value2, MockEnum.Value3]));
		
		assertTrue(MockEnum.All.intersects([MockEnum.Value1, MockEnum.Value2, MockEnum.Value3]));
		
		assertFalse(MockEnum.All.intersects(MockEnum2.Value1));
		
		assertTrue(MockEnum.All.intersects(MockEnum.All));
		assertTrue(MockEnum.All.intersects(Enum.values(MockEnum)));
		
		assertTrue(MockEnum.All.intersects(MockEnum.Value2));
		assertTrue(MockEnum.All.intersects([MockEnum.Value2]));
		assertTrue(MockEnum.All.intersects(EnumSet.fromArray([MockEnum.Value2])));
		//assertTrue(MockEnum.All.intersects(new <MockEnum>[MockEnum.Value2]));
		
		assertTrue(EnumSet.fromArgs(MockEnum.Value1, MockEnum2.Value1).intersects(EnumSet.fromArray([MockEnum.Value1, MockEnum2.Value1])));
		assertTrue(EnumSet.fromArgs(MockEnum.Value1, MockEnum2.Value1).intersects(EnumSet.fromArray([MockEnum.Value1])));
		assertTrue(EnumSet.fromArgs(MockEnum2.Value1).intersects(EnumSet.fromArray([MockEnum.Value1, MockEnum2.Value1])));
		
		assertFalse(MockEnum.All.intersects([]));
		assertFalse(MockEnum.All.intersects(null));
		assertFalse(MockEnum.All.intersects(Array));
		assertFalse(MockEnum.All.intersects(new EnumSet()));
	}
	
	public function test_equals():void
	{
		assertFalse(MockEnum.All.equals(MockEnum.Value1));
		assertFalse(MockEnum.All.equals(MockEnum.Value2));
		assertFalse(MockEnum.All.equals(MockEnum.Value3));
		
		assertFalse(MockEnum.All.equals([MockEnum.Value1, MockEnum.Value2]));
		assertFalse(MockEnum.All.equals([MockEnum.Value1, MockEnum.Value3]));
		assertFalse(MockEnum.All.equals([MockEnum.Value2, MockEnum.Value3]));
		
		assertFalse(MockEnum.All.equals([MockEnum.Value1, MockEnum.Value2, MockEnum.Value3]));
		assertTrue(MockEnum.All.equals([MockEnum.Value1, MockEnum.Value2, MockEnum.Value3, MockEnum.nexuslib_internal::Value3]));
		
		assertFalse(MockEnum.All.equals(MockEnum2.Value1));
		
		assertTrue(MockEnum.All.equals(MockEnum.All));
		assertTrue(MockEnum.All.equals(Enum.values(MockEnum)));
		assertTrue(MockEnum.All.equals(EnumSet.fromArray(MockEnum.All.getValues())));
		
		assertFalse(MockEnum.All.equals(MockEnum.Value2));
		assertFalse(MockEnum.All.equals([MockEnum.Value2]));
		assertFalse(MockEnum.All.equals(EnumSet.fromArray([MockEnum.Value2])));
		//assertTrue(MockEnum.All.equals(new <MockEnum>[MockEnum.Value2]));
		
		assertTrue(EnumSet.fromArgs(MockEnum.Value1, MockEnum2.Value1).equals(EnumSet.fromArray([MockEnum.Value1, MockEnum2.Value1])));
		assertFalse(EnumSet.fromArgs(MockEnum.Value1, MockEnum2.Value1).equals(EnumSet.fromArray([MockEnum.Value1])));
		assertFalse(EnumSet.fromArgs(MockEnum2.Value1).equals(EnumSet.fromArray([MockEnum.Value1, MockEnum2.Value1])));
		
		assertFalse(MockEnum.All.equals([]));
		assertFalse(MockEnum.All.equals(null));
		assertFalse(MockEnum.All.equals(Array));
		assertFalse(MockEnum.All.equals(new EnumSet()));
	}
	
	//--------------------------------------
	//	UTILITY METHODS
	//--------------------------------------
}
	
}