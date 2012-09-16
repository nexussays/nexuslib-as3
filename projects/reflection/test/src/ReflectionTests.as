// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package
{

import test.nexus.utils.ObjectUtilsTest;
import test.nexus.utils.reflection.*;
import test.nexus.utils.serialization.json.JsonSerializerTest;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
[Suite]
public class ReflectionTests// extends TestSuite
{
	public var test01 : ReflectionCoreTest;
	public var test02 : ReflectionTypeInfoTest;
	public var test03 : ReflectionTypeInfoTest;
	public var test04 : ObjectUtilsTest;
	public var test05 : JsonSerializerTest;
	
	public function ReflectionTests()
	{
		//addTest(new ReflectionCoreTest());
		//addTest(new ReflectionTypeInfoTest());
	}
}

}