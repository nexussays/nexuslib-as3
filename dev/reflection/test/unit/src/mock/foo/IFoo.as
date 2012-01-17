package mock.foo
{

public interface IFoo
{
	[MetadataOnInterface(foo="foo")]
	function get publicProperty():int;
	function publicFun(param:Date, param2:Number = 556, param3:* = null):Vector.<*>;
}

}