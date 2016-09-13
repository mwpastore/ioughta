# frozen_string_literal: true
require 'ioughta/version'

module Ioughta
  def self.included(base)
    class << base
      def ioughta_const(*data, &block)
        each_resolved_pair(pair(data, &block)) do |nom, val|
          const_set(nom, val)
        end
      end

      alias_method :iota_const, :ioughta_const

      def ioughta_hash(*data, &block)
        each_resolved_pair(pair(data, &block)).to_h
      end

      alias_method :iota_hash, :ioughta_hash

      private

      DEFAULT_LAMBDA = proc(&:itself)
      SKIP_SYMBOL = :_

      def lazy_iota
        (0..Float::INFINITY).lazy
      end

      def pair(data, &block)
        data = data.flatten
        lam =
          if block
            block
          elsif data.first.respond_to?(:call)
            data.shift
          else
            DEFAULT_LAMBDA
          end

        lazy_iota.each do |i|
          if i % 2 != 0
            if data[i].respond_to?(:call)
              lam = data[i]
            else
              data.insert(i, lam)
            end
          elsif data[i].nil?
            break
          end
        end
        data
      end

      def each_resolved_pair(data)
        return enum_for(:each_resolved_pair, data) unless block_given?

        data.each_slice(2).with_object(lazy_iota) do |(nom, lam), iota|
          val = lam.arity == 2 ? lam.call(iota.next, nom) : lam.call(iota.next)
          next if nom == SKIP_SYMBOL
          yield nom, val
        end
      end
    end
  end
end
