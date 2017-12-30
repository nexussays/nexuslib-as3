package mock.foo.bar
{

import mock.foo.IFoo;
import mock.testing_namespace;

[ClassMetadata(param="value", on="TestClass")]
public dynamic class TestClass extends BaseClass implements IFoo
{
   //--------------------------------------
   //   CLASS CONSTANTS
   //--------------------------------------
   
   public static const staticConst:String = "staticConst";
   public static var staticVar:String = "staticVar";
   
   private static const privateStaticConst:String = "privateStaticConst";
   private static var privateStaticVar:String = "privateStaticVar";
   
   protected static const protectedStaticConst:String = "protectedStaticConst";
   protected static var protectedStaticVar:String = "protectedStaticvar";

   testing_namespace static const namespacedStaticConst:String = "namespacedStaticConst";
   testing_namespace static var namespacedStaticVar:String = "namespacedStaticvar";
   
   [Embed(source="test.xml", mimeType="application/octet-stream")]
   public static const embed : Class;
   
   //--------------------------------------
   //   INSTANCE VARIABLES
   //--------------------------------------
   
   private var m_privateVar:int;
   protected var m_protectedVar: int;
   testing_namespace var m_namespacedVar : int;

   private var m_circular:TestClass;
   
   [Embed(source="test.xml", mimeType="application/octet-stream")]
   public const instanceEmbed:Class;
   
   [FieldMetadata(on="TestClass", param="public var param")]
   public var publicVar:int;
   
   public namespace class_namespace = "mock.foo.bar::TestClass.class_namespace";
   
   //--------------------------------------
   //   CONSTRUCTOR
   //--------------------------------------
   
   [CtorMetadata(param="value", param2="value2")]
   public function TestClass(ctorArgReq:Boolean=true, ctorArgOpt:String=null)
   {
      
   }
   
   //--------------------------------------
   //   GETTER/SETTERS
   //--------------------------------------
   
   [FieldMetadata(param="value", param2="value2")]
   public function get publicProperty():int { return m_privateVar; }
   public function set publicProperty(value:int):void
   {
      m_privateVar = value;
   }
   
   public static function get staticProperty():String { return protectedStaticVar; }

   public function get circular():TestClass { return m_circular;}
   public function set circular(value:TestClass):void
   {
      m_circular = value;
   }
   
   //--------------------------------------
   //   PUBLIC INSTANCE METHODS
   //--------------------------------------
   
   override public function baseMethod(arg1:String, arg2:String="", arg3:Array=null):Object
   {
      return m_privateVar + arg1 + (arg2 != null ? arg2 : "");
   }
   
   [MethodMetadata(on="TestClass", type="final function")]
   public final function publicFinalFun(arg1:Vector.<String>):*
   {
      return "";
   }
   
   public function publicFun(arg1:Date, arg2:Number=556, arg3:*=null):String
   {
      return arg2 == 556 ? "default" : "provided";
   }
   
   //--------------------------------------
   //   PUBLIC CLASS METHODS
   //--------------------------------------
   
   public static function foo():void
   {
   
   }
   
   //--------------------------------------
   //   PRIVATE & PROTECTED INSTANCE METHODS
   //--------------------------------------
   
   protected function protectedMethod(p1:int, p2:String):void
   {
   
   }
   
   //--------------------------------------
   //   INTERNAL & NAMESPACED INSTANCE METHODS
   //--------------------------------------
   
   [MethodMetadata(on="TestClass", type="namespaced method")]
   testing_namespace function namespacedMethod(arg1:String, arg2:String=null, arg3:Vector.<int>=null):Object
   {
      return m_privateVar + arg1 + (arg2 != null ? arg2 : "");
   }
}

}
