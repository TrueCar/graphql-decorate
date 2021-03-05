# frozen_string_literal: true

require 'spec_helper'

describe GraphQL::Decorate::ObjectIntegration do
  let(:type) do
    Class.new(BaseObject) do
      decorate_with Decorator
      decorator_metadata do |object|
        object.is_a?(Hash) ? 'hash context' : 'string context'
      end
      scoped_decorator_metadata do |object|
        object.is_a?(Hash) ? 'hash context' : 'string context'
      end
    end
  end

  it 'sets a decorator class on the type class' do
    expect(type.decorator_class).to eq(Decorator)
  end

  context 'when decorate_when recieves a block' do
    let(:type) do
      Class.new(BaseObject) do
        decorate_with do |object|
          object.is_a?(Hash) ? 'hash' : 'string'
        end
      end
    end

    it 'sets a decorator evaluator on the context' do
      expect(type.decorator_evaluator.call('foo')).to eq('string')
    end
  end

  it 'sets a decorator context evaluator on the type class' do
    expect(type.metadata_evaluator.call({})).to eq('hash context')
  end

  it 'sets a scoped decorator context evaluator on the type class' do
    expect(type.metadata_evaluator.call('foo')).to eq('string context')
  end
end
