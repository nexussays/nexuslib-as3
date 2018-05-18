package nexus.net
{

import nexus.Enum;
import nexus.EnumSet;

import flash.utils.*;

/**
 * ...
 * @since 3/8/2011 3:06 PM
 */
public class HttpRequestMethod extends Enum
{

   {initEnum(HttpRequestMethod);}

   //--------------------------------------
   //   ENUM DEFINITIONS
   //--------------------------------------

   public static const GET : HttpRequestMethod = new HttpRequestMethod(true);
   public static const POST : HttpRequestMethod = new HttpRequestMethod(true);
   public static const PUT : HttpRequestMethod = new HttpRequestMethod(false);
   public static const DELETE : HttpRequestMethod = new HttpRequestMethod(false);
   public static const HEAD : HttpRequestMethod = new HttpRequestMethod(false);
   public static const OPTIONS : HttpRequestMethod = new HttpRequestMethod(false);

   public static function get All():EnumSet
   {
      return Enum.valuesAsEnumSet(HttpRequestMethod);
   }

   //--------------------------------------
   //   PRIVATE VARIABLES
   //--------------------------------------

   private var m_isNativelySupported : Boolean;

   //--------------------------------------
   //   CONSTRUCTOR
   //--------------------------------------

   public function HttpRequestMethod(nativeSupport:Boolean)
   {
      m_isNativelySupported = nativeSupport;
   }

   //--------------------------------------
   //   GETTER/SETTERS
   //--------------------------------------

   public function get isNativelySupported():Boolean { return m_isNativelySupported; }

   //--------------------------------------
   //   PUBLIC CLASS METHODS
   //--------------------------------------

   public static function fromString(value:*):HttpRequestMethod
   {
      var enum : HttpRequestMethod = Enum.fromString(HttpRequestMethod, value, false) as HttpRequestMethod;
      if(enum == null)
      {
         throw new ArgumentError("Cannot convert \"" + value + "\" into a HttpRequestMethod");
      }
      return enum;
   }
}

}
