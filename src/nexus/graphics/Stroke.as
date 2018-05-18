// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.graphics
{

import flash.display.Graphics;

/**
 * The Stroke class defines the properties for a line.
 */
public class Stroke implements IStroke
{
   private var m_thickness : Number;
   private var m_fill : SolidColorFill;
   private var m_usePixelHinting : Boolean;
   private var m_scaleMode : String;
   private var m_caps : String;
   private var m_joints : String;
   private var m_miterLimit : Number;

   public function Stroke(   thickness:Number,
                     color:uint,
                     alpha:Number = 1.0,
                     usePixelHinting:Boolean = false,
                     scaleMode:String = "normal",
                     caps:String = "none",
                     joints:String = "round",
                     miterLimit:Number = 3.0)
   {
      this.thickness = thickness;
      this.fill = new SolidColorFill(color, alpha);

      this.usePixelHinting = usePixelHinting;

      this.scaleMode = scaleMode;
      this.caps = caps;
      this.joints = joints;
      this.miterLimit = miterLimit;
   }

   public function get thickness():Number { return m_thickness; }
   public function set thickness(value:Number):void
   {
      m_thickness = value;
   }

   public function get fill():SolidColorFill { return m_fill; }
   public function set fill(value:SolidColorFill):void
   {
      m_fill = value;
   }

   public function get usePixelHinting():Boolean { return m_usePixelHinting; }
   public function set usePixelHinting(value:Boolean):void
   {
      m_usePixelHinting = value;
   }

   public function get scaleMode():String { return m_scaleMode; }
   public function set scaleMode(value:String):void
   {
      m_scaleMode = value;
   }

   public function get caps():String { return m_caps; }
   public function set caps(value:String):void
   {
      m_caps = value;
   }

   public function get joints():String { return m_joints; }
   public function set joints(value:String):void
   {
      m_joints = value;
   }

   public function get miterLimit():Number { return m_miterLimit; }
   public function set miterLimit(value:Number):void
   {
      m_miterLimit = value;
   }

   public function apply(target:Graphics) : void
   {
      target.lineStyle(thickness, fill.color, fill.alpha, usePixelHinting, scaleMode, caps, joints, miterLimit);
   }
}
}
