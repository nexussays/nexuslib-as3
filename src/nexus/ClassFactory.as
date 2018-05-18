// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus
{

/**
 * A factory used to create instances of an object given a Class and an optional
 * Object to assign public properties/variables on the instantiated instance.
 */
public class ClassFactory implements IFactory
{
	private var m_class : Class;
	private var m_properties : Object;

	public function ClassFactory(source:Class, properties:Object = null)
	{
		m_class = source;
		m_properties = properties;
	}

	public function get type():Class { return m_class; }

	public function get properties():Object { return m_properties; }
	public function set properties(value:Object):void
	{
		m_properties = value;
	}

	public function create():*
	{
		var instance:* = new m_class();
		if(m_properties != null)
		{
			for(var property:String in m_properties)
			{
				instance[property] = m_properties[property];
			}
		}
		return instance;
	}
}
}
