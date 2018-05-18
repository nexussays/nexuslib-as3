// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.audio
{

import flash.utils.*;


/**
 * A collection of VolumeControl instances for each sound channel. Used by SoundSystem to wrap all the
 * volume controls behind a single property.
 * @since 7/29/2010 1:13 PM
 */
public class StandardSoundChannels
{

   //--------------------------------------
   //   CLASS CONSTANTS
   //--------------------------------------

   //--------------------------------------
   //   PRIVATE VARIABLES
   //--------------------------------------

   private var m_volumeControls : Dictionary;

   //--------------------------------------
   //   CONSTRUCTOR
   //--------------------------------------

   /**
    *
    * @param   handler   A function that will be added to each category's onVolumeChanged event
    */
   public function StandardSoundChannels(handler:Function)
   {
      m_volumeControls = new Dictionary();
      for each(var category : SoundChannel in SoundChannel.All.values)
      {
         m_volumeControls[category] = new VolumeControl();
         m_volumeControls[category].onVolumeChanged.add(handler);
      }
   }

   //--------------------------------------
   //   GETTER/SETTERS
   //--------------------------------------

   public function get uiEffects():VolumeControl { return m_volumeControls[SoundChannel.UIEffects]; }

   public function get voices():VolumeControl { return m_volumeControls[SoundChannel.Voices]; }

   public function get ambient():VolumeControl { return m_volumeControls[SoundChannel.Ambient]; }

   public function get soundEffects():VolumeControl { return m_volumeControls[SoundChannel.SoundEffects]; }

   public function get backgroundMusic():VolumeControl { return m_volumeControls[SoundChannel.BackgroundMusic]; }

   //--------------------------------------
   //   PUBLIC METHODS
   //--------------------------------------

   //--------------------------------------
   //   EVENT HANDLERS
   //--------------------------------------

   //--------------------------------------
   //   PRIVATE & PROTECTED INSTANCE METHODS
   //--------------------------------------

   internal function getVolumeControlByCategory(category:SoundChannel):VolumeControl
   {
      return m_volumeControls[category];
   }

   internal function getCategoryByVolumeControl(control:VolumeControl):SoundChannel
   {
      for(var key : String in m_volumeControls)
      {
         if(m_volumeControls[SoundChannel.fromString(key)] == control)
         {
            return SoundChannel.fromString(key);
         }
      }
      return null;
   }
}

}
