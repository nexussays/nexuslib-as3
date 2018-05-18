// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.graphics
{

import nexus.math.MathHelper;

/**
 * ...
 */
public class Color
{
   public static const LUM_R:Number = 0.212671;
   public static const LUM_G:Number = 0.715160;
   public static const LUM_B:Number = 0.072169;

   public var red : int;
   public var green : int;
   public var blue : int;
   public var alpha : int;

   public function Color(red:int, green:int, blue:int, alpha:int=255)
   {
      //is there a point to clamping if they are public vars anyway?
      this.red = MathHelper.clamp(red, 0, 255);
      this.green = MathHelper.clamp(green, 0, 255);
      this.blue = MathHelper.clamp(blue, 0, 255);
      this.alpha = MathHelper.clamp(alpha, 0, 255);
   }

   public function matches(other:Color):Boolean
   {
      return red == other.red && green == other.green && blue == other.blue && alpha == other.alpha;
   }

   public function setSaturation(n:Number):void
   {
      if(!isNaN(n))
      {
         red   = MathHelper.clamp(red   * ((1 - n) * LUM_R + n), 0, 255);
         green = MathHelper.clamp(green * ((1 - n) * LUM_G + n), 0, 255);
         blue  = MathHelper.clamp(blue  * ((1 - n) * LUM_B + n), 0, 255);
      }
   }

   public function toARGB():uint
   {
      return uint( ((alpha & 0xff) << 24) | ((red & 0xff) << 16) | ((green & 0xff) << 8) | (blue & 0xff) );
   }

   public function toString():String
   {
      return "(r=" + red + ", g=" + green + ", b=" + blue + ", a=" + alpha + ")";
   }

   public static function fromARGB(color:uint):Color
   {
      var a : uint = ((color >> 24) & 0xFF);
      var r : uint = ((color >> 16) & 0xFF);
      var g : uint = ((color >> 8) & 0xFF);
      var b : uint = (color & 0xFF);
      return new Color(r, g, b, a);
   }
}
}
