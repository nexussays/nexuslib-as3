
private var m_baseString : String;
private var m_baseVector : Vector.<String>;
private var m_subObj1 : SubObject;
private var m_subObj2 : SubObject;

public var baseVar : int;
testing_namespace var baseVar : String = "";
private var m_enum : MockEnum;

[MethodMetadata(on="BaseClass")]
public function baseMethod(arg1:String, arg2:String="", arg3:Array=null):Object
{
	throw new NotImplementedError();
}

[PropertyMetadata(on="BaseClass", type="final")]
public final function get baseVector():Vector.<String> { return m_baseVector; }

[PropertyMetadata(on="BaseClass")]
public function get subObj1():SubObject { return m_subObj1; }
public function set subObj1(value:SubObject):void
{
	m_subObj1 = value;
}

public function get mockEnum():MockEnum { return m_enum; }
public function set mockEnum(value:MockEnum):void { m_enum = value; }

[PropertyMetadata(on="BaseClass")]
public function get subObj2():SubObject { return m_subObj2; }

[PropertyMetadata(on="BaseClass")]
public function get baseString():String{ return m_baseString; }
public function set baseString(value:String):void
{
	m_baseString = value;
}