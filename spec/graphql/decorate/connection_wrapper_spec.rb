# frozen_string_literal: true

require 'spec_helper'

describe GraphQL::Decorate::ConnectionWrapper do
  let(:value) { [{ first_name: 'Bob', last_name: 'Boberson', published: true }] }
  let(:connection) { GraphQL::Pagination::ArrayConnection.new(value, field: BaseField.new(name: 'posts', null: false, type: PostType)) }
  let(:context) { GraphQL::Query::Context.new(query: GraphQL::Query.new(Schema), values: nil, object: nil) }
  let(:options) { { decorator_class: PostDecorator } }
  subject { described_class.wrap(connection, context, options) }

  before { allow(connection).to receive(:nodes).and_return(value) }

  it 'decorates the nodes of the connection after pagination' do
    expect(subject.nodes.first).to be_a(PostDecorator)
  end

  it 'decorates the edge nodes of the connection after pagination' do
    expect(subject.edge_nodes.first).to be_a(PostDecorator)
  end

  it 'delegates all other methods to the connection' do
    GraphQL::Pagination::ArrayConnection.singleton_class.class_eval do
      define_method(:class_method) do
        'class method'
      end
    end
    expect(subject.class).to respond_to(:class_method)
    expect(subject.class.class_method).to eq('class method')
    expect(subject).to respond_to(:items)
    expect(subject.items).to eq(value)
  end
end
