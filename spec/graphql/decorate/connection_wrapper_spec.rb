# frozen_string_literal: true

require 'spec_helper'

describe GraphQL::Decorate::ConnectionWrapper do
  subject(:connection_wrapper) { described_class.wrap(connection, context, options) }

  let(:value) { [{ first_name: 'Bob', last_name: 'Boberson', published: true }] }
  let(:connection) do
    GraphQL::Pagination::ArrayConnection.new(value, field: BaseField.new(name: 'posts', null: false, type: PostType))
  end
  let(:context) { GraphQL::Query::Context.new(query: GraphQL::Query.new(Schema), values: nil, object: nil) }
  let(:options) { { decorator_class: PostDecorator } }

  before { allow(connection).to receive(:nodes).and_return(value) }

  it 'decorates the nodes of the connection after pagination' do
    expect(connection_wrapper.nodes.first).to be_a(PostDecorator)
  end

  it 'decorates the edge nodes of the connection after pagination' do
    expect(connection_wrapper.edge_nodes.first).to be_a(PostDecorator)
  end

  context 'when delegating' do
    GraphQL::Pagination::ArrayConnection.singleton_class.class_eval do
      define_method(:class_method) do
        'class method'
      end
    end

    it 'responds to instance methods' do
      expect(connection_wrapper).to respond_to(:items)
    end

    it 'delegates instance methods to the connection' do
      expect(connection_wrapper.items).to eq(value)
    end

    it 'responds to class methods' do
      expect(connection_wrapper.class).to respond_to(:class_method)
    end

    it 'delegates class methods to the connection class' do
      expect(connection_wrapper.class.class_method).to eq('class method')
    end
  end
end
