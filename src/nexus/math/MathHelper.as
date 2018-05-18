// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.math
{

/**
 * A collection of math utility methods.
 */
public class MathHelper
{
	public static function clamp(value : Number, min : Number, max : Number) : Number
    {
        value = (value > max) ? max : value;
        value = (value < min) ? min : value;
        return value;
    }

	public static function sign(value : Number) : int
	{
		if (value == 0)
		{
			return 0;
		}
		return value > 0 ? 1 : -1;
	}

	public static function distance(value1 : Number, value2 : Number) : Number
    {
		return Math.abs(value1 - value2);
    }

	public static function toDegrees(radians : Number) : Number
    {
        return (radians * 57.29578);
    }

    public static function toRadians(degrees : Number) : Number
    {
        return (degrees * 0.01745329);
    }

	public static function wrapAngleRadians(angle : Number) : Number
	{
		while(angle <= -3.141593)
		{
			angle += 6.283185;
		}
		while(angle > 3.141593)
		{
			angle -= 6.283185;
		}
		return angle;
	}

	public static function wrapAngleDegrees(angle : Number) : Number
	{
		while(angle <= -180)
		{
			angle += 360;
		}
		while(angle > 180)
		{
			angle -= 360;
		}
		return angle;
	}

	/**
	 * Compares the sign value of source to compareTo and returns source or -source as appropriate
	 * @param	source		The value to check the sign of and return
	 * @param	compareTo	The value to compare against
	 */
	static public function matchSign(source:Number, compareTo:Number):Number
	{
		if(compareTo < 0)
		{
			return source <= 0 ? source : -source;
		}
		else
		{
			return source >= 0 ? source : -source
		}
	}
}
}
