package mock.foo.bar
{

import nexus.utils.serialization.json.IJsonSerializable;

public class CustomSerializationClass extends BaseClass implements IJsonSerializable
{
	private static var s_id : int = 1;
	static public function get id():int { return s_id; }
	
	public function CustomSerializationClass()
	{
		this.baseString = "CustomSerializationClass" + (++s_id);
	}
	
	public function toJSON(key:String):Object
	{
		return this.baseString;
	}
	
	public function jsonLikeType(data:Object):Boolean
	{
		return data is String;
	}
}

}