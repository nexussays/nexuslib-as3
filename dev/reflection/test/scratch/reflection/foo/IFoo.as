package foo
{
	
import foo.bar.TestClass;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
public interface IFoo
{
	[MetadataOnInterface(foo="foo")]
	function get publicProperty():int;
	function publicFun(param:TestClass, param2:Number = 556, param3:* = null):Vector.<*>;
}

}