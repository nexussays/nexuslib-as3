// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package
{

import test.*;
import test.nexus.*;
import test.nexus.math.*;
import test.nexus.security.crypto.*;
import test.nexus.utils.*;
import test.nexus.utils.reflection.*;
import test.nexus.utils.serialization.json.*;

[Suite]
public class MainTestSuite
{
   public var basic   : BasicTest;
   
   public var enum      : EnumTest;
   public var enumSet   : EnumSetTest;
   
   public var reflection         : ReflectionTest;
   public var reflection_typeInfo   : TypeInfoTest;
   
   public var objectUtils   : ObjectUtilsTest;
   public var json         : JsonSerializerTest;
   
   public var rngLehmer   : LehmerGeneratorTest;
   public var rngTinymt   : TinyMTGeneratorTest;
   public var rngNative   : NativeRandomGeneratorTest;
   
   public var hmac   : HMACTest;
}

}
