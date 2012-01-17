package foo.pkg
{
	import nexus.utils.serialization.json.IJsonSerializable;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	10/28/2011 12:38 AM
 */
public class TestSub //implements IJsonSerializable
{
	private var m_foo : String;
	
	public function TestSub()
	{
		
	}
	
	/* INTERFACE nexus.utils.serialization.json.IJsonSerializable */
	
	//public function toJSON(key:String):Object
	//{
		//return foo;
	//}
	//
	//public function jsonLikeType(data:Object):Boolean
	//{
		//return data is String;
	//}
	
	public function get foo():String
	{
		return m_foo;
	}
	
	public function set foo(value:String):void
	{
		m_foo = value;
	}
}

}