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
package reflection
{

import asunit.framework.TestCase;
import flash.system.ApplicationDomain;
import mock.foo.bar.FinalClass;

import flash.display.Sprite;
import flash.utils.*;

import nexus.utils.reflection.*;

import mock.foo.bar.BaseClass;
import mock.foo.bar.TestClass;
import mock.foo.IFoo;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	1/17/2012 3:37 AM
 */
public class ReflectionTypeInfoTest extends TestCase
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_finalTypeInfo:TypeInfo;
	private var m_testTypeInfo:TypeInfo;
	private var m_baseTypeInfo:TypeInfo;
	private var m_test:TestClass;
	
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
	
	override protected function setUp():void
	{
		m_test = new TestClass();
		var finalClass : FinalClass = new FinalClass(false);
		m_finalTypeInfo = Reflection.getTypeInfo(finalClass);
		m_testTypeInfo = Reflection.getTypeInfo(m_finalTypeInfo.extendedClasses[0]);
		m_baseTypeInfo = Reflection.getTypeInfo(BaseClass);
	}
	
	override protected function tearDown():void
	{
		m_testTypeInfo = null;
		m_baseTypeInfo = null;
		m_test = null;
	}
	
	//--------------------------------------
	//	TESTS
	//--------------------------------------
	
	/*
	public function test_caching():void
	{
		assertSame(m_testTypeInfo, Reflection.getTypeInfo(m_test));
		assertSame(m_baseTypeInfo, Reflection.getTypeInfo(m_baseTypeInfo.type, ApplicationDomain.currentDomain));
		assertSame(m_finalTypeInfo, Reflection.getTypeInfo(FinalClass, Reflection.SYSTEM_DOMAIN));
	}
	//*/
	
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
	
	public function test_metadata():void
	{
		assertNotNull(m_testTypeInfo.getMetadataInfoByName("ClassMetadata"));
		assertEquals("value2",	m_testTypeInfo.getMetadataInfoByName("ClassMetadata").getValue("param2"));
		assertEquals("value",	m_testTypeInfo.getMetadataInfoByName("ClassMetadata").data["param"]);
		assertEquals("ClassMetadata",	m_testTypeInfo.getMetadataInfoByName("ClassMetadata").name);
	}
}

}