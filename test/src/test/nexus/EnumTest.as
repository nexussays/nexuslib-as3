// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package test.nexus
{

import asunit.framework.TestCase;
import flash.errors.IllegalOperationError;
import mock.*;
import nexus.*;

/**
 * ...
 */
public class EnumTest extends TestCase
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
	
	public function EnumTest(testMethod:String = null)
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
	
	public function test_name():void
	{
		assertEquals("Value1", MockEnum2.Value1.name);
		assertEquals("Value2", MockEnum2.Value2.name);
		assertEquals("Value3", MockEnum2.Value3.name);
		
		assertEquals("Value3", MockEnum.nexuslib_internal::Value3.name);
	}
	
	public function test_fullname():void
	{
		assertEquals("mock::MockEnum.Value3", MockEnum.Value3.fullname);
		assertEquals("mock::MockEnum.Value3", MockEnum.nexuslib_internal::Value3.fullname);
		assertEquals("mock::MockEnum2.Value1", MockEnum2.Value1.fullname);
	}
	
	public function test_value():void
	{
		assertEquals(1, MockEnum2.Value1.value);
		assertEquals(2, MockEnum2.Value2.value);
		assertEquals(4, MockEnum2.Value3.value);
	}
	
	public function test_equals():void
	{
		assertNotSame(MockEnum.Value1, MockEnum.Value2, MockEnum.Value3);
		
		assertSame(MockEnum.Value1, MockEnum.Value1);
		
		assertTrue(MockEnum.Value1 == MockEnum.Value1);
		assertFalse(MockEnum.Value1 == MockEnum.Value2);
		assertFalse(MockEnum.Value1 == MockEnum.Value3);
		
		assertTrue(MockEnum.Value1.equals(MockEnum.Value1));
		assertFalse(MockEnum.Value1.equals(MockEnum.Value2));
		assertFalse(MockEnum.Value1.equals(MockEnum.Value3));
		
		assertFalse(MockEnum.Value3.equals([MockEnum.Value1, MockEnum.Value2]));
		assertFalse(MockEnum.Value3.equals([MockEnum.Value1, MockEnum.Value3]));
		assertFalse(MockEnum.Value3.equals([MockEnum.Value2, MockEnum.Value3]));
		
		assertFalse(MockEnum.Value3.equals([MockEnum.Value1, MockEnum.Value2, MockEnum.Value3]));
		
		//compile-time type error. Enums ftw.
		//assertFalse(MockEnum.Value1 == MockEnum2.Value1);
		assertFalse(MockEnum.Value1.equals(MockEnum2.Value1));
		
		assertTrue(MockEnum.Value2.equals(MockEnum.Value2));
		assertTrue(MockEnum.Value2.equals([MockEnum.Value2]));
		assertTrue(MockEnum.Value2.equals(EnumSet.fromArray([MockEnum.Value2])));
		assertTrue(MockEnum.Value2.equals(EnumSet.fromArgs(MockEnum.Value2)));
		assertTrue(MockEnum.Value2.equals(new <MockEnum>[MockEnum.Value2]));
		
		assertFalse(MockEnum.Value2.equals([]));
		assertFalse(MockEnum.Value2.equals(null));
		assertFalse(MockEnum.Value2.equals(Array));
		assertFalse(MockEnum.Value2.equals(new EnumSet()));
	}
	
	public function test_intersects():void
	{
		assertTrue(MockEnum.Value1.intersects(MockEnum.Value1));
		assertFalse(MockEnum.Value1.intersects(MockEnum.Value2));
		assertFalse(MockEnum.Value1.intersects(MockEnum.Value3));
		
		assertFalse(MockEnum.Value3.intersects([MockEnum.Value1, MockEnum.Value2]));
		assertTrue(MockEnum.Value3.intersects([MockEnum.Value1, MockEnum.Value3]));
		assertTrue(MockEnum.Value3.intersects([MockEnum.Value2, MockEnum.Value3]));
		
		assertTrue(MockEnum.Value3.intersects([MockEnum.Value1, MockEnum.Value2, MockEnum.Value3]));
		
		assertFalse(MockEnum.Value1.intersects(MockEnum2.Value1));
		
		assertTrue(MockEnum.Value2.intersects(MockEnum.Value2));
		assertTrue(MockEnum.Value2.intersects([MockEnum.Value2]));
		assertTrue(MockEnum.Value2.equals(EnumSet.fromArray([MockEnum.Value2])));
		assertTrue(MockEnum.Value2.equals(EnumSet.fromArgs(MockEnum.Value2)));
		assertTrue(MockEnum.Value2.intersects(new <MockEnum>[MockEnum.Value2]));
		
		assertFalse(MockEnum.Value2.intersects([]));
		assertFalse(MockEnum.Value2.intersects(null));
		assertFalse(MockEnum.Value2.intersects(Array));
		assertFalse(MockEnum.Value2.intersects(new EnumSet()));
	}
	
	public function test_instantiation():void
	{
		assertThrows(IllegalOperationError, function():void { new MockEnum() } );
		
		var fail : MockEnum;
		assertThrows(IllegalOperationError, function():void { fail = new MockEnum() } );
		assertNull(fail);
	}
	
	public function test_badEnum1():void
	{
		assertThrows(IllegalOperationError, function():void { BadEnum.Value1 } );
		
		//should have thrown in the constructor and should not exist
		assertThrows(TypeError, function():void { BadEnum.Value1 } );
	}
	
	public function test_badEnum2():void
	{
		assertThrows(SyntaxError, function():void { BadEnum2.Value1 } );
	}
	
	public function test_badEnum3():void
	{
		assertFalse(BadEnum3.Value1 == BadEnum3.Value2);
		BadEnum3.Value1 = BadEnum3.Value2;
		assertTrue(BadEnum3.Value1 == BadEnum3.Value2);
		
		assertThrows(SyntaxError, function():void { BadEnum3.Value1.name } );
	}
	
	//--------------------------------------
	//	UTILITY METHODS
	//--------------------------------------
}
	
}