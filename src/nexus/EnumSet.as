// Copyright 2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus
{

import flash.utils.*;

/**
 * Used to group multiple Enums and compare Enums and EnumSets with one another
 */
public class EnumSet implements IEnum
{
	//--------------------------------------
	//	PRIVATE VARIABLES
	//--------------------------------------
	
	/**
	 * @private
	 */
	protected var m_values:Array;
	
	//--------------------------------------
	//	INITIALIZE
	//--------------------------------------
	
	/**
	 * Use static methods on EnumSet to instantiate
	 * @private
	 */
	public function EnumSet()
	{
		m_values = [];
	}
	
	/**
	 * Create a new EnumSet from the enum values in the provided array
	 * @param	values
	 * @return
	 */
	static public function fromArray(values:Array):EnumSet
	{
		var result : EnumSet = new EnumSet();
		//check for enums, retain order, and don't allow duplicates
		for(var x:int = 0; x < values.length; ++x)
		{
			var item:Object = values[x];
			if(!(item is Enum))
			{
				throw new ArgumentError("Cannot create EnumSet. Value " + item + " is not an Enum");
			}
			else if(result.m_values.indexOf(item) == -1)
			{
				result.m_values.push(item);
			}
		}
		return result;
	}
	
	/**
	 * Create a new EnumSet from the enums provided as arguments to this method
	 * @param	...args
	 * @return
	 */
	static public function fromArgs(...args):EnumSet
	{
		return EnumSet.fromArray(args);
	}
	
	/**
	 * Internal create method that doesn't check or filter values
	 * @return
	 */
	static internal function fromArrayInternal(array:Array):EnumSet
	{
		var result : EnumSet = new EnumSet();
		result.m_values = array;
		return result;
	}
	
	//--------------------------------------
	//	PUBLIC METHODS
	//--------------------------------------
	
	/**
	 * Get a clone of the Enum values in this EnumSet as an Array
	 */
	public function getValues():Array
	{
		return m_values.slice();
	}
	
	//
	// IEnum
	//
	
	/**
	 * @inheritDoc
	 */
	public function intersects(matchValue:Object):Boolean
	{
		if(matchValue == null || m_values.length == 0)
		{
			return false;
		}
		else if(matchValue is Enum)
		{
			return m_values.indexOf(matchValue) != -1;
		}
		else if(matchValue is EnumSet || matchValue is Array || matchValue is Vector.<*>)
		{
			var vals : Object = matchValue is EnumSet ? EnumSet(matchValue).m_values : matchValue;
			//quick check for no values
			if(vals.length == 0)
			{
				return false;
			}
			for(var x : int = 0; x < m_values.length; ++x)
			{
				//if even a single value matches, these intersect
				if(vals.indexOf(m_values[x]) != -1)
				{
					return true;
				}
			}
		}
		return false;
	}
	
	/**
	 * @inheritDoc
	 */
	public function equals(matchValue:Object):Boolean
	{
		if(matchValue == null || m_values.length == 0)
		{
			return false;
		}
		else if(matchValue is Enum)
		{
			//in order for a single Enum to be equal to this set there must be only one item
			return m_values.length == 1 && m_values[0] == matchValue;
		}
		else if(matchValue is EnumSet || matchValue is Array || matchValue is Vector.<*>)
		{
			var vals : Object = matchValue is EnumSet ? EnumSet(matchValue).m_values : matchValue;
			if(vals.length == m_values.length)
			{
				for(var x : int = 0; x < m_values.length; ++x)
				{
					if(vals.indexOf(m_values[x]) == -1)
					{
						return false;
					}
				}
				return true;
			}
		}
		return false;
	}
	
	public function toString():String
	{
		return "[EnumSet:" + m_values.toString() + "]";
	}
}

}