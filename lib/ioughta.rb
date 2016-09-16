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

      def pair(data, &block)
        data = data.flatten(1)
        lam = (data.shift if data[0].respond_to?(:call)) || block || DEFAULT_LAMBDA

        data.map.with_index do |nom, i, j = i.succ|
          [nom, data[j].respond_to?(:call) ? lam = data.slice!(j) : lam]
        end
      end

      def each_resolved_pair(data)
        return enum_for(__method__, data) do
          data.count { |nom, | nom != SKIP_SYMBOL }
        end unless block_given?

        data.each_with_index do |(nom, lam), iota|
          val = lam[*[iota, nom].take(lam.arity.abs)]
          next if nom == SKIP_SYMBOL
          yield nom, val
        end
      end
    end
  end
end
