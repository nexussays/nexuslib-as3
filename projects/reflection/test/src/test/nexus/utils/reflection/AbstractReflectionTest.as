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

import asunit.framework.TestCase;

import nexus.utils.reflection.*;

import mock.foo.bar.*;
import mock.foo.IFoo;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
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