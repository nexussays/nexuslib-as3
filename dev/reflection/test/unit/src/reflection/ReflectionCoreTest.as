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

import asunit.framework.*;

import flash.display.Sprite;
import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

import nexus.utils.reflection.*;

import mock.foo.bar.BaseClass;
import mock.foo.bar.TestClass;
import mock.foo.IFoo;

/**
 * Test the utility methods in Reflection, aside from getTypeInfo()
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	1/14/2012 11:47 PM
 */
public class ReflectionCoreTest extends TestCase
{
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_testTypeInfo:TypeInfo;
	private var m_baseTypeInfo:TypeInfo;
	private var m_test:TestClass;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function ReflectionCoreTest(testMethod:String = null)
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
	
	override protected function tearDown():void
	{
		m_testTypeInfo = null;
		m_baseTypeInfo = null;
		m_test = null;
	}
	
	//--------------------------------------
	//	TESTS
	//--------------------------------------
	
	public function test_getClass():void
	{
		assertSame(TestClass,	Reflection.getClass(m_test));
		assertSame(TypeInfo,	Reflection.getClass(TypeInfo));
		assertSame(String,		Reflection.getClass("dna.utils.reflection::TypeInfo"));
		assertSame(String,		Reflection.getClass("TypeInfo"));
	}
	
	public function test_getClassByNameWithApplicationDomain():void
	{
		assertSame(BaseClass,		Reflection.getClassByName("mock.foo.bar::BaseClass", Reflection.SYSTEM_DOMAIN));
		assertSame(BaseClass,		Reflection.getClassByName("mock.foo.bar::BaseClass", ApplicationDomain.currentDomain));
		
		//FIXME: I feel like this should work. Is it my bug or do I misunderstand something about app domains?
		//assertSame(TestClass,		Reflection.getClassByName("mock.foo.bar::TestClass", new ApplicationDomain(ApplicationDomain.currentDomain)));
	}
	
	public function test_getClassByName():void
	{
		assertSame(BaseClass,	Reflection.getClassByName("mock.foo.bar.BaseClass"));
		assertSame(BaseClass,	Reflection.getClassByName("mock.foo.bar::BaseClass"));
		assertSame(TestClass,	Reflection.getClassByName("mock.foo.bar::TestClass"));
		
		assertThrows(ReferenceError,	function():void { Reflection.getClassByName("foo") } );
		assertThrows(ReferenceError,	function():void { Reflection.getClassByName("TestClass") } );
		
		assertSame(IFoo,		Reflection.getClassByName("mock.foo::IFoo"));
		
		assertSame(Object,	Reflection.getClassByName("*"));
		assertSame(Object,	Reflection.getClassByName("Object"));
		
		assertSame(Class,	Reflection.getClassByName("Class"));
		
		assertSame(Vector.<Object>,	Reflection.getClassByName("Vector.<*>"));
		assertSame(Vector.<Object>,	Reflection.getClassByName("Vector.<Object>"));
		assertSame(Vector.<Object>,	Reflection.getClassByName("__AS3__.vec::Vector.<*>"));
		
		assertSame(null,	Reflection.getClassByName("null"));
		assertSame(null,	Reflection.getClassByName("void"));
		assertSame(null,	Reflection.getClassByName("undefined"));
		
		assertSame(uint,		Reflection.getClassByName("uint"));
		assertSame(int,			Reflection.getClassByName("int"));
		assertSame(Number,		Reflection.getClassByName("Number"));
		assertSame(Array,		Reflection.getClassByName("Array"));
		assertSame(Date,		Reflection.getClassByName("Date"));
		assertSame(Dictionary,	Reflection.getClassByName("flash.utils.Dictionary"));
		assertSame(Dictionary,	Reflection.getClassByName("flash.utils::Dictionary"));
	}
	
	public function test_getSuperClass():void
	{
		assertSame(BaseClass,	Reflection.getSuperClass(m_test));
		assertSame(BaseClass,	Reflection.getSuperClass(TestClass));
		assertSame(Object,		Reflection.getSuperClass(BaseClass));
		assertSame(Object,		Reflection.getSuperClass("mock.foo.bar::TestClass"));
		assertSame(Object,		Reflection.getSuperClass("TestClass"));
	}
	
