# puppet-module-facter

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
1. [Setup - The basics of getting started with facter](#setup)
   * [What facter affects](#what-facter-affects)
   * [Beginning with facter](#beginning-with-facter)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Module description

This module manages facter, specifically the facts.d directory, symlinks
to facter that are in your PATH and the ability to define external
facts.

## Setup

### What facter affects

Ensure that `/etc/facter/facts.d` exists with the correct permissions
and populate it with `facts.txt` which is used for external facts. It
can optionally create a symlink such as `/usr/local/bin/facter` to point
to facter in the puppet package that may not be in your `$PATH`.

It has a defined type that allows for specifying external facts. This
allows you to seed already known information on the system.

### Beginning with facter

Declare the main class as demonstrated below.

## Usage

You can manage all interaction with facter through the main `facter`
class. To specify external facts, use the `facter::fact` defined type.

You can optionally specify a hash of external facts in Hiera.

```yaml
---
facter::facts_hash:
  role:
    value: 'puppetmaster'
  location:
    value: 'RNB'
    file: 'location.txt'
```

The above configuration in Hiera would produce
`/etc/facter/facts.d/facts.txt` with the following content.

```
role=puppetmaster
```

It would also produce `/etc/facter/facts.d/location.txt` with the following content.

```
location=RNB
```

### Minimum usage

```puppet
include facter
```

### Parameters for configuration

Please consult the `REFERENCE.md` file for all parameters.

## Limitations

This module is compatible with the latest release of Puppet versions 5
and 6. It supports all POSIX like platforms as well as Windows. See
`.travis.yml` for an exact matrix of tested Ruby and Puppet versions.

## Development

See `CONTRIBUTING.md` for information related to the development of this
module.
