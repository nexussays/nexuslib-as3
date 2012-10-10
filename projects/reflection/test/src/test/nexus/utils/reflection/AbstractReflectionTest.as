// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package test.nexus.utils.reflection
{

import asunit.framework.TestCase;

import nexus.utils.reflection.*;

import mock.foo.bar.*;
import mock.foo.IFoo;

/**
 * ...
 */
public class AbstractReflectionTest extends TestCase
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	protected var m_finalTypeInfo:TypeInfo;
	protected var m_testTypeInfo:TypeInfo;
	protected var m_baseTypeInfo:TypeInfo;
	protected var m_test:TestClass;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function AbstractReflectionTest(testMethod:String = null)
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
		m_finalTypeInfo = null;
		m_baseTypeInfo = null;
		m_test = null;
	}
}

}