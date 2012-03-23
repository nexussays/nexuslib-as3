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
package test.nexus.utils.reflection
{

import asunit.framework.*;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

import mock.foo.bar.*;
import mock.foo.IFoo;

import nexus.errors.ClassNotFoundError;
import nexus.utils.reflection.*;

/**
 * Test the utility methods in Reflection, aside from getTypeInfo()
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
public class ReflectionCoreTest extends AbstractReflectionTest
{
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
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
	
	//--------------------------------------
	//	TESTS
	//--------------------------------------
	
	public function test_getClass():void
	{
		baseTest_getClass(null);
	}
	
	//TODO: Increase the scope of this test by loading in a new app domain
	public function test_getClassWithApplicationDomain():void
	{
		baseTest_getClass(Reflection.SYSTEM_DOMAIN);
		baseTest_getClass(ApplicationDomain.currentDomain);
		//FIXME: I feel like this should work
		//baseTest_getClass(new ApplicationDomain(ApplicationDomain.currentDomain));
	}
	
	public function test_getClassByName():void
	{
		baseTest_getClassByName(null);
	}
	
	//TODO: Increase the scope of this test by loading in a new app domain
	public function test_getClassByNameWithApplicationDomain():void
	{
		baseTest_getClassByName(Reflection.SYSTEM_DOMAIN);
		baseTest_getClassByName(ApplicationDomain.currentDomain);
		//baseTest_getClassByName(new ApplicationDomain(ApplicationDomain.currentDomain));
	}
	
	public function test_getSuperClass():void
	{
		baseTest_getSuperClass(null);
	}
	
	//TODO: Increase the scope of this test by loading in a new app domain
	public function test_getSuperClassWithApplicationDomain():void
	{
		baseTest_getSuperClass(Reflection.SYSTEM_DOMAIN);
		baseTest_getSuperClass(ApplicationDomain.currentDomain);
		//baseTest_getSuperClass(new ApplicationDomain(ApplicationDomain.currentDomain));
	}
	
	public function test_getApplicationDomain():void
	{
		assertSame(Reflection.SYSTEM_DOMAIN, Reflection.getApplicationDomain(m_test));
		
		assertTrue(Reflection.areApplicationDomainsEqual(ApplicationDomain.currentDomain, Reflection.getApplicationDomain(m_test)));
	}
	
	public function test_getVectorType():void
	{
		baseTest_getVectorType(null);
	}
	
	public function test_getVectorTypeWithApplicationDomain():void
	{
		baseTest_getVectorType(Reflection.SYSTEM_DOMAIN);
		baseTest_getVectorType(ApplicationDomain.currentDomain);
	}
	
	public function test_getQualifiedClassName():void
	{
		assertEquals("mock.foo.bar::BaseClass",	Reflection.getQualifiedClassName(BaseClass));
		assertEquals("mock.foo.bar::BaseClass",	Reflection.getQualifiedClassName(new BaseClass()));
		assertEquals("mock.foo.bar::TestClass",	Reflection.getQualifiedClassName(m_test));
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
	
	public function test_getUnqualifiedClassName():void
	{
		assertEquals("TestClass", 	Reflection.getUnqualifiedClassName(m_test));
		assertEquals("TestClass", 	Reflection.getUnqualifiedClassName(TestClass));
		assertEquals("TestClass", 	Reflection.getUnqualifiedClassName(new TestClass()));
		assertEquals("TestClass", 	Reflection.getUnqualifiedClassName("foo::TestClass"));
		assertEquals("TestClass", 	Reflection.getUnqualifiedClassName("mock.foo.bar::TestClass"));
		//TODO: Support this case?
		//assertEquals("TestClass",	Reflection.getUnqualifiedClassName("mock.foo.bar.TestClass"));
		assertEquals("TestClass",	Reflection.getUnqualifiedClassName("[class TestClass]"));
		assertEquals("String",		Reflection.getUnqualifiedClassName("TestClass"));
		
		assertEquals("IFoo",		Reflection.getUnqualifiedClassName(IFoo));
		
		assertEquals("Vector.<*>",		Reflection.getUnqualifiedClassName(new Vector.<*>()));
		assertEquals("Vector.<Object>",	Reflection.getUnqualifiedClassName(Vector.<Object>));
		assertEquals("Vector.<Object>", Reflection.getUnqualifiedClassName("__AS3__.vec::Vector.<Object>"));
		assertEquals("Vector.<String>",	Reflection.getUnqualifiedClassName(new <String>["foo", "bar"]));
		
		assertSame("null",	Reflection.getUnqualifiedClassName(null));
		assertSame("null",	Reflection.getUnqualifiedClassName(undefined));
		
		assertEquals("int",		Reflection.getUnqualifiedClassName(5));
		assertEquals("int",		Reflection.getUnqualifiedClassName(5.0));
		assertEquals("Number",	Reflection.getUnqualifiedClassName(5.555));
	}
	
	public function test_classExtendsClass():void
	{
		baseTest_classExtendsClass(null);
	}
	
	public function test_classExtendsClassWithApplicationDomain():void
	{
		baseTest_classExtendsClass(Reflection.SYSTEM_DOMAIN);
		baseTest_classExtendsClass(ApplicationDomain.currentDomain);
	}
	
	public function test_applicationDomainsAreEqual():void
	{
		var childDomain : ApplicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
		
		assertTrue(Reflection.areApplicationDomainsEqual(ApplicationDomain.currentDomain, ApplicationDomain.currentDomain));
		
		assertTrue(Reflection.areApplicationDomainsEqual(Reflection.SYSTEM_DOMAIN, ApplicationDomain.currentDomain));
		assertTrue(Reflection.areApplicationDomainsEqual(ApplicationDomain.currentDomain, Reflection.SYSTEM_DOMAIN));
		
		assertTrue(Reflection.areApplicationDomainsEqual(childDomain.parentDomain, Reflection.SYSTEM_DOMAIN));
		assertTrue(Reflection.areApplicationDomainsEqual(childDomain.parentDomain, ApplicationDomain.currentDomain));
		
		assertFalse(Reflection.areApplicationDomainsEqual(ApplicationDomain.currentDomain, childDomain));
		assertFalse(Reflection.areApplicationDomainsEqual(ApplicationDomain.currentDomain, new ApplicationDomain(Reflection.SYSTEM_DOMAIN)));
		assertFalse(Reflection.areApplicationDomainsEqual(ApplicationDomain.currentDomain, new ApplicationDomain(null)));
	}
	
	public function test_isScalar():void
	{
		//scalars
		
		assertTrue(Reflection.isScalar(int));
		assertTrue(Reflection.isScalar(0));
		assertTrue(Reflection.isScalar(1));
		assertTrue(Reflection.isScalar(uint));
		assertTrue(Reflection.isScalar(Number));
		assertTrue(Reflection.isScalar(5.55555));
		
		assertTrue(Reflection.isScalar(String));
		assertTrue(Reflection.isScalar("foo"));
		assertTrue(Reflection.isScalar(""));
		
		assertTrue(Reflection.isScalar(Boolean));
		assertTrue(Reflection.isScalar(false));
		assertTrue(Reflection.isScalar(true));
		
		//not scalars
		
		assertFalse(Reflection.isScalar(Object));
		assertFalse(Reflection.isScalar({}));
		
		assertFalse(Reflection.isScalar(Array));
		assertFalse(Reflection.isScalar([]));
		
		assertFalse(Reflection.isScalar(null));
		
		assertFalse(Reflection.isScalar(TestClass));
		assertFalse(Reflection.isScalar(m_test));
	}
	
	public function test_isArrayType():void
	{
		assertTrue(Reflection.isArrayType(new Vector.<String>()));
		assertTrue(Reflection.isArrayType(new <TestClass>[new TestClass(), m_test]));
		assertTrue(Reflection.isArrayType(Vector.<TestClass>));
		
		assertTrue(Reflection.isArrayType(Array));
		assertTrue(Reflection.isArrayType([]));
		
		assertFalse(Reflection.isArrayType(Object));
		assertFalse(Reflection.isArrayType({}));
	}
	
	public function test_isVector():void
	{
		assertTrue(Reflection.isVector(new Vector.<String>()));
		assertTrue(Reflection.isVector(new <TestClass>[new TestClass(), m_test]));
		assertTrue(Reflection.isVector(Vector.<TestClass>));
		
		assertFalse(Reflection.isVector(Array));
		assertFalse(Reflection.isVector([]));
		
		assertFalse(Reflection.isVector(Object));
		assertFalse(Reflection.isVector({}));
	}
	
	public function test_isAssociativeArray():void
	{
		assertTrue(Reflection.isAssociativeArray(Object));
		assertTrue(Reflection.isAssociativeArray({}));
		assertTrue(Reflection.isAssociativeArray(new Dictionary()));
		assertTrue(Reflection.isAssociativeArray(Dictionary));
		
		assertFalse(Reflection.isAssociativeArray(new Vector.<String>()));
		assertFalse(Reflection.isAssociativeArray(new <TestClass>[new TestClass(), m_test]));
		assertFalse(Reflection.isAssociativeArray(Vector.<TestClass>));
		
		assertFalse(Reflection.isAssociativeArray(Array));
		assertFalse(Reflection.isAssociativeArray([]));
		
		assertFalse(Reflection.isAssociativeArray(m_test));
		assertFalse(Reflection.isAssociativeArray(BaseClass));
	}
	
	public function testComprehensive():void
	{
		assertSame(Vector.<String>,
			Reflection.getClass(new (Reflection.getClassByName(Reflection.getQualifiedClassName(new Vector.<String>())))()) );
		assertSame(Vector.<*>,
			Reflection.getClass(new (Reflection.getClassByName(Reflection.getQualifiedClassName(new Vector.<*>())))()) );
		assertSame(Vector.<Object>,
			Reflection.getClass(new (Reflection.getClassByName(Reflection.getQualifiedClassName(new Vector.<Object>())))()) );
		
		assertSame(TestClass,
			Reflection.getClass(new (Reflection.getClassByName(Reflection.getQualifiedClassName(TestClass)))()) );
		assertSame(Date,
			Reflection.getClass(new (Reflection.getClassByName(Reflection.getQualifiedClassName(new Date())))()) );
		
		assertSame(Object,
			Reflection.getClass(new (Reflection.getClassByName(Reflection.getQualifiedClassName({})))()) );
			
		assertSame(int,
			Reflection.getClass(new (Reflection.getClassByName(Reflection.getQualifiedClassName(5)))()) );
	}
	
	//--------------------------------------
	//	PRIVATE INSTANCE METHODS
	//--------------------------------------
	
	private function baseTest_getClass(appDomain:ApplicationDomain):void
	{
		assertSame(int,			Reflection.getClass(0, appDomain));
		assertSame(Array,		Reflection.getClass([], appDomain));
		assertSame(Date,		Reflection.getClass(new Date(), appDomain));
		assertSame(Object,		Reflection.getClass({}, appDomain));
		
		assertNull(Reflection.getClass(null, appDomain));
		
		assertSame(TestClass,	Reflection.getClass(m_test, appDomain));
		assertSame(BaseClass,	Reflection.getClass(BaseClass, appDomain));
		assertSame(String,		Reflection.getClass("TypeInfo", appDomain));
		assertSame(String,		Reflection.getClass("dna.utils.reflection::TypeInfo", appDomain));
	}
	
	private function baseTest_getClassByName(appDomain:ApplicationDomain):void
	{
		assertSame(uint,		Reflection.getClassByName("uint", appDomain));
		assertSame(int,			Reflection.getClassByName("int", appDomain));
		assertSame(Number,		Reflection.getClassByName("Number", appDomain));
		assertSame(Array,		Reflection.getClassByName("Array", appDomain));
		assertSame(Date,		Reflection.getClassByName("Date", appDomain));
		assertSame(Class,		Reflection.getClassByName("Class", appDomain));
		assertSame(Dictionary,	Reflection.getClassByName("flash.utils.Dictionary", appDomain));
		assertSame(Dictionary,	Reflection.getClassByName("flash.utils::Dictionary", appDomain));
		assertSame(BaseClass,	Reflection.getClassByName("mock.foo.bar.BaseClass", appDomain));
		assertSame(BaseClass,	Reflection.getClassByName("mock.foo.bar::BaseClass", appDomain));
		assertSame(TestClass,	Reflection.getClassByName("mock.foo.bar::TestClass", appDomain));
		assertSame(IFoo,		Reflection.getClassByName("mock.foo::IFoo", appDomain));
		
		assertSame(Object,	Reflection.getClassByName("*", appDomain));
		assertSame(Object,	Reflection.getClassByName("Object", appDomain));
		
		assertNull(Reflection.getClassByName("null", appDomain));
		assertNull(Reflection.getClassByName("void", appDomain));
		assertNull(Reflection.getClassByName("undefined", appDomain));
		
		assertSame(Vector.<*>,				Reflection.getClassByName("Vector.<*>", appDomain));
		assertSame(Vector.<*>,				Reflection.getClassByName("__AS3__.vec::Vector.<*>", appDomain));
		assertSame(Vector.<Object>,			Reflection.getClassByName("Vector.<Object>", appDomain));
		assertSame(Vector.<FinalClass>,		Reflection.getClassByName("__AS3__.vec::Vector.<mock.foo.bar::FinalClass>", appDomain));
		assertSame(Vector.<Vector.<Object>>,Reflection.getClassByName("Vector.<__AS3__.vec::Vector.<Object>>", appDomain));
		
		assertThrows(ClassNotFoundError,	function():void { Reflection.getClassByName("foo", appDomain) } );
		assertThrows(ClassNotFoundError,	function():void { Reflection.getClassByName("TestClass", appDomain) } );
		//TODO: Find a fix for this?
		assertThrows(ClassNotFoundError,	function():void { Reflection.getClassByName("Vector.<__AS3__.vec::Vector.<*>>", appDomain) });
	}
	
	private function baseTest_getSuperClass(appDomain:ApplicationDomain):void
	{
		assertSame(BaseClass,	Reflection.getSuperClass(m_test, appDomain));
		assertSame(BaseClass,	Reflection.getSuperClass(TestClass, appDomain));
		assertSame(TestClass,	Reflection.getSuperClass(FinalClass, appDomain));
		assertSame(Object,		Reflection.getSuperClass(BaseClass, appDomain));
		assertSame(Object,		Reflection.getSuperClass(Date, appDomain));
		assertSame(Object,		Reflection.getSuperClass(Array, appDomain));
		
		assertSame(Vector.<*>,	Reflection.getSuperClass(Vector.<String>, appDomain));
		assertSame(Vector.<*>,	Reflection.getSuperClass(Vector.<Vector.<TestClass>>, appDomain));
		assertSame(Vector.<*>,	Reflection.getSuperClass(Vector.<Object>, appDomain));
		assertSame(Object,		Reflection.getSuperClass(Vector.<*>, appDomain));
		
		//strings
		assertSame(Object,		Reflection.getSuperClass("TestClass", appDomain));
		assertSame(Object,		Reflection.getSuperClass("mock.foo.bar::TestClass", appDomain));
		
		//no parent class of Object
		assertNull(Reflection.getSuperClass(Object, appDomain));
		
		//should return null instead of throwing null argument error
		assertNull(Reflection.getSuperClass(null, appDomain));
	}
	
	private function baseTest_getVectorType(appDomain:ApplicationDomain):void
	{
		assertSame(String,		Reflection.getVectorType(new Vector.<String>(), appDomain));
		assertSame(BaseClass,	Reflection.getVectorType(new Vector.<BaseClass>(), appDomain));
		
		assertSame(IFoo,		Reflection.getVectorType(new Vector.<IFoo>(), appDomain));
		
		assertSame(Object,		Reflection.getVectorType(new Vector.<Object>(), appDomain));
		assertSame(Object,		Reflection.getVectorType(new Vector.<*>(), appDomain));
		
		assertNull(Reflection.getVectorType([], appDomain));
		assertNull(Reflection.getVectorType("string", appDomain));
		
		assertSame(Vector.<String>,			Reflection.getVectorType(new Vector.<Vector.<String>>(), appDomain));
		assertSame(Vector.<Vector.<Array>>,	Reflection.getVectorType(new Vector.<Vector.<Vector.<Array>>>(), appDomain));
		assertSame(Vector.<FinalClass>,		Reflection.getVectorType(new Vector.<Vector.<FinalClass>>(), appDomain));
		
		assertNull(Reflection.getVectorType(null, appDomain));
	}
	
	private function baseTest_classExtendsClass(appDomain:ApplicationDomain):void
	{
		assertTrue(Reflection.classExtendsClass(FinalClass,	TestClass,	appDomain));
		assertTrue(Reflection.classExtendsClass(FinalClass,	BaseClass,	appDomain));
		assertTrue(Reflection.classExtendsClass(BaseClass,	Object,		appDomain));
		
		assertFalse(Reflection.classExtendsClass(TestClass,		FinalClass,	appDomain));
		assertFalse(Reflection.classExtendsClass(TestClass,		TestClass,	appDomain));
		assertFalse(Reflection.classExtendsClass(Object,		Object,		appDomain));
		
		assertFalse(Reflection.classExtendsClass(null,		Object,		appDomain));
		assertFalse(Reflection.classExtendsClass(Object,	null,		appDomain));
		assertFalse(Reflection.classExtendsClass(null,		FinalClass,	appDomain));
		assertFalse(Reflection.classExtendsClass(FinalClass,null,		appDomain));
		assertFalse(Reflection.classExtendsClass(null,		null,		appDomain));
		
		//assertFalse(Reflection.classExtendsClass(Class(Vector.<Object>),		Class(Vector.<String>),		appDomain));
	}
}

}