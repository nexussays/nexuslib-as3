package
{
import flash.display.Shape;
import flash.utils.Dictionary;
import nexus.utils.serialization.json.IJsonSerializable;
/**
 * ...
 * @author ...
 */
public class TestClass// implements IJsonSerializable
{
	public static const STATIC_CONST : String = "sc";
	public const INSTANCE_CONST : String = "ic";
	
	private var m_foo : Shape;
	private var m_bar : int;
	private var m_baz : Vector.<String>;
	private var m_d : Dictionary;
	public var date : Date;
	
	private var m_sub : TestSub;
	
	[Transient]
	public var reg : RegExp = /test\\\(regex\).?(?:\d)*[a-zA-Z]$/g;
	
	public function TestClass(bar:int = 2)
	{
		date = new Date();
		date.setFullYear(1983, 9, 25);
		m_foo = new Shape();
		m_bar = bar;
		m_baz = new Vector.<String>();
		m_baz[0] = "foo";
		m_baz[1] = "value 2";
		m_baz[2] = "value 3";
		m_d = new Dictionary();
		m_d["foo"] = "foo";
		m_d["Fop"] = "Fop";
		m_d["z"] = "z";
		
		m_sub = new TestSub();
		m_sub.foo = Math.random() + "";
	}
	
	/* INTERFACE nexus.utils.serialization.json.IJsonSerializable */
	
	//public function toJSON(key:String):Object
	//{
		//trace("key", key);
		//return {"baz":baz};
	//}
	
	public function jsonLikeType(data:Object):Boolean
	{
		return "baz" in data;
	}
	
	//public function get foo():Shape  { return m_foo; }
	public function set foo(value:Shape):void
	{
		m_foo = value;
	}
	
	public function get bar():int  { return m_bar; }
	public function set bar(value:int):void
	{
		m_bar = value;
	}
	
	public function get baz():Vector.<String>  { return m_baz; }
	
	public function get zdict():Dictionary { return m_d; }
	public function set zdict(value:Dictionary):void
	{
		m_d = value;
	}
	
	public function get sub():TestSub
	{
		return m_sub;
	}
}

}