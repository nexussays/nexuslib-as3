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

import flash.display.Sprite;
import flash.utils.*;

import nexus.utils.reflection.*;

import test_classes.foo.bar.BaseClass;
import test_classes.foo.bar.TestClass;
import test_classes.foo.IFoo;

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
		m_testTypeInfo = Reflection.getTypeInfo(m_test);
		m_baseTypeInfo = Reflection.getTypeInfo(BaseClass);
	}
	
	//--------------------------------------
	//	TESTS
	//--------------------------------------
	
	public function test_isDynamic():void
	{
		assertEquals(true, m_testTypeInfo.isDynamic);
		assertEquals(false, m_baseTypeInfo.isDynamic);
	}
	
	public function test_type():void
	{
		assertSame(TestClass, m_testTypeInfo.type);
		assertSame(BaseClass, m_baseTypeInfo.type);
	}
	
	public function test_name():void
	{
		assertEquals("test_classes.foo.bar::TestClass", m_testTypeInfo.name);
		assertEquals("test_classes.foo.bar::BaseClass", m_baseTypeInfo.name);
	}
	
	public function test_extendedClasses():void
	{
		assertEquals(1, m_testTypeInfo.extendedClasses.indexOf(Object));
		assertEquals(0, m_testTypeInfo.extendedClasses.indexOf(BaseClass));
		assertEquals( -1, m_testTypeInfo.extendedClasses.indexOf(Sprite));
		
		assertEquals(0, m_baseTypeInfo.extendedClasses.indexOf(Object));
		assertEquals( -1, m_baseTypeInfo.extendedClasses.indexOf(BaseClass));
		assertEquals( -1, m_baseTypeInfo.extendedClasses.indexOf(Sprite));
	}
	
	public function test_implementedInterfaces():void
	{
		assertEquals(0, m_testTypeInfo.implementedInterfaces.indexOf(IFoo));
		
		assertEquals(-1, m_baseTypeInfo.implementedInterfaces.indexOf(IFoo));
	}
}

}