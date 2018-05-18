// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.net.mercury
{

import nexus.Debug;
import flash.events.Event;

import flash.utils.*;

/**
 * ...
 * @since 3/19/2011 5:27 PM
 */
public class MessengerEvent extends Event
{
   //--------------------------------------
   //   CLASS CONSTANTS
   //--------------------------------------

   public static const LOAD_PROGRESS : String = " nexus.net.mercury.LOAD_PROGRESS";
   public static const LOAD_ERROR : String = " nexus.net.mercury.LOAD_ERROR";
   public static const LOAD_COMPLETE : String = " nexus.net.mercury.LOAD_COMPLETE";

   //--------------------------------------
   //   PRIVATE VARIABLES
   //--------------------------------------

   private var m_message : String;

   //--------------------------------------
   //   CONSTRUCTOR
   //--------------------------------------

   public function MessengerEvent(type:String, messageOverride:String=null)
   {
      super(type, false, false);

      //if(!(super.target is Messenger))
      //{
         //throw new Error("Error dispatching MessengerEvent, target is not an instance of  nexus.net.mercury.Messenger: " + super.target);
      //}

      switch(type)
      {
         case LOAD_PROGRESS:
         case LOAD_ERROR:
         case LOAD_COMPLETE:
            //all good
            break;
         default:
            throw new Error("Error dispatching MessengerEvent, type is invalid value \"" + type + "\"");
      }

      m_message = messageOverride;
   }

   //--------------------------------------
   //   GETTER/SETTERS
   //--------------------------------------

   public function get messenger():Messenger { return Messenger(super.target); }

   //--------------------------------------
   //   PUBLIC METHODS
   //--------------------------------------

   public override function clone():Event
   {
      return new MessengerEvent(type);
   }

   public override function toString():String
   {
      return "[MessengerEvent:HTTP" + messenger.httpStatus + ", " + (m_message || messenger.statusMessage) + "]";
   }

   //--------------------------------------
   //   EVENT HANDLERS
   //--------------------------------------

   //--------------------------------------
   //   PRIVATE & PROTECTED INSTANCE METHODS
   //--------------------------------------

   private final function trace(...params): void
   {
      Debug.debug(MessengerEvent, params);
   }
}

}
