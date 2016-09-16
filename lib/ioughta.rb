# frozen_string_literal: true
require 'ioughta/version'

module Ioughta
  def self.included(base)
    class << base
      def ioughta_const(*data, &block)
        each_resolved_pair(data, block) do |nom, val|
          const_set(nom, val)
        end
      end

      alias_method :iota_const, :ioughta_const

      def ioughta_hash(*data, &block)
        each_resolved_pair(data, block).to_h
      end

      alias_method :iota_hash, :ioughta_hash

      private

      DEFAULT_LAMBDA = proc(&:itself)
      SKIP_SYMBOL = :_

      def each_pair_with_index(data, block = nil)
        return enum_for(__method__, data, block) unless block_given?

        data = data.to_a.flatten(1)
        lam = (data.shift if data[0].respond_to?(:call)) || block || DEFAULT_LAMBDA

        data.each_with_index do |nom, i, j = i.succ|
          yield nom, data[j].respond_to?(:call) ? lam = data.slice!(j) : lam, i
        end
      end

      def each_resolved_pair(*args)
        return enum_for(__method__, *args) unless block_given?

        each_pair_with_index(*args) do |nom, lam, iota|
          yield nom, lam[*[iota, nom].take(lam.arity.abs)] unless nom == SKIP_SYMBOL
        end
      end
    end
  end
end
