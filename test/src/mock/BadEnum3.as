// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package mock
{

import nexus.Enum;

/**
 * This class should fail but not until values are accessed
 */
public class BadEnum3 extends Enum
{
	public static var Value1:BadEnum3 = new BadEnum3();
	public static var Value2:BadEnum3 = new BadEnum3();
}

}