// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package test.nexus.utils.serialization.json
{

import asunit.framework.TestCase;
import mock.testing_namespace;
import nexus.utils.ObjectUtils;

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
	
	private var m_base1 : BaseClass;
	private var m_base2 : BaseClass;
	
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
		m_base1 = new BaseClass();
		m_base2 = new BaseClass();
		m_base1.baseVar = m_base2.baseVar = 100;
		m_base1.testing_namespace::baseVar = "test_serialization3";
		
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
	
	/**
	 * Ensure that all calls to a serializer with identical data produce identical results
	 */
	public function test_determinism():void
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
	
	/**
	 * Repeatedly serialize and deserialize the same data to insure integrity
	 */
	public function test_integrity():void
	{
		internal_testIntegrity(false);
	}
	
	/**
	 * Ensure serializing with a namespace is different than without (where m_base1 has namespaced fields)
	 */
	public function test_namespace1():void
	{
		m_serializer1.includeNamespace(testing_namespace);
		
		m_json1 = m_serializer1.serialize(m_base1);
		m_json2 = m_serializer2.serialize(m_base1);
		assertTrue(m_json1 != m_json2);
	}
	
	/**
	 * Repeatedly serialize and deserialize the same data, including a namespace, to insure integrity
	 */
	public function test_namespaceIntegrity():void
	{
		//internal_testIntegrity(true);
	}
	
	/**
	 * serialize a typed object with a namespaced field and then deserialize into a typed object
	 */
	public function test_namespace3():void
	{
		//TODO: This is really a test of ObjectUtils
		m_serializer1.includeNamespace(testing_namespace);
		
		m_json1 = m_serializer1.serialize(m_base1);
		m_base2 = m_serializer1.deserialize(m_json1, BaseClass) as BaseClass;
		m_json2 = m_serializer1.serialize(m_base2);
		assertEquals(m_json1, m_json2);
	}
	
	/**
	 * Add a bunch of extra values to the deserialized object and create an instance of it
	 */
	public function test_dynamic():void
	{
		var deserialized : Object;
		
		m_serializer1.includeNamespace(testing_namespace);
		
		m_json1 = m_serializer1.serialize(m_base1);
		deserialized = m_serializer1.deserialize(m_json1);
		deserialized["extra.foo::field"] = "blah blah";
		deserialized["http://mock.testing_namespace::var"] = "foo";
		m_base2 = ObjectUtils.createTypedObjectFromNativeObject(BaseClass, deserialized) as BaseClass;
		m_json2 = m_serializer1.serialize(m_base2);
		assertEquals(m_json1, m_json2);
	}
	
	public function test_IJsonSerializable():void
	{
		var custom : CustomSerializationClass = new CustomSerializationClass();
		var id : int = CustomSerializationClass.id;
		
		m_json1 = m_serializer1.serialize(custom);
		assertEquals("\"CustomSerializationClass" + id + "\"", m_json1);
		
		custom = m_serializer1.deserialize(m_json1, CustomSerializationClass) as CustomSerializationClass;
		assertEquals("CustomSerializationClass" + id, custom.baseString);
	}
	
	//--------------------------------------
	//	PRIVATE INSTANCE METHODS
	//--------------------------------------
	
	private function internal_testIntegrity(includeTestingNamespace:Boolean):void
	{
		var deserialized : Object;
		
		if(includeTestingNamespace)
		{
			m_serializer1.includeNamespace(testing_namespace);
		}
		
		m_json1 = m_serializer1.serialize(m_base1);
		deserialized = m_serializer1.deserialize(m_json1);
		m_json2 = m_serializer1.serialize(deserialized);
		assertEquals(m_json1, m_json2);
		
		deserialized = m_serializer2.deserialize(m_json2);
		m_json1 = m_serializer2.serialize(deserialized);
		assertEquals(m_json1, m_json2);
		
		deserialized = m_serializer1.deserialize(m_json1);
		m_json2 = m_serializer1.serialize(deserialized);
		assertEquals(m_json1, m_json2);
	}
}

}