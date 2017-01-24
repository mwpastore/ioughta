# Io(ugh)ta

[![Build Status](https://travis-ci.org/mwpastore/ioughta.svg?branch=master)](https://travis-ci.org/mwpastore/ioughta)
[![Gem Version](https://badge.fury.io/rb/ioughta.svg)](https://badge.fury.io/rb/ioughta)

Helpers for defining sequences of constants in Ruby using a Go-like syntax.

Go has quite a nice facility for defining constants derived from a sequential
value using a [simple and elegant syntax][1], so I thought I'd steal it for
Ruby. Rubyists tend to group constants together in hashes rather than littering
their programs with countless constants, so there's a mechanism for that, too.

Although there isn't as strong of a need for sequences of constants in Ruby as
there is in other languages such as Go, they are still sometimes required when
working with external systems such as databases and web APIs for which Ruby
symbols don't map cleanly. For example, a database column might store users'
privilege levels as 0, 1, or 2, and it would be useful to define constants that
map to those values. Ruby doesn't have a native expression for this construct
(other than simply defining them one at a time).

Here's a simple example, written in Go:

```go
type Allergen int

const (
    IgEggs Allergen = 1 << iota // 1 << 0 which is 00000001
    IgChocolate                 // 1 << 1 which is 00000010
    IgNuts                      // 1 << 2 which is 00000100
    IgStrawberries              // 1 << 3 which is 00001000
    IgShellfish                 // 1 << 4 which is 00010000
)
```

And here it is in Ruby, using ioughta:

```ruby
Object.ioughta_const(
  :IG_EGGS, ->(ioughta) { 1 << ioughta },
  :IG_CHOCOLATE,
  :IG_NUTS,
  :IG_STRAWBERRIES,
  :IG_SHELLFISH
)

IG_STRAWBERRIES # => 8
```

Or, perhaps a bit more Rubyishly:

```ruby
IG = Object.iota_hash(%i[
  eggs
  chocolate
  nuts
  strawberries
  shellfish
]) { |i| 1 << i }.freeze

IG[:shellfish] # => 16
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ioughta'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install ioughta
```

## Usage

Ioughta works just like `const` and `iota` do in Go, with only a few minor
differences. You must `include` the module in your program, class, or module in
order to start using it. The iterator starts at zero (0) and increments for
each constant (or hash key) being defined. A function (any Ruby callable) takes
the current iteration as input and returns the value to be assigned. The
default function simply returns the iterator, so you can easily create
sequences of constants with consecutive integer values:

```ruby
require 'ioughta'
include Ioughta

Object.ioughta_const(:FOO, :BAR, :QUX)

FOO # => 0
BAR # => 1
QUX # => 2
```

To skip value(s) in the sequence, use the `:_` symbol:

```ruby
Object.ioughta_const(:_, :FOO, :BAR, :_, :QUX)

FOO # => 1
BAR # => 2
QUX # => 4
```

As soon as Ioughta sees a lambda (or any Ruby callable), it will start using it
to generate future values from the iterator. You can redefine the lambda as
many times as you like:

```ruby
Object.ioughta_const(
  :A,                   # will use the default lambda  (0 =>   0)
  :B, ->(i) { i * 2 },  # will multiply by two         (1 =>   2)
  :C,                   # will also multiply by two    (2 =>   4)
  :D, ->(j) { j ** 3 }, # will cube                    (3 =>  27)
  :E,                   # will also cube               (4 =>  64)
  :F,                   # cube all the things          (5 => 125)
  :G, ->{ 0.5 }         # will use a simple value      (6 => 0.5)
  :H, proc(&:itself)    # restore the default behavior (7 =>   7)
)
```

You can also pass the lambda as the first argument:

```ruby
Object.ioughta_const ->(i) { 1 << (10 * i) }, %i[_ KiB MiB GiB TiB PiB EiB ZiB YiB]
```

Or even pass a block, instead of a lambda (it's the Ruby way!):

```ruby
UNITS = Object.ioughta_hash(%i[_ KB MB GB TB PB EB ZB YB]) { |i| 10 ** (i * 3) }.freeze
```

If the first argument is a lambda *and* a block is given, the block will be
silently ignored.

## Notes

The only major feature missing from the Go implementation is the ability to
perform parallel assignment in the constant list. We're defining a list of
terms, not a list of expressions, so it's not possible to do in Ruby without
resourcing to nasty `eval` tricks. **Don't forget to separate your terms with
commas and freeze your hash constants!**

You've probably noticed that in order to use Ioughta in the top-level
namespace, we need to explicitly specify the `Object` receiver (just like we
need to do for `#const_set`). I didn't want to get too crazy with the
monkey-patching and/or method delegation. No such limitation exists when
including Ioughta in a module or class, thanks to the available context. Also,
if the `ioughta_const` and `ioughta_hash` method names are too ugly for you (I
don't blame you), they're aliased as `iota_const` and `iota_hash`,
respectively.

Here is a very contrived and arbitrary example:

```ruby
require 'ioughta'

module MyFileUtils
  include Ioughta

  iota_const ->(b) { 1 << b }, %i[EXECUTE WRITE READ]
  iota_const ->(b) { 1 << b }, %i[TACKY SETGID SETUID]

  OFFSET = iota_hash(->(d) { d * 3 }, %i[other group user special]).freeze
  MASK = iota_hash(OFFSET.keys) { |_, key| 7 << OFFSET[key] }.freeze

  def self.mask_and_shift(mode, field)
    (mode & MASK[field]) >> OFFSET[field]
  end
end

MyFileUtils.mask_and_shift(0644, :user) & MyFileUtils::EXECUTE # => 0
MyFileUtils.mask_and_shift(01777, :special) & MyFileUtils::TACKY # => 1
```

One note on the above: the lambda (or block) can take the "key" at the current
iteration as an optional second argument.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Trivium

Pronounced /aɪ ˈɔtə/, as in the English phrase "Why, I oughta...!"

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/mwpastore/ioughta.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

[1]: https://splice.com/blog/iota-elegant-constants-golang/
