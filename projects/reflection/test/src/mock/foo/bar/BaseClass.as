package mock.foo.bar
{

import mock.testing_namespace;
import nexus.errors.NotImplementedError;

[ClassMetadata(on="BaseClass")]
public class BaseClass
{
	private var m_baseString : String;
	
	public var baseVar : int;
	testing_namespace var baseVar : String;
	
	public function BaseClass()
	{
	
	}
	
	[MethodMetadata(on="BaseClass")]
	public function baseMethod(arg1:String, arg2:String="", arg3:Array=null):Object
	{
		throw new NotImplementedError();
	}
	
	[PropertyMetadata(on="BaseClass")]
	public function get baseString():String{ return m_baseString; }
	public function set baseString(value:String):void
	{
		m_baseString = value;
	}
}

}