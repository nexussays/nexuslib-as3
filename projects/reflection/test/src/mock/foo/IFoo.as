package mock.foo
{

public interface IFoo
{
	[MetadataOnInterface(foo="foo")]
	function get publicProperty():int;
	
	function publicFun(arg1:Date, arg2:Number = 556, arg3:*= null):String;
}

}