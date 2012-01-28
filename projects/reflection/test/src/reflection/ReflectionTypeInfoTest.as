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
 * The Original Code is nexuslib.
 *
 * The Initial Developer of the Original Code is
 * Malachi Griffie <malachi@nexussays.com>.
 * Portions created by the Initial Developer are Copyright (C) 2011
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** */
package reflection
{

import flash.display.Sprite;
import flash.system.ApplicationDomain;
import flash.utils.*;

import mock.foo.bar.*;
import mock.foo.IFoo;

import nexus.utils.reflection.*;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	1/17/2012 3:37 AM
 */
public class ReflectionTypeInfoTest extends AbstractReflectionTest
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
	
	public function ReflectionTypeInfoTest(testMethod:String = null)
	{
		super(testMethod);
	}
	
	//--------------------------------------
	//	SETUP & TEARDOWN
	//--------------------------------------
	
	//--------------------------------------
	//	TESTS
	//--------------------------------------
	
	public function test_caching():void
	{
		assertSame(m_testTypeInfo, Reflection.getTypeInfo(m_test));
		assertSame(m_baseTypeInfo, Reflection.getTypeInfo(m_baseTypeInfo.type, ApplicationDomain.currentDomain));
		assertSame(m_finalTypeInfo, Reflection.getTypeInfo(FinalClass, Reflection.SYSTEM_DOMAIN));
		
		//TODO: Add checking for child app domains
		//assertSame(m_baseTypeInfo, Reflection.getTypeInfo(m_baseTypeInfo.type, new ApplicationDomain(ApplicationDomain.currentDomain)));
	}
	
	public function test_isDynamic():void
	{
		assertEquals(true,	m_testTypeInfo.isDynamic);
		assertEquals(false,	m_baseTypeInfo.isDynamic);
		assertEquals(false,	m_finalTypeInfo.isDynamic);
	}
	
	public function test_isFinal():void
	{
		assertEquals(false,	m_testTypeInfo.isFinal);
		assertEquals(false,	m_baseTypeInfo.isFinal);
		assertEquals(true,	m_finalTypeInfo.isFinal);
	}
	
	public function test_type():void
	{
		assertSame(TestClass,	m_testTypeInfo.type);
		assertSame(BaseClass,	m_baseTypeInfo.type);
		assertSame(FinalClass,	m_finalTypeInfo.type);
	}
	
	public function test_name():void
	{
		assertEquals("mock.foo.bar::TestClass",	m_testTypeInfo.name);
		assertEquals("mock.foo.bar::BaseClass",	m_baseTypeInfo.name);
		assertEquals("mock.foo.bar::FinalClass",m_finalTypeInfo.name);
	}
	
	public function test_extendedClasses():void
	{
		assertEquals(1,		m_testTypeInfo.extendedClasses.indexOf(Object));
		assertEquals(0,		m_testTypeInfo.extendedClasses.indexOf(BaseClass));
		assertEquals( -1,	m_testTypeInfo.extendedClasses.indexOf(TestClass));
		assertEquals( -1,	m_testTypeInfo.extendedClasses.indexOf(Sprite));
		
		assertEquals(0,		m_baseTypeInfo.extendedClasses.indexOf(Object));
		assertEquals( -1,	m_baseTypeInfo.extendedClasses.indexOf(BaseClass));
		assertEquals( -1,	m_baseTypeInfo.extendedClasses.indexOf(TestClass));
		assertEquals( -1,	m_baseTypeInfo.extendedClasses.indexOf(Sprite));
		
		assertEquals(2,		m_finalTypeInfo.extendedClasses.indexOf(Object));
		assertEquals(1,		m_finalTypeInfo.extendedClasses.indexOf(BaseClass));
		assertEquals(0,		m_finalTypeInfo.extendedClasses.indexOf(TestClass));
		assertEquals( -1,	m_finalTypeInfo.extendedClasses.indexOf(Sprite));
	}
	
	public function test_implementedInterfaces():void
	{
		assertEquals(0, m_testTypeInfo.implementedInterfaces.indexOf(IFoo));
		
		assertEquals( -1, m_baseTypeInfo.implementedInterfaces.indexOf(IFoo));
		
		assertEquals(-1, m_baseTypeInfo.implementedInterfaces.indexOf(IFoo));
	}
	
	public function testNamespacing():void
	{
		m_test.publicProperty = 555;
		
		assertNotNull(m_testTypeInfo.getMethodByName("namespacedMethod"));
		testMethodCalls(m_testTypeInfo.getMethodByName("namespacedMethod"));
		
		assertNotNull(m_testTypeInfo.getMethodByName("baseMethod"));
		testMethodCalls(m_testTypeInfo.getMethodByName("baseMethod"));
	}
	
	private function testMethodCalls(methodInfo:MethodInfo):void
	{
		assertEquals("555append", methodInfo.invoke(m_test, "append"));
		assertEquals("555appendfoo", methodInfo.invoke(m_test, "append", "foo"));
		assertEquals("555", methodInfo.invoke(m_test, null));
		assertEquals("555foo", methodInfo.invoke(m_test, null, "foo"));
		
		assertEquals("555append", m_test[methodInfo.qname]("append"));
		assertEquals("555appendfoo", m_test[methodInfo.qname]("append", "foo"));
		assertEquals("555", m_test[methodInfo.qname](null));
		assertEquals("555foo", m_test[methodInfo.qname](null, "foo"));
	}
	
	public function testMetadata():void
	{
		var method : MethodInfo;
		//
		//base class
		//
		assertNotNull(m_baseTypeInfo.getMetadataByName("ClassMetadata"));
		
		assertNotNull(m_baseTypeInfo.getMethodByName("baseMethod"));
		method = m_baseTypeInfo.getMethodByName("baseMethod");
		
		assertNotNull(method.getMetadataByName("MethodMetadata"));
		
		assertEquals("BaseClass",	method.getMetadataByName("MethodMetadata").getValue("on"));
		
		//
		//test class
		//
		assertNotNull(m_testTypeInfo.getMetadataByName("ClassMetadata"));
		
		assertEquals("ClassMetadata",	m_testTypeInfo.getMetadataByName("ClassMetadata").metadataName);
		
		assertEquals("TestClass",	m_testTypeInfo.getMetadataByName("ClassMetadata").getValue("on"));
		assertEquals("value",	m_testTypeInfo.getMetadataByName("ClassMetadata").metadataKeyValuePairs["param"]);
		
		assertNotNull(m_testTypeInfo.getMethodByName("baseMethod"));
		method = m_testTypeInfo.getMethodByName("baseMethod");
		
		//TODO: I feel like there is some inconssitency here and that these should work
		//assertNotNull(method.getMetadataByName("MethodMetadata"));
		
		//assertEquals("BaseClass",	method.getMetadataByName("MethodMetadata").getValue("on"));
		
		//
		//final class
		//
		assertNull(m_finalTypeInfo.getMetadataByName("ClassMetadata"));
		
		assertNotNull(m_finalTypeInfo.getMethodByName("baseMethod"));
		method = m_finalTypeInfo.getMethodByName("baseMethod");
		
		assertNotNull(method.getMetadataByName("MethodMetadata"));
		
		assertEquals("FinalClass",	method.getMetadataByName("MethodMetadata").getValue("on"));
	}
}

}