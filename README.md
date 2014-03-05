# Overview

nexuslib is a collection of (in-development) Actionscript libraries.

The reflection library is production ready and is currently in-use in production environments.

## Getting Started

Download the [latest release](https://github.com/nexussays/nexuslib-as3/releases), or clone the repo and reference in your project.

### Dependencies

blooddy-crypto (statically linked with nexuslib.swc)

### API Docs

http://docs.nexussays.com/nexuslib/index.html

## Components

### Reflection & Serialization

`nexus.utils.reflection`, `nexus.utils.serialization`

Reflection & serialization library. Features deterministic JSON de/serialization, deserializing directly to typed AS objects, a structured reflection class heirarchy, and more. Full support for Application Domains and namespaces.

### Enigma

`nexus.security.crypto`

Crypto & security library. Currently only provides an HMAC class and some utilities.

### Mercury

`nexus.net`

In development.

### Git

`nexus.vcs.git`

see: https://github.com/nexussays/git-as3
