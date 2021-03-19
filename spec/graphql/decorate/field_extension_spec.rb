# frozen_string_literal: true

require 'spec_helper'

describe GraphQL::Decorate::FieldExtension do
  subject(:field_extension) do
    described_class.new(field: field, options: {}).after_resolve(context: context, object: object, value: value)
  end

  shared_examples('decorated value') do |decorator_class|
    it 'decorates the value provided using the class in the options' do
      expect(field_extension).to be_a(decorator_class)
    end

    it 'sets the value on the decorator' do
      expect(field_extension.object).to eq(value)
    end
  end

  shared_examples('decorated array') do |decorator_class|
    it 'is an Array' do
      expect(field_extension).to be_an(Array)
    end

    it 'decorates the value provided using the class in the options' do
      expect(field_extension.first).to be_a(decorator_class)
    end

    it 'sets the value on the decorator' do
      expect(field_extension.first.object).to eq(value.first)
    end
  end

  shared_examples('undecorated value') do
    it 'decorates the value provided using the class in the options' do
      expect(field_extension).not_to be_a(Decorator)
    end

    it 'sets the value on the decorator' do
      expect(field_extension).to eq(value)
    end
  end

  shared_examples('undecorated array') do
    it 'is an Array' do
      expect(field_extension).to be_an(Array)
    end

    it 'decorates the value provided using the class in the options' do
      expect(field_extension.first).not_to be_a(Decorator)
    end

    it 'sets the value on the decorator' do
      expect(field_extension.first).to eq(value.first)
    end
  end

  let(:type) { PostType }
  let(:field) { nil }
  let(:context) do
    GraphQL::Query::Context.new(query: GraphQL::Query.new(Schema),
                                values: { current_field: instance_double('field', type: type), current_path: [] },
                                object: nil)
  end
  let(:object) { BlogType.send(:new, { name: 'My Blog', active: true }, context) }

  context 'when the value being resolved is a single object' do
    let(:value) { { first_name: 'Bob', last_name: 'Boberson', published: true } }

    it_behaves_like 'decorated value', PostDecorator

    context 'when using a different decorator setup' do
      before do
        GraphQL::Decorate.configure do |config|
          config.decorate do |decorator_class, object, metadata|
            decorator_class.new(object, context: metadata)
          end
        end
      end

      after { GraphQL::Decorate.reset_configuration! }

      it_behaves_like 'decorated value', PostDecorator
    end

    context 'when resolving the type at runtime with a decorator class' do
      let(:type) { Icon }
      let(:value) { {} }

      it_behaves_like 'decorated value', MissingDecorator
    end

    context 'when resolving the type with a decorator class evaluator' do
      let(:type) { Icon }
      let(:value) { { url: 'https://www.image.com' } }

      it_behaves_like 'decorated value', ImageDecorator
    end

    context 'when resolving the type without a decorator class' do
      let(:type) { Icon }
      let(:value) { { file_path: '/path/to/file' } }

      it_behaves_like 'undecorated value'
    end

    context 'when resolving the value with a decorator evaluator and a matching object' do
      let(:type) { CommentType }
      let(:value) { { verified_user: true, message: 'My comment 1' } }

      it_behaves_like 'decorated value', VerifiedCommentDecorator
    end

    context 'when resolving the value with a decorator evaluator and without a matching object' do
      let(:type) { CommentType }

      it_behaves_like 'undecorated value'
    end

    it 'adds graphql to the decorator metadata' do
      expect(field_extension.context).to include(graphql: true)
    end

    context 'when a decorator metadata evaluator is provided' do
      let(:type) { PostType }

      it 'populates decorator metadata using the evaluated data' do
        custom_context = type.decorator_metadata.unscoped_proc.call(value, {})
        expect(field_extension.context).to include({ graphql: true }.merge(custom_context))
      end
    end
  end

  context 'when the value being resolved is a collection' do
    let(:value) { [{ first_name: 'Bob', last_name: 'Boberson', published: true }] }

    it_behaves_like 'decorated array', PostDecorator

    context 'when using a different decorator setup' do
      before do
        GraphQL::Decorate.configure do |config|
          config.decorate do |decorator_class, object, metadata|
            decorator_class.new(object, context: metadata)
          end
        end
      end

      after { GraphQL::Decorate.reset_configuration! }

      it_behaves_like 'decorated array', PostDecorator
    end

    context 'when resolving the type at runtime with a decorator class' do
      let(:type) { Icon }
      let(:value) { [{}] }

      it_behaves_like 'decorated array', MissingDecorator
    end

    context 'when resolving the type at runtime with a decorator class evaluator' do
      let(:type) { Icon }
      let(:value) { [{ url: 'https://www.image.com' }] }

      it_behaves_like 'decorated array', ImageDecorator
    end

    context 'when resolving the type at runtime without a decorator class' do
      let(:type) { Icon }
      let(:value) { [{ file_path: '/path/to/file' }] }

      it_behaves_like 'undecorated array'
    end

    context 'when decorating an ActiveRecord::Relation' do
      let(:value) { ActiveRecord::Relation.new([{ first_name: 'Bob', last_name: 'Boberson', published: true }]) }

      it_behaves_like 'decorated array', PostDecorator
    end

    context 'when using a custom collection class from the configuration' do
      before do
        GraphQL::Decorate.configure do |config|
          config.custom_collection_classes << CustomCollection
        end
      end

      let(:value) { CustomCollection.new([{ first_name: 'Bob', last_name: 'Boberson', published: true }]) }

      it_behaves_like 'decorated array', PostDecorator
    end

    context 'when resolving the value with a decorator evaluator and a matching object' do
      let(:type) { CommentType }
      let(:value) do
        [{ verified_user: true, message: 'My comment 1' }, { verified_user: false, message: 'My comment 2' }]
      end

      it 'decorates the first item as a VerifiedCommentDecorator' do
        expect(field_extension[0]).to be_a(VerifiedCommentDecorator)
      end

      it 'decorates the second item as an UnverifiedCommentDecorator' do
        expect(field_extension[1]).to be_a(UnverifiedCommentDecorator)
      end

      it 'sets the value on the first decorator' do
        expect(field_extension[0].object).to eq(value[0])
      end

      it 'sets the value on the second decorator' do
        expect(field_extension[1].object).to eq(value[1])
      end
    end

    context 'when the resolved object does not match' do
      let(:type) { CommentType }
      let(:value) { [{ message: 'My comment 1' }] }

      it_behaves_like 'undecorated array'
    end

    context 'when decorator metadata is provided' do
      let(:type) { PostType }

      it 'populates decorator metadata using the evaluated data' do
        custom_context = type.decorator_metadata.unscoped_proc.call(value.first, {})
        expect(field_extension.first.context).to include({ graphql: true }.merge(custom_context))
      end
    end
  end

  context 'when the value is nil' do
    let(:value) { nil }

    it { is_expected.to be_nil }
  end
end
