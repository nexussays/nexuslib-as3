// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.net.mercury
{

import nexus.Enum;
import nexus.EnumSet;
import flash.utils.*;

/**
 * An enum which defines the possible type of data a transport can return. This is the base type and more functionality can
 * be layered on top, eg ResourceType.Text could be processed as XML or JSON
 * @since 3/14/2011 11:31 AM
 */
public class ResourceType extends Enum
{

   {initEnum(ResourceType);}

   public static const Audio : ResourceType = new ResourceType();
   public static const Bitmap : ResourceType = new ResourceType();
   public static const Bytes : ResourceType = new ResourceType();
   public static const SWF : ResourceType = new ResourceType();
   public static const Text : ResourceType = new ResourceType();

   public static function get All():EnumSet
   {
      return Enum.valuesAsEnumSet(ResourceType);
   }

   public static function fromString(value:*):ResourceType
   {
      var enum : ResourceType = Enum.fromString(ResourceType, value, false) as ResourceType;
      if(enum == null)
      {
         throw new ArgumentError("Cannot convert \"" + value + "\" into a ResourceType");
      }
      return enum;
   }
}

}
