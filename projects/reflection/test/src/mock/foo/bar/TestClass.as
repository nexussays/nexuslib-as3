package mock.foo.bar
{

import mock.foo.IFoo;
import mock.testing_namespace;

[ClassMetadata(param="value", param2="value2")]
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
	
	public static function get staticProperty():Vector.<ArgumentError>
	{
		return null;
	}
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_privateVar:int;
	protected var m_protectedVar: Class;
	
	[Embed(source='test.xml', mimeType='application/octet-stream')]
	public const instanceEmbed:Class;
	
	public const publicConst: String = "name";
	
	[FieldMetadata(className="datamodel.schemas::CookingComponents",source="components")]
	public var publicVar:int;
	
	public namespace foo_namespace = "foo.testing_namespace";
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	[CtorMetadata(param="value", param2="value2")]
	public function TestClass(ctorArgReq:Boolean=true, ctorArgOpt:String=null)
	{
		
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get publicProperty():int
	{
		return m_privateVar;
	}
	
	[FieldMetadata(param="value", param2="value2")]
	public function set publicProperty(value:int):void
	{
		m_privateVar = value;
	}
	
	[bazbazbaz(param="value", param2="value2")]
	testing_namespace function namespacedMethod(test:String, foo:*=null):Object
	{
		return m_privateVar + test + (foo != null ? foo : "");
	}
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	override public function baseMethod(arg1:*, arg2:Object):Date
	{
		return super.baseMethod(arg1, arg2);
	}
	
	[RandomMetadata(param="value", param2="value2")]
	public final function publicFinalFun(param:Vector.<String>):*
	{
		trace("publicFinalFun");
		return "";
	}
	
	public function publicFun(param:Date, param2:Number=556, param3:*=null):Vector.<*>
	{
		trace("publicFun", param.getTime() == (new Date()).getTime() ? "param is self" : "param is other instance", param2);
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