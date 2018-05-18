// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus
{

import nexus.utils.DateUtil;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Stage;
import flash.external.ExternalInterface;
import flash.system.Capabilities;
import flash.system.Security;
import flash.system.System;
import flash.utils.*;

/**
 * Class to wrap debugging functions.
 */
public class Debug
{
   /**
    * Write the information to trace output and Debug
    * @param   source   The object the debug is coming from
    * @param   args
    * @example In your class, this is a common implementation:
    * <pre>
    * private function trace(...params): void
    * {
    *    Debug.debug(this, params);
    * }
    * </pre>
    * If you expect your class to be inherited, you can pass in the class object to use
    * internally and optionally provide a protected trace method for your subclasses to use:
    * <pre>
    * private function debugSelf(...params): void
    * {
    *    Debug.debug(MyBaseClass, params);
    * }
    * protected function trace(...params): void
    * {
    *    Debug.debug(this, params);
    * }
    * </pre>
    */
   CONFIG::debug
   public static function debug(source : *, args : *): void
   {
      var name : String = getQualifiedClassName(source);
      name = name.substring(name.lastIndexOf(":") + 1);
      args.splice(0, 0, getTimer() + " [" + name + ".as]");
      trace.apply(source, args);
   }

   CONFIG::release
   public static function debug(...params): void
   {
      //NOOP in release mode
   }

   CONFIG::debug
   public static function showParentage(obj : DisplayObject):String
   {
      var arr:Array = new Array();
      while (obj != null)
      {
         arr.push(obj.x + "," + obj.y + " " + obj.width + "x" + obj.height + " (" + obj.scaleX + "," + obj.scaleY + ")" + (obj.visible ? "" : " (invis)") + ":" + obj);
         obj = obj.parent;
      }

      var prefix:String = "";
      var result:String = "";
      for (var i:int = arr.length - 1; i >= 0; --i)
      {
         result += prefix + arr[i] + "\n";
         prefix += " ";
      }

      return result;
   }

   CONFIG::release
   public static function showParentage(obj : DisplayObject):String
   {
      return "";
   }

   CONFIG::debug
   public static function recurseDisplayTree(obj:DisplayObjectContainer):String
   {
      return recurseDisplay(obj, 0);
   }

   CONFIG::release
   public static function recurseDisplayTree(obj:DisplayObjectContainer):String
   {
      return "";
   }

   public static function getKeysForObject( obj : Object ) : Array
   {
      var result : Array = [];
      for(var prop : String in obj)
      {
         result.push(prop);
      }
      return result;
   }

   public static function flattenObject( obj : Object, a_delimiter : String = ", " ) : String
   {
      var result : Array = new Array();
      for(var item : Object in obj)
      {
         result.push(item + ": " + obj[item]);
      }
      return result.join(a_delimiter);
   }

   public static function dumpSystemInfo(stage:Stage=null):Array
   {
      var dump : Array = new Array();

      dump.push("PLAYER: " + Capabilities.playerType + (Capabilities.isDebugger ? " (debug) " : " ") + "version: " + Capabilities.version);
      if(stage != null)
      {
         dump.push("PLAYER USING WMODEGPU: " + stage.wmodeGPU);
      }
      dump.push("PLAYER RUN TIME: " + DateUtil.getFormattedTime( getTimer() ));
      dump.push("PLAYER CAPABILITIES: " +
         "audio: " + Capabilities.hasAudio + ", " +
         "streamingaudio: " + Capabilities.hasStreamingAudio + ", " +
         "streamingvideo: " + Capabilities.hasStreamingVideo);

      dump.push("SANDBOX: " + Security.sandboxType);

      dump.push("CLIENT OS: " + Capabilities.os);
      dump.push("CLIENT CPU: " + Capabilities.cpuArchitecture);
      dump.push("CLIENT TIME: " + (new Date()));
      dump.push("CLIENT RESOLUTION: " + Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY);
      dump.push("CLIENT LANGUAGE: " + Capabilities.language);

      dump.push("EXTERNAL INTERFACE: " + ExternalInterface.available + " id: " + ExternalInterface.objectID);

      return dump;
   }

   private static function recurseDisplay(obj:DisplayObject, level:int=0):String
   {
      var result : String = padding(level) + obj + " \"" + obj.name + "\" " +
         (obj.cacheAsBitmap ? "cacheAsBitmap " : "") +
         (obj.filters != null && obj.filters.length > 0 ? obj.filters.length + "filters " : "") +
         "a:" + obj.alpha + " " +
         "(" + obj.x + "," + obj.y + ") " + obj.width + "x" + obj.height +
         (obj.visible ? "" : " (invis)");
      var disp : DisplayObjectContainer = obj as DisplayObjectContainer;
      if (disp != null)
      {
         result += " " + disp.numChildren + " children";
         //for(var x : int = disp.numChildren - 1; x >= 0; --x)
         for(var x : int = 0; x < disp.numChildren; ++x)
         {
            try
            {
               result += "\n" + recurseDisplay(disp.getChildAt(x), level + 1);
            }
            catch(e:RangeError)
            {
               //no idea why, but this sometimes gives a range error even if x is less than numChildren
            }
         }
      }
      return result;
   }

   private static function padding(num:int):String
   {
      var result : String = "";
      for(var x : int = 0; x < num; ++x)
      {
         result += "  ";
      }
      return result;
   }
}
}
