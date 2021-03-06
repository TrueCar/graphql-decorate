# frozen_string_literal: true

module ActiveRecord
  class Relation
    def initialize(collection)
      @collection = collection
    end

    def map(&block)
      @collection.map(&block)
    end

    def first
      @collection.first
    end
  end
end
