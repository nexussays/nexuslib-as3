// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package test.nexus.utils
{

import asunit.framework.TestCase;
import mock.foo.bar.BaseClass;
import nexus.utils.ObjectUtils;
import nexus.utils.reflection.Reflection;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
public class ObjectUtilsTest extends TestCase
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_goodJson : Object;
	private var m_badJson : Object;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function ObjectUtilsTest(testMethod:String = null)
	{
		super(testMethod);
	}
	
	//--------------------------------------
	//	SETUP & TEARDOWN
	//--------------------------------------
	
	override protected function setUp():void
	{
		m_goodJson = {
			"baseString": "string value",
			"baseVector": [
				"vector value 0",
				"vector value 1"
			],
			"subObj1": {
				"array": [
					"array value 0",
					"array value 1"
				],
				"vector": [
					"vector value 0",
					"vector value 1"
				],
				"date": 1275838483
			},
			"subObj2": {
					
			}
		};
		
		m_badJson = {
			"baseString": {
				obj: "sub value"
			},
			"baseVector": {
				vec: "is object"
			},
			"newValue": 500,
			"subObj1": "bad string value",
			"subObj2": {
				"array": [
					"array value 0",
					"array value 1"
				],
				"vector": [
					"vector value 0",
					"vector value 1"
				],
				"date": 1275838483
			}
		};
	}
	
	override protected function tearDown():void
	{
		
	}
	
	//--------------------------------------
	//	TESTS
	//--------------------------------------
	
	public function test_createTypedObjectFromNativeObject_good():void
	{
		var base : BaseClass;
		
		base = ObjectUtils.createTypedObjectFromNativeObject(BaseClass, m_goodJson) as BaseClass;
		
		assertSame(BaseClass,				Reflection.getClass(base));
		
		assertEquals("string value",		base.baseString);
		assertEquals("vector value 0",		base.baseVector[0]);
		assertEquals("vector value 1",		base.baseVector[1]);
	}
	
	public function test_createTypedObjectFromNativeObject_bad():void
	{
		var base : BaseClass;
		
		base = ObjectUtils.createTypedObjectFromNativeObject(BaseClass, m_badJson) as BaseClass;
		
		assertSame(BaseClass,				Reflection.getClass(base));
		
		assertNull(base.baseString);
		assertEquals(0, 					base.baseVector.length);
	}
}

}