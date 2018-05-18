// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.audio
{

import nexus.Enum;
import nexus.EnumSet;

/**
 * ...
 */
public class SoundChannel extends Enum
{
   {initEnum(SoundChannel); }

   //--------------------------------------
   // CLASS CONSTANTS
   //--------------------------------------

   public static const BackgroundMusic : SoundChannel = new SoundChannel();
   public static const SoundEffects : SoundChannel = new SoundChannel();
   public static const UIEffects : SoundChannel = new SoundChannel();
   public static const Ambient : SoundChannel = new SoundChannel();
   public static const Voices : SoundChannel = new SoundChannel();

   //--------------------------------------
   //  GETTER/SETTERS
   //--------------------------------------

   public static function get All():EnumSet
   {
      return Enum.valuesAsEnumSet(SoundChannel);
   }

   //--------------------------------------
   //  PUBLIC METHODS
   //--------------------------------------

   public static function fromString(value:*):SoundChannel
   {
      var enum : SoundChannel = Enum.fromString(SoundChannel, value, false) as SoundChannel;
      if(enum == null)
      {
         throw new ArgumentError("Cannot convert \"" + value + "\" into a SoundChannel");
      }
      return enum;
   }
}
}
