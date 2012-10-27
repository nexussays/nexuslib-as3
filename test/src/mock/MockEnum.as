// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package mock
{

import nexus.*;

public class MockEnum extends Enum
{
	public static const Value1 : MockEnum = new MockEnum();
	public static const Value2 : MockEnum = new MockEnum();
	public static const Value3 : MockEnum = new MockEnum();
	
	nexuslib_internal static const Value3:MockEnum = new MockEnum();
	
	public static const FOO:String = "FOO";
	
	public static function get All():EnumSet { return Enum.values(MockEnum); }
}

}