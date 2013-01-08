// Copyright 2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package test
{

import asunit.framework.TestCase;

/**
 * ...
 */
public class BasicTest extends TestCase
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
	
	public function BasicTest(testMethod:String = null)
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
	
	public function test_vectorEquality():void
	{
		assertTrue(	"new Vector.<*>() is Vector.<*>", new Vector.<*>() is Vector.<*>);
		assertFalse("new Vector.<*>() is Vector.<Object>", new Vector.<*>() is Vector.<Object>);
		assertTrue(	"Vector.<*> is Class", Vector.<*> is Class);
		
		assertTrue(	"new Vector.<Object>() is Vector.<Object>", new Vector.<Object>() is Vector.<*>);
		assertTrue(	"new Vector.<Object>() is Vector.<*>", new Vector.<Object>() is Vector.<Object>);
		assertTrue(	"Vector.<Object> is Class", Vector.<Object> is Class);
		
		assertTrue(	"new Vector.<String>() is Vector.<*>", new Vector.<String>() is Vector.<*>);
		assertFalse("new Vector.<String>() is Vector.<Object>", new Vector.<String>() is Vector.<Object>);
		assertTrue(	"new Vector.<String>() is Vector.<String>", new Vector.<String>() is Vector.<String>);
		assertTrue(	"Vector.<String> is Class", Vector.<String> is Class);
		
		assertFalse("new Vector.<int>() is Vector.<*>", new Vector.<int>() is Vector.<*>);
		assertFalse("new Vector.<int>() is Vector.<Object>", new Vector.<int>() is Vector.<Object>);
		assertTrue(	"new Vector.<int>() is Vector.<int>", new Vector.<int>() is Vector.<int>);
		assertTrue(	"Vector.<int> is Class", Vector.<int> is Class);
		
		assertFalse("new Vector.<uint>() is Vector.<*>", new Vector.<uint>() is Vector.<*>);
		assertFalse("new Vector.<uint>() is Vector.<Object>", new Vector.<uint>() is Vector.<Object>);
		assertTrue(	"new Vector.<uint>() is Vector.<uint>", new Vector.<uint>() is Vector.<uint>);
		assertTrue(	"Vector.<uint> is Class", Vector.<uint> is Class);
		
		assertFalse("new Vector.<Number>() is Vector.<*>", new Vector.<Number>() is Vector.<*>);
		assertFalse("new Vector.<Number>() is Vector.<Object>", new Vector.<Number>() is Vector.<Object>);
		assertTrue(	"new Vector.<Number>() is Vector.<Number>", new Vector.<Number>() is Vector.<Number>);
		assertTrue(	"Vector.<Number> is Class", Vector.<Number> is Class);
		
		assertTrue("new Vector.<Boolean>() is Vector.<*>", new Vector.<Boolean>() is Vector.<*>);
		assertFalse("new Vector.<Boolean>() is Vector.<Object>", new Vector.<Boolean>() is Vector.<Object>);
		assertTrue(	"new Vector.<Boolean>() is Vector.<Boolean>", new Vector.<Boolean>() is Vector.<Boolean>);
		assertTrue(	"Vector.<Boolean> is Class", Vector.<Boolean> is Class);
	}
}
	
}