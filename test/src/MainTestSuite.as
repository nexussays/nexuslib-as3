// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package
{

import test.nexus.*;
import test.nexus.security.crypto.*;
import test.nexus.utils.*;
import test.nexus.utils.reflection.*;
import test.nexus.utils.serialization.json.*;

[Suite]
public class MainTestSuite// extends TestSuite
{
	public var enum : EnumTest;
	public var enumSet : EnumSetTest;
	
	//public var test01 : ReflectionTest;
	//public var test02 : TypeInfoTest;
	//public var test03 : ObjectUtilsTest;
	//public var test04 : JsonSerializerTest;
	//
	//public var hmac : HMACTest;
	
	public function MainTestSuite()
	{
		//addTest(new ReflectionCoreTest());
		//addTest(new ReflectionTypeInfoTest());
	}
}

}