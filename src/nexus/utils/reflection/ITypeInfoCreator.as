// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.utils.reflection
{

import flash.system.ApplicationDomain;
	
/**
 * An internal interface used for XML and JSON TypeInfo creators
 */
public interface ITypeInfoCreator
{
	function create(object:Object, type:Class, applicationDomain:ApplicationDomain):TypeInfo;
}

}