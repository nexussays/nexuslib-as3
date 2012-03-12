/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is PROJECT_NAME.
 *
 * The Initial Developer of the Original Code is
 * Malachi Griffie <malachi@nexussays.com>.
 * Portions created by the Initial Developer are Copyright (C) 2011
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** */
package test.nexus.utils.serialization.json
{

import asunit.framework.TestCase;
import mock.testing_namespace;

import flash.utils.*;

import mock.foo.bar.*;

import nexus.utils.serialization.json.JsonSerializer;

/**
 * ...
 */
public class JsonSerializerTest extends TestCase
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_base1 : DynamicBaseClass;
	private var m_base2 : DynamicBaseClass;
	
	private var m_serializer1 : JsonSerializer;
	private var m_serializer2 : JsonSerializer;
	
	private var m_json1 : Object;
	private var m_json2 : Object;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function JsonSerializerTest(testMethod:String = null)
	{
		super(testMethod);
	}
	
	//--------------------------------------
	//	SETUP & TEARDOWN
	//--------------------------------------
	
	override protected function setUp():void
	{
		m_base1 = new DynamicBaseClass();
		m_base2 = new DynamicBaseClass();
		m_base1.baseVar = m_base2.baseVar = 100;
		
		m_serializer1 = new JsonSerializer();
		m_serializer2 = new JsonSerializer();
	}
	
	override protected function tearDown():void
	{
		m_base1 = null;
		m_base2 = null;
		
		m_serializer1 = null;
		m_serializer2 = null;
		
		m_json1 = null;
		m_json2 = null;
	}
	
	//--------------------------------------
	//	TESTS
	//--------------------------------------
	
	public function test_serialization1():void
	{
		//first instance
		
		m_json1 = m_serializer1.serialize(m_base1);
		m_json2 = m_serializer1.serialize(m_base1);
		assertEquals(m_json1, m_json2);
		
		m_json1 = m_serializer2.serialize(m_base1);
		m_json2 = m_serializer2.serialize(m_base1);
		assertEquals(m_json1, m_json2);
		
		m_json1 = m_serializer1.serialize(m_base1);
		m_json2 = m_serializer2.serialize(m_base1);
		assertEquals(m_json1, m_json2);
		
		//second instance
		
		m_json1 = m_serializer1.serialize(m_base2);
		m_json2 = m_serializer1.serialize(m_base2);
		assertEquals(m_json1, m_json2);
		
		m_json1 = m_serializer2.serialize(m_base2);
		m_json2 = m_serializer2.serialize(m_base2);
		assertEquals(m_json1, m_json2);
		
		m_json1 = m_serializer1.serialize(m_base2);
		m_json2 = m_serializer2.serialize(m_base2);
		assertEquals(m_json1, m_json2);
		
		//both instances
		
		m_json1 = m_serializer1.serialize(m_base1);
		m_json2 = m_serializer1.serialize(m_base2);
		assertEquals(m_json1, m_json2);
		
		m_json1 = m_serializer2.serialize(m_base1);
		m_json2 = m_serializer2.serialize(m_base2);
		assertEquals(m_json1, m_json2);
		
		m_json1 = m_serializer1.serialize(m_base1);
		m_json2 = m_serializer2.serialize(m_base2);
		assertEquals(m_json1, m_json2);
		
		m_json1 = m_serializer1.serialize(m_base2);
		m_json2 = m_serializer2.serialize(m_base1);
		assertEquals(m_json1, m_json2);
	}
	
	public function test_serialization2():void
	{
		m_json1 = m_serializer1.serialize(m_base1);
		var deserialized : Object = m_serializer1.deserialize(m_json1);
		m_json2 = m_serializer1.serialize(deserialized);
		assertEquals(m_json1, m_json2);
		
		m_base1 = m_serializer1.deserialize(m_json1, DynamicBaseClass) as DynamicBaseClass;
		m_json2 = m_serializer1.serialize(m_base1);
		assertEquals(m_json1, m_json2);
	}
	
	public function test_serialization3():void
	{
		var deserialized : Object;
		
		m_serializer1.includeNamespaceInSerialization(testing_namespace);
		//m_base1.testing_namespace::baseVar = "test_serialization3";
		m_base1["dynamic.var::foo"] = "dynamic";
		m_base1["http://mock.testing_namespace::dynamictoo"] = "dynamic";
		
		m_json1 = m_serializer1.serialize(m_base1);
		deserialized = m_serializer1.deserialize(m_json1);
		m_json2 = m_serializer1.serialize(deserialized);
		deserialized = m_serializer1.deserialize(m_json2);
		m_json1 = m_serializer1.serialize(deserialized);
		assertEquals(m_json1, m_json2);
		
		m_json1 = m_serializer1.serialize(m_base1);
		m_base2 = m_serializer1.deserialize(m_json1, DynamicBaseClass) as DynamicBaseClass;
		m_json2 = m_serializer1.serialize(m_base2);
		assertEquals(m_json1, m_json2);
	}
}

}