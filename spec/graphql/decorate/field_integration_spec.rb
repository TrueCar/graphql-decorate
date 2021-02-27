# frozen_string_literal: true
require 'spec_helper'

describe GraphQL::Decorate::FieldIntegration do
  let(:query) { <<-GRAPHQL }
    query {
      baseField
      decoratedObject {
        bar
      }
      decoratedArray {
        bar
      }
      decoratedConnection(first: 1) {
        edges {
          node {
            bar
          }
        }
        nodes {
          bar
        }
      }
      decoratedTypeWithInterface {
        baz
      }
    }
  GRAPHQL

  subject { Schema.execute(query) }

  it 'decorates fields' do
    expect(Decorator).to receive(:decorate).exactly(5).times.and_call_original
    expect(subject['data']['baseField']).to eq('base_field_value')
    expect(subject['data']['decoratedObject']['bar']).to eq('foobar')
    expect(subject['data']['decoratedArray'].first['bar']).to eq('foobar')
    expect(subject['data']['decoratedConnection']['edges'].first['node']['bar']).to eq('foobar')
    expect(subject['data']['decoratedConnection']['nodes'].first['bar']).to eq('foobar')
    expect(subject['data']['decoratedTypeWithInterface']['baz']).to eq('foobaz')
  end
end
