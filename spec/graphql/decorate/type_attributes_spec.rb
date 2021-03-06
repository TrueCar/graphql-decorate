# frozen_string_literal: true

require 'spec_helper'

describe GraphQL::Decorate::TypeAttributes do
  subject(:type_attributes) { described_class.new(type) }

  context 'when given a scalar type' do
    let(:type) { String }

    it 'has no decorator class' do
      expect(type_attributes.decorator_class).to be_nil
    end

    it 'has no decorator evaluator' do
      expect(type_attributes.decorator_evaluator).to be_nil
    end

    it 'has no metadata evaluator' do
      expect(type_attributes.metadata_evaluator).to be_nil
    end

    it 'has no scoped metadata evaluator' do
      expect(type_attributes.scoped_metadata_evaluator).to be_nil
    end

    it 'has no unresolved type' do
      expect(type_attributes.unresolved_type).to be_nil
    end

    it 'is not a resolved type' do
      expect(type_attributes).not_to be_unresolved_type
    end

    it 'is a resolved type' do
      expect(type_attributes).to be_resolved_type
    end

    it 'is not a connection' do
      expect(type_attributes).not_to be_connection
    end
  end

  context 'when given an undecorated type' do
    let(:type) { BaseObject }

    it 'has no decorator class' do
      expect(type_attributes.decorator_class).to be_nil
    end

    it 'has no decorator evaluator' do
      expect(type_attributes.decorator_evaluator).to be_nil
    end

    it 'has no metadata evaluator' do
      expect(type_attributes.metadata_evaluator).to be_nil
    end

    it 'has no scoped metadata evaluator' do
      expect(type_attributes.scoped_metadata_evaluator).to be_nil
    end

    it 'has no unresolved type' do
      expect(type_attributes.unresolved_type).to be_nil
    end

    it 'is not a resolved type' do
      expect(type_attributes).not_to be_unresolved_type
    end

    it 'is a resolved type' do
      expect(type_attributes).to be_resolved_type
    end

    it 'is not a connection' do
      expect(type_attributes).not_to be_connection
    end
  end

  context 'when given a decorated type' do
    let(:type) { PostType }

    it 'has no decorator class' do
      expect(type_attributes.decorator_class).to eq(PostType.decorator_class)
    end

    it 'has no decorator evaluator' do
      expect(type_attributes.decorator_evaluator).to eq(PostType.decorator_evaluator)
    end

    it 'has no metadata evaluator' do
      expect(type_attributes.metadata_evaluator).to eq(PostType.metadata_evaluator)
    end

    it 'has no scoped metadata evaluator' do
      expect(type_attributes.scoped_metadata_evaluator).to eq(PostType.scoped_metadata_evaluator)
    end

    it 'has no unresolved type' do
      expect(type_attributes.unresolved_type).to be_nil
    end

    it 'is not a resolved type' do
      expect(type_attributes).not_to be_unresolved_type
    end

    it 'is a resolved type' do
      expect(type_attributes).to be_resolved_type
    end

    it 'is not a connection' do
      expect(type_attributes).not_to be_connection
    end
  end

  context 'when given a connection type' do
    let(:type) { PostType.connection_type }

    it 'has no decorator class' do
      expect(type_attributes.decorator_class).to eq(PostType.decorator_class)
    end

    it 'has no decorator evaluator' do
      expect(type_attributes.decorator_evaluator).to eq(PostType.decorator_evaluator)
    end

    it 'has no metadata evaluator' do
      expect(type_attributes.metadata_evaluator).to eq(PostType.metadata_evaluator)
    end

    it 'has no scoped metadata evaluator' do
      expect(type_attributes.scoped_metadata_evaluator).to eq(PostType.scoped_metadata_evaluator)
    end

    it 'has no unresolved type' do
      expect(type_attributes.unresolved_type).to be_nil
    end

    it 'is not a resolved type' do
      expect(type_attributes).not_to be_unresolved_type
    end

    it 'is a resolved type' do
      expect(type_attributes).to be_resolved_type
    end

    it 'is not a connection' do
      expect(type_attributes).to be_connection
    end
  end

  context 'when given an unresolved type' do
    let(:type) { Icon }

    it 'has no decorator class' do
      expect(type_attributes.decorator_class).to be_nil
    end

    it 'has no decorator evaluator' do
      expect(type_attributes.decorator_evaluator).to be_nil
    end

    it 'has no metadata evaluator' do
      expect(type_attributes.metadata_evaluator).to be_nil
    end

    it 'has no scoped metadata evaluator' do
      expect(type_attributes.scoped_metadata_evaluator).to be_nil
    end

    it 'has no unresolved type' do
      expect(type_attributes.unresolved_type).to eq(Icon)
    end

    it 'is not a resolved type' do
      expect(type_attributes).to be_unresolved_type
    end

    it 'is a resolved type' do
      expect(type_attributes).not_to be_resolved_type
    end

    it 'is not a connection' do
      expect(type_attributes).not_to be_connection
    end
  end
end
