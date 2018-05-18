// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.graphics
{

import nexus.geom.GeomHelper;
import nexus.math.MathHelper;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Point;

/**
 * ...
 */
public class GraphicsUtil
{
   public static function drawWedge(graphics:Graphics, x:Number, y:Number, radius:Number, arc:Number, beginArc:Number = 0) : void
   {
      arc = Math.min(Math.abs(arc), 360);

      var numberOfSegments : Number = Math.ceil(arc / 45);
      var segmentAngleIncrease : Number = MathHelper.toRadians(arc / numberOfSegments);
      var angle : Number = MathHelper.toRadians(beginArc);
      var angleMid : Number = angle - (segmentAngleIncrease / 2);

      graphics.moveTo(x, y);
      graphics.lineTo(x + Math.cos(angle) * radius, y + Math.sin(angle) * radius);
      for (var i : int = 0; i < numberOfSegments; i++)
      {
         angle += segmentAngleIncrease;
         angleMid += segmentAngleIncrease;

         var anchorX : Number = x + radius * Math.cos(angle);
         var anchorY : Number = y + radius * Math.sin(angle);
         var controlX : Number = x + (radius / Math.cos(segmentAngleIncrease / 2)) * Math.cos(angleMid);
         var controlY : Number = y + (radius / Math.cos(segmentAngleIncrease / 2)) * Math.sin(angleMid);

         graphics.curveTo(controlX, controlY, anchorX, anchorY);
      }

      //end wedge
      graphics.lineTo(x, y);
   }
}
}
