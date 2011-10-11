package  
{
	import flash.display.Shape;
	import nexus.utils.serialization.json.IJsonSerializable;
/**
 * ...
 * @author ...
 */
public class TestClass implements IJsonSerializable
{
	public static const STATIC_CONST : String = "foo";
	public const INSTANCE_CONST : String = "also foo";
	
	private var m_foo : Shape;
	private var m_bar : int;
	private var m_baz : Vector.<TestClass>;
	
	public function TestClass(bar:int = 2) 
	{
		m_foo = new Shape();
		m_bar = bar;
		m_baz = new Vector.<TestClass>();
		if(bar == 2)
		{
			m_baz[0] = new TestClass(m_bar +1);
		}
	}
	
	/* INTERFACE nexus.utils.serialization.json.IJsonSerializable */
	
	public function toJson():Object 
	{
		return { "baz":baz, "foo":foo };
	}
	
	public function jsonLikeType(data:Object):Boolean 
	{
		return "foo" in data && "baz" in data;
	}
	
	public function get foo():Shape  { return m_foo; }
	public function set foo(value:Shape):void 
	{
		m_foo = value;
	}
	
	public function get bar():int  { return m_bar; }
	
	public function get baz():Vector.<TestClass>  { return m_baz; }
	public function set baz(value:Vector.<TestClass>):void 
	{
		m_baz = value;
	}
}

}