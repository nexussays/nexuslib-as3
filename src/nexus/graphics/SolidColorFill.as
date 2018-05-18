// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.graphics
{

import nexus.graphics.IFill;
import flash.display.Graphics;

public class SolidColorFill implements IFill
{
   private var m_color:uint;
   private var m_alpha:Number;

   public function SolidColorFill(color:uint, alpha:Number=1.0)
   {
      this.color = color;
      this.alpha = alpha;
   }

   public function get color():uint { return m_color; }
   public function set color(value:uint):void
   {
      m_color = value;
   }

   public function get alpha():Number { return m_alpha; }
   public function set alpha(value:Number):void
   {
      m_alpha = value;
   }

   public function begin(target:Graphics):void
   {
      target.beginFill(color, alpha);
   }

   public function end(target:Graphics):void
   {
      target.endFill();
   }

   public function clone():IFill
   {
      return new SolidColorFill(color, alpha);
   }

   public function toString():String
   {
      return "[SolidColorFill color=" + color.toString(16) + ", alpha=" + alpha + "]";
   }
}
}
