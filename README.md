# Io(ugh)ta

[![Build Status](https://travis-ci.org/mwpastore/ioughta.svg?branch=master)](https://travis-ci.org/mwpastore/ioughta)
[![Gem Version](https://badge.fury.io/rb/ioughta.svg)](https://badge.fury.io/rb/ioughta)

Helpers for defining Go-like constants and hashes in Ruby using iota.

Go has quite a nice facility for defining constants derived from a sequential
value using a [simple and elegant syntax][1], so I thought I'd steal it for
Ruby. Rubyists tend to group constants together in hashes rather than littering
their programs with countless constants, so there's a mechanism for that, too.

Here's an example, written in Go:

```go
type Allergen int

const (
    IgEggs Allergen = 1 << iota   // 1 << 0 which is 00000001
    IgChocolate                   // 1 << 1 which is 00000010
    IgNuts                        // 1 << 2 which is 00000100
    IgStrawberries                // 1 << 3 which is 00001000
    IgShellfish                   // 1 << 4 which is 00010000
)
```

Here it is in Ruby, using ioughta:

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

Or, perhaps a little more Rubyishly:

```ruby
IG = Object.ioughta_hash(
  :eggs, ->(i) { 1 << i },
  :chocolate,
  :nuts,
  :strawberries,
  :shellfish
).freeze

IG[:strawberries] # => 8
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
order to start using it. The iterator starts at zero (`0`) and increments for
each constant. The default lambda is simply `:itself`, so you can very easily
create a sequence of constants with consecutive integer values:

```ruby
require 'ioughta'
include Ioughta

Object.ioughta_const(:FOO, :BAR, :QUX)

QUX # => 2
```

To skip value(s) in the sequence, use the `:_` symbol:

```ruby
Object.ioughta_const(:_, :FOO, :BAR, :_, :QUX)

QUX # => 4
```

As soon as Ioughta sees a lambda, it will start using it to generate future
values from the iterator. In Go parlance, this is (apparently) known as
*implicit repetition of the last non-empty expression list*. You can redefine
the lambda as many times as you like:

```ruby
Object.ioughta_const(
  :A,                   # will use the default lambda  (0 =>   0)
  :B, ->(i) { i * 2 },  # will multiply by two         (1 =>   2)
  :C,                   # will also multiply by two    (2 =>   4)
  :D, ->(j) { j ** 3 }, # will cube                    (3 =>  27)
  :E,                   # will also cube               (4 =>  64)
  :F,                   # cube all the things          (5 => 125)
  :G, proc(&:itself)    # restore the default behavior (6 =>   6)
)
```

You can also pass the lambda as the first argument:

```ruby
Object.ioughta_const ->(i) { 1 << (10 * i) }, %i[_ KB MB GB TB PB EB ZB YB]
```

Or even a block, instead of a lambda:

```ruby
BYTES = Object.ioughta_hash(%i[_ KB MB GB TB PB EB ZB YB]) { |i| 1 << (10 * i) }
```

The only major feature missing from the Go implementation is the ability to
perform parallel assignment in the constant list. We're defining a list of
terms, not a list of expressions, so it's not possible to do in Ruby without
resourcing to nasty `eval` tricks. Don't forget to separate your terms with
commas!

You've probably noticed that in order to use Ioughta in the top-level
namespace, we need to explicitly specify the `Object` receiver (just like we
need to do for `#const_set`). I didn't want to get too crazy with the
monkeypatching and/or dynamic dispatch. No such limitation exists when
including Ioughta in a module or class, thanks to the available context. Also,
if the `ioughta_const` and `ioughta_hash` methods are too ugly for you (I don't
blame you), they're aliased as `iota_const` and `iota_hash`, respectively.

Here is a very contrived and arbitrary example:

```ruby
require 'ioughta'

module MyFileUtils
  include Ioughta

  iota_const :EXECUTE, ->(b) { 0b1 << b }, :WRITE, :READ
  iota_const :TACKY, ->(b) { 0b1 << b }, :SETGID, :SETUID

  SHIFT = iota_hash(:other, ->(d) { d * 3 }, :group, :user, :special).freeze
  MASK = iota_hash(:other, ->(_o, key) { 07 << SHIFT[key] }, :group, :user, :special).freeze

  def self.mask_and_shift(mode, field)
    (mode & MASK[field]) >> SHIFT[field]
  end
end

MyFileUtils.mask_and_shift(0644, :user) & MyFileUtils::EXECUTE # => 0
MyFileUtils.mask_and_shift(01777, :special) & MyFileUtils::TACKY # => 1
```

One note on the above: the lambda can take the key at the current iteration as
an optional second argument.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/mwpastore/ioughta.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

[1]: https://splice.com/blog/iota-elegant-constants-golang/
