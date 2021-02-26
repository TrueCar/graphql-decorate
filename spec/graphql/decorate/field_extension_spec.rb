require 'spec_helper'

describe GraphQL::Decorate::FieldExtension do
  let(:field) { nil }
  let(:options) { { decorator_class: Decorator } }
  let(:context) { {} }
  subject { described_class.new(field: field, options: options).after_resolve(context: context, value: value) }

  context 'when the value being resolved is a scalar' do
    let(:value) { 'foo' }

    it 'decorates the value provided using the class in the options' do
      expect(subject).to be_a(Decorator)
      expect(subject.object).to eq(value)
    end

    context 'using a different decorator setup' do
      before do
        GraphQL::Decorate.configure do |config|
          config.decorate do |decorator_class, object, _context|
            decorator_class.decorate_differently(object)
          end
        end
      end

      after { GraphQL::Decorate.reset_configuration! }

      let(:options) { { decorator_class: DifferentDecorator } }

      it 'decorates the value using the class in the options and the custom block in the configuration' do
        expect(subject).to be_a(DifferentDecorator)
        expect(subject.object).to eq(value)
      end
    end

    context 'when the type cannot be resolved until runtime' do
      let(:options) { { unresolved_type: unresolved_type } }
      let(:unresolved_type) { double('unresolved type', resolve_type: resolved_type) }

      context 'when the resolved type has a decorator class' do
        let(:resolved_type) { DecoratedType }

        it 'decorates the value using the decorator on the newly resolved type' do
          expect(subject).to be_a(Decorator)
          expect(subject.object).to eq(value)
        end
      end

      context 'when the resolved type does not have a decorator class' do
        let(:resolved_type) { GraphQL::Schema::Object }

        it 'returns the object undecorated' do
          expect(subject).to_not be_a(Decorator)
          expect(subject).to eq(value)
        end
      end
    end

    context 'when the decorator class is specified using a block' do
      let(:decorator_evaluator) { ->(object) { object.is_a?(Hash) ? Decorator : nil } }
      let(:options) { { decorator_evaluator: decorator_evaluator } }

      context 'when the resolved object matches' do
        let(:value) { { foo: :bar } }

        it 'decorates the object using the return value' do
          expect(subject).to be_a(Decorator)
          expect(subject.object).to eq(value)
        end
      end

      context 'when the resolved object does not match' do
        it 'returns the object undecorated' do
          expect(subject).to_not be_a(Decorator)
          expect(subject).to eq(value)
        end
      end
    end

    it 'adds graphql to the decorator context' do
      expect(subject.context).to include(context: { graphql: true })
    end

    context 'when a decorator context evaluator is provided' do
      let(:decorator_context_evaluator) { ->(object) { { custom_context: object + 'bar' } } }
      let(:custom_context) { decorator_context_evaluator.call(value) }

      let(:options) { { decorator_class: Decorator, decorator_context_evaluator: decorator_context_evaluator } }

      it 'populates decorator context using the evaluated data' do
        expect(subject.context).to include({ context: { graphql: true }.merge(custom_context) })
      end
    end
  end

  context 'when the value being resolved is a collection' do
    let(:object) { 'foo' }
    let(:value) { [object] }

    it 'returns a collection of decorators' do
      expect(subject).to be_a(Array)
      expect(subject.first).to be_a(Decorator)
      expect(subject.first.object).to eq(object)
    end

    context 'using a different decorator setup' do
      before do
        GraphQL::Decorate.configure do |config|
          config.decorate do |decorator_class, object, _context|
            decorator_class.decorate_differently(object)
          end
        end
      end

      after { GraphQL::Decorate.reset_configuration! }

      let(:options) { { decorator_class: DifferentDecorator } }

      it 'decorates the value in a collection using the class in the options and the custom block in the configuration' do
        expect(subject).to be_a(Array)
        expect(subject.first).to be_a(DifferentDecorator)
        expect(subject.first.object).to eq(object)
      end
    end

    context 'when the type cannot be resolved until runtime' do
      let(:options) { { unresolved_type: unresolved_type } }
      let(:unresolved_type) { double('unresolved type', resolve_type: resolved_type) }

      context 'when the resolved type has a decorator class' do
        let(:resolved_type) { DecoratedType }

        it 'decorates the value using the decorator on the newly resolved type' do
          expect(subject).to be_a(Array)
          expect(subject.first).to be_a(Decorator)
          expect(subject.first.object).to eq(object)
        end
      end

      context 'when the resolved type does not have a decorator class' do
        let(:resolved_type) { GraphQL::Schema::Object }

        it 'returns the object undecorated' do
          expect(subject).to be_a(Array)
          expect(subject.first).to_not be_a(Decorator)
          expect(subject.first).to eq(object)
        end
      end
    end

    context 'given an Array' do
      it 'decorates the collection' do
        expect(subject.first).to be_a(Decorator)
        expect(subject.first.object).to eq(object)
      end
    end

    context 'when ActiveRecord::Relation is defined and is given' do
      let(:value) { ActiveRecord::Relation.new([object]) }

      it 'decorates the collection' do
        expect(subject.first).to be_a(Decorator)
        expect(subject.first.object).to eq(object)
      end
    end

    context 'given a custom collection class from the configuration' do
      before do
        GraphQL::Decorate.configure do |config|
          config.custom_collection_classes << CustomCollection
        end
      end

      let(:value) { CustomCollection.new([object]) }

      it 'decorates the collection' do
        expect(subject.first).to be_a(Decorator)
        expect(subject.first.object).to eq(object)
      end
    end

    context 'when the decorator class is specified using a block' do
      let(:custom_decorator) { Class.new(Decorator) }
      let(:decorator_evaluator) do
        lambda do |object|
          case object
          when Hash
            Decorator
          when String
            custom_decorator
          else
            nil
          end
        end
      end
      let(:options) { { decorator_evaluator: decorator_evaluator } }

      context 'when the resolved object matches' do
        let(:hash) { { foo: :bar } }
        let(:string) { 'foo' }
        let(:value) { [hash, string] }

        it 'decorates the objects in the collection using the returned value' do
          expect(subject.first).to be_a(Decorator)
          expect(subject[1]).to be_a(custom_decorator)
          expect(subject.first.object).to eq(hash)
          expect(subject[1].object).to eq(string)
        end
      end

      context 'when the resolved object does not match' do
        let(:object) { 2 }

        it 'returns the collection undecorated' do
          expect(subject.first).to_not be_a(Decorator)
          expect(subject.first).to eq(object)
        end
      end
    end

    context 'when a decorator context evaluator is provided' do
      let(:decorator_context_evaluator) { ->(object) { { custom_context: object + 'bar' } } }
      let(:custom_context) { decorator_context_evaluator.call(object) }

      let(:options) { { decorator_class: Decorator, decorator_context_evaluator: decorator_context_evaluator } }

      it 'populates decorator context using the evaluated data' do
        expect(subject.first.context).to include({ context: { graphql: true }.merge(custom_context) })
      end
    end
  end

  context 'when the value is nil' do
    let(:value) { nil }

    it { is_expected.to be_nil }
  end
end
