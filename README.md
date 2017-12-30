# Overview

nexuslib is a collection of Actionscript libraries. Enums, Random, Reflection, Serialization, Crypto.

The reflection library specifically is production ready and is currently in-use in production environments.

## Getting Started

Download the [latest release](https://github.com/nexussays/nexuslib-as3/releases), or clone the repo and reference in your project.

### External Dependencies

None

> blooddy-crypto is statically linked with nexuslib.swc

### API Docs

http://docs.nexussays.com/nexuslib/index.html

## Components

### Enum & EnumSet

Since AS3 doesn't provide a native enum structure you can use this to ceate one thusly:
```as3
public class MyEnum extends Enum
{
   public static const Enum1 : MyEnum = new MyEnum();
   public static const Enum2 : MyEnum = new MyEnum();

   public static function get All():EnumSet { return Enum.values(MyEnum); }
}
```
For more examples of correct and incorrect Enum usage, see the [mocks in the test directory](./test/src/mock)

### Reflection & Serialization

`nexus.utils.reflection`, `nexus.utils.serialization`

Reflection & serialization library. Features deterministic JSON de/serialization, deserializing directly to typed AS objects, a structured reflection class heirarchy, and more. Full support for Application Domains and namespaces.

### Crypto & security

`nexus.security.crypto`

Currently only provides an HMAC class and some utilities.

### Version control (Git)

`nexus.vcs.git`

see: https://github.com/nexussays/git-as3
