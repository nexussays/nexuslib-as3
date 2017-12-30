package mock.foo.bar
{

import mock.foo.SubObject;
import mock.MockEnum;
import mock.testing_namespace;
import nexus.Enum;
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
