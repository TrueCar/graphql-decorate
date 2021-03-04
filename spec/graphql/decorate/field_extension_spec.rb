# frozen_string_literal: true

require 'spec_helper'

describe GraphQL::Decorate::FieldExtension do
  let(:field) { nil }
  let(:options) { { decorator_class: PostDecorator } }
  let(:context) { GraphQL::Query::Context.new(query: GraphQL::Query.new(Schema), values: nil, object: nil) }
  let(:object) { BlogType.send(:new, { name: 'My Blog', active: true }, context) }
  subject { described_class.new(field: field, options: options).after_resolve(context: context, object: object, value: value) }

  context 'when the value being resolved is a single object' do
    let(:value) { { first_name: 'Bob', last_name: 'Boberson', published: true } }

    it 'decorates the value provided using the class in the options' do
      expect(subject).to be_a(PostDecorator)
      expect(subject.object).to eq(value)
    end

    context 'using a different decorator setup' do
      before do
        GraphQL::Decorate.configure do |config|
          config.decorate do |decorator_class, object, metadata|
            decorator_class.new(object, context: metadata)
          end
        end
      end

      after { GraphQL::Decorate.reset_configuration! }

      it 'decorates the value using the class in the options and the custom block in the configuration' do
        expect(subject).to be_a(PostDecorator)
        expect(subject.object).to eq(value)
      end
    end

    context 'when the type cannot be resolved until runtime' do
      let(:options) { { unresolved_type: unresolved_type } }

      context 'when the resolved type has a decorator class' do
        let(:unresolved_type) { Icon }
        let(:value) { { url: 'https://www.image.com' } }

        it 'decorates the value using the decorator on the newly resolved type' do
          expect(subject).to be_a(ImageDecorator)
          expect(subject.object).to eq(value)
        end
      end

      context 'when the resolved type does not have a decorator class' do
        let(:unresolved_type) { Icon }
        let(:value) { { file_path: '/path/to/file' } }

        it 'returns the object undecorated' do
          expect(subject).to_not be_a(ImageDecorator)
          expect(subject).to eq(value)
        end
      end
    end

    context 'when the decorator class is specified using a block' do
      let(:decorator_evaluator) { CommentType.decorator_evaluator }
      let(:options) { { decorator_evaluator: decorator_evaluator } }

      context 'when the resolved object matches' do
        let(:value) { { verified_user: true, message: 'My comment 1' } }

        it 'decorates the object using the return value' do
          expect(subject).to be_a(VerifiedCommentDecorator)
          expect(subject.object).to eq(value)
        end
      end

      context 'when the resolved object does not match' do
        it 'returns the object undecorated' do
          expect(subject).to_not be_a(VerifiedCommentDecorator)
          expect(subject).to_not be_a(UnverifiedCommentDecorator)
          expect(subject).to eq(value)
        end
      end
    end

    it 'adds graphql to the decorator context' do
      expect(subject.context).to include(graphql: true)
    end

    context 'when a decorator context evaluator is provided' do
      let(:metadata_evaluator) { PostType.metadata_evaluator }
      let(:custom_context) { metadata_evaluator.call(value, {}) }

      let(:options) { { decorator_class: PostDecorator, metadata_evaluator: metadata_evaluator } }

      it 'populates decorator context using the evaluated data' do
        expect(subject.context).to include({ graphql: true }.merge(custom_context))
      end
    end
  end

  context 'when the value being resolved is a collection' do
    let(:inner_value) { { first_name: 'Bob', last_name: 'Boberson', published: true } }
    let(:value) { [inner_value] }

    it 'returns a collection of decorators' do
      expect(subject).to be_a(Array)
      expect(subject.first).to be_a(PostDecorator)
      expect(subject.first.object).to eq(inner_value)
    end

    context 'using a different decorator setup' do
      before do
        GraphQL::Decorate.configure do |config|
          config.decorate do |decorator_class, object, metadata|
            decorator_class.new(object, context: metadata)
          end
        end
      end

      after { GraphQL::Decorate.reset_configuration! }

      it 'decorates the value in a collection using the class in the options and the custom block in the configuration' do
        expect(subject).to be_a(Array)
        expect(subject.first).to be_a(PostDecorator)
        expect(subject.first.object).to eq(inner_value)
      end
    end

    context 'when the type cannot be resolved until runtime' do
      let(:options) { { unresolved_type: unresolved_type } }
      let(:unresolved_type) { Icon }

      context 'when the resolved type has a decorator class' do
        let(:inner_value) { { url: 'https://www.image.com' } }

        it 'decorates the value using the decorator on the newly resolved type' do
          expect(subject).to be_a(Array)
          expect(subject.first).to be_a(ImageDecorator)
          expect(subject.first.object).to eq(inner_value)
        end
      end

      context 'when the resolved type does not have a decorator class' do
        let(:inner_value) { { file_path: '/path/to/file' } }

        it 'returns the object undecorated' do
          expect(subject).to be_a(Array)
          expect(subject.first).to_not be_a(ImageDecorator)
          expect(subject.first).to eq(inner_value)
        end
      end
    end

    context 'given an Array' do
      it 'decorates the collection' do
        expect(subject.first).to be_a(PostDecorator)
        expect(subject.first.object).to eq(inner_value)
      end
    end

    context 'when ActiveRecord::Relation is defined and is given' do
      let(:value) { ActiveRecord::Relation.new([inner_value]) }

      it 'decorates the collection' do
        expect(subject.first).to be_a(PostDecorator)
        expect(subject.first.object).to eq(inner_value)
      end
    end

    context 'given a custom collection class from the configuration' do
      before do
        GraphQL::Decorate.configure do |config|
          config.custom_collection_classes << CustomCollection
        end
      end

      let(:value) { CustomCollection.new([inner_value]) }

      it 'decorates the collection' do
        expect(subject.first).to be_a(PostDecorator)
        expect(subject.first.object).to eq(inner_value)
      end
    end

    context 'when the decorator class is specified using a block' do
      let(:options) { { decorator_evaluator: CommentType.decorator_evaluator } }

      context 'when the resolved object matches' do
        let(:value) { [{ verified_user: true, message: 'My comment 1' }, { verified_user: false, message: 'My comment 2' }] }

        it 'decorates the objects in the collection using the returned value' do
          expect(subject[0]).to be_a(VerifiedCommentDecorator)
          expect(subject[1]).to be_a(UnverifiedCommentDecorator)
          expect(subject[0].object).to eq(value[0])
          expect(subject[1].object).to eq(value[1])
        end
      end

      context 'when the resolved object does not match' do
        let(:inner_value) { { message: 'My comment 1' } }

        it 'returns the collection undecorated' do
          expect(subject.first).to_not be_a(VerifiedCommentDecorator)
          expect(subject.first).to_not be_a(UnverifiedCommentDecorator)
          expect(subject.first).to eq(inner_value)
        end
      end
    end

    context 'when a decorator context evaluator is provided' do
      let(:metadata_evaluator) { PostType.metadata_evaluator }
      let(:custom_context) { metadata_evaluator.call(inner_value, {}) }

      let(:options) { { decorator_class: PostDecorator, metadata_evaluator: metadata_evaluator } }

      it 'populates decorator context using the evaluated data' do
        expect(subject.first.context).to include({ graphql: true }.merge(custom_context))
      end
    end
  end

  context 'when the value is nil' do
    let(:value) { nil }

    it { is_expected.to be_nil }
  end
end
