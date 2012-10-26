package mock.foo.bar
{

import mock.foo.SubObject;
import mock.testing_namespace;
import nexus.errors.NotImplementedError;

[ClassMetadata(on="DynamicBaseClass")]
dynamic public class DynamicBaseClass
{
	include "_BaseClassContent.as";
	
	public function DynamicBaseClass()
	{
		m_baseVector = new Vector.<String>();
		m_subObj2 = new SubObject();
	}
}

}