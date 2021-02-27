# frozen_string_literal: true
require 'spec_helper'

describe GraphQL::Decorate::TypeAttributes do
  subject { described_class.new(type) }

  context 'given a scalar type' do
    let(:type) { String }

    it 'returns nil or false to all queries except resolved_type?' do
      expect(subject.decorator_class).to eq(nil)
      expect(subject.decorator_evaluator).to eq(nil)
      expect(subject.decorator_context_evaluator).to eq(nil)
      expect(subject.unresolved_type).to eq(nil)
      expect(subject.unresolved_type?).to be_falsey
      expect(subject.resolved_type?).to be_truthy
      expect(subject.connection?).to be_falsey
    end
  end

  context 'given an undecorated type' do
    let(:type) { BaseObject }

    it 'returns nil or false to all queries except resolved_type?' do
      expect(subject.decorator_class).to eq(nil)
      expect(subject.decorator_evaluator).to eq(nil)
      expect(subject.decorator_context_evaluator).to eq(nil)
      expect(subject.unresolved_type).to eq(nil)
      expect(subject.unresolved_type?).to be_falsey
      expect(subject.resolved_type?).to be_truthy
      expect(subject.connection?).to be_falsey
    end
  end

  context 'given a decorated type' do
    let(:type) { DecoratedType }

    it 'returns as a resolved type with the attributes on the type class' do
      expect(subject.decorator_class).to eq(DecoratedType.decorator_class)
      expect(subject.decorator_evaluator).to eq(DecoratedType.decorator_evaluator)
      expect(subject.decorator_context_evaluator).to eq(DecoratedType.decorator_context_evaluator)
      expect(subject.unresolved_type).to eq(nil)
      expect(subject.unresolved_type?).to be_falsey
      expect(subject.resolved_type?).to be_truthy
      expect(subject.connection?).to be_falsey
    end
  end

  context 'given a connection type' do
    let(:type) { DecoratedType.connection_type }

    it 'returns as a resolved connection type with the attributes on the node type class' do
      expect(subject.decorator_class).to eq(DecoratedType.decorator_class)
      expect(subject.decorator_evaluator).to eq(DecoratedType.decorator_evaluator)
      expect(subject.decorator_context_evaluator).to eq(DecoratedType.decorator_context_evaluator)
      expect(subject.unresolved_type).to eq(nil)
      expect(subject.unresolved_type?).to be_falsey
      expect(subject.resolved_type?).to be_truthy
      expect(subject.connection?).to be_truthy
    end
  end

  context 'given an unresolved type' do
    let(:type) { DecoratedInterface }

    it 'returns as an unresolved type with no attributes' do
      expect(subject.decorator_class).to eq(nil)
      expect(subject.decorator_evaluator).to eq(nil)
      expect(subject.decorator_context_evaluator).to eq(nil)
      expect(subject.unresolved_type).to eq(DecoratedInterface)
      expect(subject.unresolved_type?).to be_truthy
      expect(subject.resolved_type?).to be_falsey
      expect(subject.connection?).to be_falsey
    end
  end
end
