// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.audio
{

import nexus.FunctionGroup;
import flash.utils.Dictionary;

/**
 * ...
 */
public class VolumeControl
{
   //--------------------------------------
   // CLASS CONSTANTS
   //--------------------------------------

   internal const onVolumeChanged : FunctionGroup = new FunctionGroup([VolumeControl]);

   //--------------------------------------
   //  PROTECTED VARIABLES
   //--------------------------------------

   protected var m_systemVolume : Number;
   protected var m_userVolume : Number;

   protected var m_isMuted : Boolean;

   //--------------------------------------
   //  CONSTRUCTOR
   //--------------------------------------

   public function VolumeControl()
   {
      m_systemVolume = 1.0;
      m_userVolume = 1.0;
      m_isMuted = false;
   }

   //--------------------------------------
   //  GETTER/SETTERS
   //--------------------------------------

   /**
    * The system volume of this control. This should be used for things like fading out, where we wouldn't want
    * to actually adjust the volume the user has set.
    */
   public function get systemVolume() : Number { return m_systemVolume; }
   public function set systemVolume( value : Number ) : void
   {
      m_systemVolume = CoreSound.filterVolume(value);
      adjustVolume();
   }

   /**
    * The user-defined volume of this control.
    */
   public function get userVolume() : Number { return m_isMuted ? 0 : m_userVolume; }
   public function set userVolume( value : Number ) : void
   {
      m_userVolume = CoreSound.filterVolume(value);
      adjustVolume();
   }

   /**
    * The current actual volume, accounting for systemVolume and userVolume adjustments and muting
    */
   public function get actualVolume(): Number { return this.systemVolume * this.userVolume; }

   /**
    * The current actual volume rounded to an integer from 0-100
    */
   public function get actualVolumeAsInt(): int { return int(this.actualVolume * 100); }


   public function get isMuted():Boolean { return m_isMuted; }

   //--------------------------------------
   //  PUBLIC METHODS
   //--------------------------------------

   /**
    * Mutes all sounds in this group, does not stop or pause any sounds that are currently playing.
    */
   public function mute(): void
   {
      m_isMuted = true;
      adjustVolume();
   }

   /**
    * Unmutes all sounds in this group, does not start or unpause any sounds.
    */
   public function unmute(): void
   {
      m_isMuted = false;
      adjustVolume();
   }

   /**
    * Toggles the mute start from its current state to the opposite state.
    */
   public function toggleMute(): void
   {
      if(m_isMuted)
      {
         unmute();
      }
      else
      {
         mute();
      }
   }

   //--------------------------------------
   //  PRIVATE & PROTECTED INSTANCE METHODS
   //--------------------------------------

   private function adjustVolume():void
   {
      onVolumeChanged.execute(this);
   }
}

}
