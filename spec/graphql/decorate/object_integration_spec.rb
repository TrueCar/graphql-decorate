# frozen_string_literal: true

require 'spec_helper'

describe GraphQL::Decorate::ObjectIntegration do
  let(:type) do
    Class.new(BaseObject) do
      decorate_with Decorator
      decorate_metadata do |metadata|
        metadata.unscoped do |object|
          object.is_a?(Hash) ? 'hash context' : 'string context'
        end
        metadata.scoped do |object|
          object.is_a?(Hash) ? 'hash context' : 'string context'
        end
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

  it 'sets a decorator metadata proc on the type class' do
    expect(type.decorator_metadata.unscoped_proc.call({})).to eq('hash context')
  end

  it 'sets a scoped decorator metadata proc on the type class' do
    expect(type.decorator_metadata.scoped_proc.call('foo')).to eq('string context')
  end
end
