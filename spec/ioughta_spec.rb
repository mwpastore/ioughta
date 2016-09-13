require 'spec_helper'

describe Ioughta do
  it 'has a version number' do
    expect(Ioughta::VERSION).not_to be_nil
  end

  describe 'simple module constants' do
    before do
      module Foo
        include Ioughta

        ioughta_const :A, :B, :C
        BAR = ioughta_hash(:D, :E, :F).freeze

        ioughta_const :QUX, ->(a, b) { b }
      end
    end

    after do
      Object.send(:remove_const, :Foo)
    end

    it 'defines scalar constants' do
      expect(Foo::A).to eq(0)
      expect(Foo::B).to eq(1)
      expect(Foo::C).to eq(2)
    end

    it 'defines hash attributes' do
      expect(Foo::BAR).to eq(D: 0, E: 1, F: 2)
    end

    it 'aliases the methods' do
      expect(Foo.method(:iota_const)).to eq(Foo.method(:ioughta_const))
      expect(Foo.method(:iota_hash)).to eq(Foo.method(:ioughta_hash))
    end

    it 'allows the lambda to take an optional second argument' do
      expect(Foo::QUX).to eq(:QUX)
    end
  end

  describe 'complex module constants' do
    before do
      module Foo
        include Ioughta

        ioughta_const :_, :A, ->(i) { i ** 2 }, :B, :C
        BAR = ioughta_hash(:_, :D, ->(i) { i ** 3 }, :E, :F).freeze
      end
    end

    after do
      Object.send(:remove_const, :Foo)
    end

    it 'defines scalar constants' do
      expect(Foo::A).to eq(1 ** 2)
      expect(Foo::B).to eq(2 ** 2)
      expect(Foo::C).to eq(3 ** 2)
    end

    it 'defines hash attributes' do
      expect(Foo::BAR).to eq(D: 1 ** 3, E: 2 ** 3, F: 3 ** 3)
    end
  end

  describe 'multiple skips and lambdas' do
    before do
      module Foo
        include Ioughta

        ioughta_const \
          :A, :_,
          :B, ->(i) { i ** 2 }, :C, :_,
          :D, ->(j) { j ** 3 }, :E, :F, :_,
          :G, proc(&:itself)
      end
    end

    after do
      Object.send(:remove_const, :Foo)
    end

    it 'defines scalar constants' do
      expect(Foo::A).to eq(0)
      expect(Foo::B).to eq(2 ** 2)
      expect(Foo::C).to eq(3 ** 2)
      expect(Foo::D).to eq(5 ** 3)
      expect(Foo::E).to eq(6 ** 3)
      expect(Foo::F).to eq(7 ** 3)
      expect(Foo::G).to eq(9)
    end
  end

  describe 'it aliases the methods' do
    before do
      module Foo
        include Ioughta
      end
    end

    after do
      Object.send(:remove_const, :Foo)
    end
  end
end