	public function test_getVectorType():void
	{
		assertSame(String,		Reflection.getVectorType(new Vector.<String>()));
		assertSame(BaseClass,	Reflection.getVectorType(new Vector.<BaseClass>()));
		assertSame(Object,		Reflection.getVectorType(new Vector.<*>()));
		
		assertSame(null,		Reflection.getVectorType([]));
		assertSame(null,		Reflection.getVectorType("string"));
		
		assertSame(Vector.<String>,		Reflection.getVectorType(new Vector.<Vector.<String>>()));
	}
	
	public function test_getQualifiedClassName():void
	{
		assertEquals("mock.foo.bar::BaseClass",	Reflection.getQualifiedClassName(BaseClass));
		assertEquals("mock.foo.bar::BaseClass",	Reflection.getQualifiedClassName(new BaseClass()));
		assertEquals("mock.foo::IFoo",			Reflection.getQualifiedClassName(IFoo));
		
		assertEquals("__AS3__.vec::Vector.<Object>",	Reflection.getQualifiedClassName(Vector.<Object>));
		assertEquals("__AS3__.vec::Vector.<Object>",	Reflection.getQualifiedClassName(new Vector.<Object>()));
		assertEquals("__AS3__.vec::Vector.<String>",	Reflection.getQualifiedClassName(new <String>["foo", "bar"]));
		
		assertSame("null",	Reflection.getQualifiedClassName(null));
		assertSame("null",	Reflection.getQualifiedClassName(undefined));
		
		///@see: http://jacksondunstan.com/articles/1357
		assertEquals("int",		Reflection.getQualifiedClassName(5));
		assertEquals("int",		Reflection.getQualifiedClassName(5.0));
		assertEquals("Number",	Reflection.getQualifiedClassName(5.555));
	}
	
	public function test_comprehensive():void
	{
		assertSame(Vector.<String>,
			Reflection.getClass(new (Reflection.getClassByName(Reflection.getQualifiedClassName(new Vector.<String>())))()) );
		assertSame(Vector.<Object>,
			Reflection.getClass(new (Reflection.getClassByName(Reflection.getQualifiedClassName(new Vector.<*>())))()) );
		assertSame(TestClass,
			Reflection.getClass(new (Reflection.getClassByName(Reflection.getQualifiedClassName(new TestClass())))()) );
		
		assertSame(int,
			Reflection.getClass(new (Reflection.getClassByName(Reflection.getQualifiedClassName(5)))()) );
	}
	
	public function test_getUnqualifiedClassName():void
	{
		assertEquals("TestClass", 		Reflection.getUnqualifiedClassName(m_test));
		assertEquals("TestClass", 		Reflection.getUnqualifiedClassName(TestClass));
		assertEquals("TestClass", 		Reflection.getUnqualifiedClassName("[class TestClass]"));
		assertEquals("TestClass", 		Reflection.getUnqualifiedClassName("foo::TestClass"));
		assertEquals("TestClass", 		Reflection.getUnqualifiedClassName("mock.foo.bar::TestClass"));
		//TODO: Support this case?
		//assertEquals("TestClass", 		Reflection.getUnqualifiedClassName("mock.foo.bar.TestClass"));
		assertEquals("String",			Reflection.getUnqualifiedClassName("TestClass"));
		assertEquals("Vector.<String>", Reflection.getUnqualifiedClassName("__AS3__.vec::Vector.<String>"));
	}
	
	public function test_isScalar():void
	{
		assertTrue(Reflection.isScalar(int));
		assertTrue(Reflection.isScalar(1));
		assertTrue(Reflection.isScalar(uint));
		assertTrue(Reflection.isScalar(Number));
		assertTrue(Reflection.isScalar(5.55555));
		
		assertTrue(Reflection.isScalar(String));
		assertTrue(Reflection.isScalar("foo"));
		
		assertFalse(Reflection.isScalar(Object));
		assertFalse(Reflection.isScalar({}));
		
		assertFalse(Reflection.isScalar(Array));
		assertFalse(Reflection.isScalar([]));
		
		assertFalse(Reflection.isScalar(null));
		
		assertFalse(Reflection.isScalar(TypeInfo));
		assertFalse(Reflection.isScalar(m_test));
	}
}

}