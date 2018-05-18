// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.net.mercury
{

import nexus.EnumSet;
import flash.utils.*;

import nexus.Enum;

/**
 * An enum used in Messenger to define which ApplicationDomain the loaded content should be placed in
 * @since 3/14/2011 10:09 PM
 */
public class ApplicationDomainType extends Enum
{

   {initEnum(ApplicationDomainType);}

   /**
    * This allows the loaded SWF file to use the parent's classes directly, for example by writing
    * <code>new MyClassDefinedInParent()</code>.  The parent, however, cannot use this syntax;
    * if the parent wishes to use the child's classes, it must call
    * <code>ApplicationDomain.getDefinition()</code> to retrieve them.  The advantage of
    * this choice is that, if the child defines a class with the same name as a class already
    * defined by the parent, no error results; the child simply inherits the parent's
    * definition of that class, and the child's conflicting definition goes unused unless
    * either child or parent calls the <code>ApplicationDomain.getDefinition()</code> method to retrieve it.
    */
   public static const Child : ApplicationDomainType = new ApplicationDomainType();

   /**
    * When the load is complete, parent and child can use each other's classes directly. If the child attempts
    * to define a class with the same name as a class already defined by the parent, the parent class is used
    * and the child class is ignored.
    */
   public static const Current : ApplicationDomainType = new ApplicationDomainType();

   /**
    * This separates loader and loadee entirely, allowing them to define separate versions of classes
    * with the same name without conflict or overshadowing.  The only way either side sees the other's
    * classes is by calling the <code>ApplicationDomain.getDefinition()</code> method.
    */
   public static const Separate : ApplicationDomainType = new ApplicationDomainType();


   //public static function get All():EnumSet
   //{
      //return Enum.valuesAsEnumSet(ApplicationDomainType);
   //}

   public static function fromString(value:*):ApplicationDomainType
   {
      var enum : ApplicationDomainType = Enum.fromString(ApplicationDomainType, value, false) as ApplicationDomainType;
      if(enum == null)
      {
         throw new ArgumentError("Cannot convert \"" + value + "\" into ApplicationDomainType");
      }
      return enum;
   }
}

}
