// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.audio
{

import flash.events.Event;
import flash.media.*;
import flash.utils.*;

import nexus.audio.*;
import nexus.math.Random;
import nexus.IDisposable;

/**
 * Randomly plays one sound out of a given variety of sounds.
 */
public class RandomSound extends CoreSound
{
   //--------------------------------------
   //  PRIVATE VARIABLES
   //--------------------------------------

   private var m_sounds : Vector.<CoreSound>;
   private var m_currentSound : CoreSound;
   private var m_nextSound : CoreSound;

   //--------------------------------------
   //  CONSTRUCTOR
   //--------------------------------------

   /**
    * Initialized with an array of CoreSound
    * @param   sounds   An array of CoreSound instance, a Class of an [Embed] sound, or a path to a sound asset
    * @example <code>
    * var sound : RandomSound = new RandomSound([ new SelfLoadingSound("/path/sound.mp3"), embeddedSoundClass,
    *       new CoreSound(new EmbeddedSoundClass()), coreSoundInstance2, "/path/sound2.mp3" ]);
    * </code>
    */
   function RandomSound( sounds: Array = null )
   {
      super(null);

      m_sounds = new Vector.<CoreSound>();

      for each(var sound: * in sounds)
      {
         this.addSound( sound );
      }
   }

   public function get currentSound():CoreSound { return m_currentSound; }

   public function get nextSound():CoreSound { return m_nextSound; }

   //--------------------------------------
   //  PUBLIC METHODS
   //--------------------------------------

   /**
    * Adds a sound to the variety if it does not already exist.
    * If the sound already exists in the variety, nothing is added.
    * @param   a_sound      The sound to add to the variety
    */
   public function addSound(sound : *) : void
   {
      var coreSound : CoreSound = CoreSound.create(sound);
      if(!hasSound(coreSound))
      {
         m_sounds.push(coreSound);

         //if this is the first sound added, set it to be the next sound
         if(m_nextSound == null)
         {
            m_nextSound = coreSound;
         }
      }
   }

   /**
    * Removes the sound from the variety if it exists. If the sound does
    * not exist in the variety, nothing is removed and no errors are thrown.
    * @param   a_sound      The sound to remove from the variety
    */
   public function removeSound(sound : CoreSound) : void
   {
      var index : int = m_sounds.indexOf(sound);
      if(index != -1)
      {
         m_sounds.splice(index, 1);
      }
   }

   public function hasSound(sound: CoreSound): Boolean
   {
      return (m_sounds.indexOf(sound) != -1);
   }

   override protected function startPlay(loop:Boolean, callback:Function, waitForLoad:Boolean):void
   {
      if(m_nextSound != null)
      {
         setActiveSound(m_nextSound);
      }

      super.startPlay(loop, callback, waitForLoad);

      if(m_sounds.length > 0)
      {
         m_nextSound = m_sounds[ Random.randomInt(0, m_sounds.length - 1) ];
      }
   }

   override public function dispose():void
   {
      for each( var sound : CoreSound in m_sounds )
      {
         sound.dispose();
         delete m_sounds[ sound ];
         sound = null;
      }
      sound = null;
      m_sounds = null;
      super.dispose();
   }

   private function setActiveSound(sound:CoreSound):void
   {
      m_currentSound = sound;
      m_channel = m_currentSound.channel;
      m_sound = m_currentSound.sound;
   }
}
}
