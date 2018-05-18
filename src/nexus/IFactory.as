// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus
{

/**
 * Basic factory interface
 * @see  nexus.ClassFactory
 */
public interface IFactory
{
	function get type():Class;

	function get properties():Object;
	function set properties(value:Object):void;

	function create():*;
}
}
