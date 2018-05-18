// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.utils
{

import nexus.math.Random;
import nexus.math.SeededRandom;
import nexus.SystemTime;
import flash.filters.ColorMatrixFilter;
import flash.geom.ColorTransform;

/**
 * A collection of various utility methods, now
 */
public class ColorUtils
{

   /**
    * Convert a color to its greyscale equivalent using proper colorspace.
    * @param   a_color
    * @return
    */
   public static function convertToGreyscale( a_color : uint ) : uint
   {
      var r : uint = ((a_color >> 16) & 0xFF);
      var g : uint = ((a_color >> 8) & 0xFF);
      var b : uint = (a_color & 0xFF);
      //section c-9
      //http://www.faqs.org/faqs/graphics/colorspace-faq/
      var y : uint = 0.212671 * r + 0.715160 * g + 0.072169 * b;

      //return new color but retain alpha from pre-greyscale version
      return (a_color & 0xff000000 | ((y & 0xff) << 16) | ((y & 0xff) << 8) | (y & 0xff));
   }

   public static function get greyscaleColorMatrixFilter() : ColorMatrixFilter
   {
      //return new ColorTransform(0.212671, 0.715160, 0.072169);
      //return new ColorTransform(0.3086, 0.6094, 0.0820);
      return new ColorMatrixFilter([
         .212671, .715160, .072169, 0, 0,
         .212671, .715160, .072169, 0, 0,
         .212671, .715160, .072169, 0, 0,
         0, 0, 0, 1, 0,
      ]);
   }

}

}
