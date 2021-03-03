# frozen_string_literal: true

require 'spec_helper'

describe GraphQL::Decorate::ObjectIntegration do
  let(:type) do
    Class.new(BaseObject) do
      decorate_with Decorator
      decorate_when do |object|
        object.is_a?(Hash) ? 'hash' : 'string'
      end
      decorator_context do |object|
        object.is_a?(Hash) ? 'hash context' : 'string context'
      end
    end
  end

  it 'sets a decorator class on the type class' do
    expect(type.decorator_class).to eq(Decorator)
  end

  it 'sets a decorator evaluator on the context' do
    expect(type.decorator_evaluator.call('foo')).to eq('string')
  end

  it 'sets a decorator context evaluator on the type class' do
    expect(type.decorator_context_evaluator.call({})).to eq('hash context')
  end
end
