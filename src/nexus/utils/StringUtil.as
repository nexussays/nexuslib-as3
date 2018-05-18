// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.utils
{

import flash.utils.Dictionary;

/**
 * Utility class to manipulate strings
 */
public class StringUtil
{
   public static function trim(value:String):String
   {
      return value != null ? value.replace(/^\s+|\s+$/g, "") : null;
   }

   public static function capitalizeFirst(str:String): String
   {
      return str.substr(0, 1).toUpperCase() + str.substr(1);
   }

   public static function makePossessive(str:String) : String
   {
      return (str.charAt(str.length - 1) == 's' ? str + "'" : str) + "'s";
   }

   public static function pluralize(word:String, count:int) : String
   {
      if(count != 1 && word != null)
      {
         // note: check for words like 'wrench'; this won't work for
         // Czechs, Fuchs, Machs, Sachs, conchs, epochs, eunuchs, lochs,
         // matriarchs, monarchs, oligarchs, patriarchs, psychs,
         // scotchs, stomachs, synchs, techs, and triptychs, but should
         // be fine otherwise
         if (/ch$/.test(word))
         {
            return word + "es";
         }

         var lastChar : String = word.charAt(word.length - 1);
         switch (lastChar)
         {
            case 's':
            case 'o':
               return word + "es";
            default:
               return word + "s";
         }
      }
      return word;
   }

   public static function compare(a:String, b:String):int
   {
      return a != null ? a.localeCompare(b) : (b != null ? b.localeCompare(a) : 0);
   }
}

}
