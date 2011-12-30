package foo.bar
{

import flash.globalization.DateTimeFormatter;
import flash.utils.*;

import foo.*;

import nexus.utils.serialization.*;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since 7/28/2011 8:46 PM
 */
[classMetadata(param="value", param2="value2")]
public dynamic class TestClass extends BaseClass implements IFoo
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	public static const staticConst:String = "staticConst";
	public static var staticVar:String = "staticVar";
	
	private static const pvtStaticConst:String = "pvtStaticConst";
	private static var pvtStaticVar:String = "pvtStaticVar";
	
	[Embed(source='test.xml', mimeType='application/octet-stream')]
	public static const embed : Class;
	
	public static function get staticProperty():ISerializer
	{
		return null;
	}
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_privateVar:int;
	protected var m_protectedVar: Class;
	
	[Embed(source = 'test.xml', mimeType = 'application/octet-stream')]
	public const instanceEmbed:Class;
	
	public const publicConst: String = "name";
	
	[CMSComponentSet(className="datamodel.schemas::CookingComponents",source="components")]
	public var publicVar:int;
	
	public namespace foo_namespace = "foo.special_namespace";
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	[ctorMetadata(param="value", param2="value2")]
	public function TestClass(ctorArgReq:Boolean, ctorArgOpt:String=null)
	{
		
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get publicProperty():int
	{
		return m_privateVar;
	}
	
	[blargh(param="value", param2="value2")]
	public function set publicProperty(value:int):void
	{
		m_privateVar = value;
	}
	
	[bazbazbaz(param="value", param2="value2")]
	special_namespace function namespacedMethod(test:String, foo:*):Object
	{
		return null;
	}
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	override public function baseMethod(arg1:*, arg2:Object):DateTimeFormatter
	{
		return super.baseMethod(arg1, arg2);
	}
	
	[RandomMetadata(param="value", param2="value2")]
	public final function publicFinalFun(param:Vector.<String>):*
	{
		trace("publicFinalFun");
		return "";
	}
	
	public function publicFun(param:TestClass, param2:Number=556, param3:*=null):Vector.<*>
	{
		trace("publicFun", param == this ? "param is self" : "param is other instance", param2);
		return null;
	}
	
	public static function foo():void
	{
	
	}
	
	//--------------------------------------
	//	EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
	protected function protectedMethod(p1:int, p2:String):void
	{
	
	}
}

}