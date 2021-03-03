# frozen_string_literal: true
require 'spec_helper'

describe GraphQL::Decorate::FieldIntegration do
  let(:query) { <<-GRAPHQL }
    query {
      blog {
        name
        title
      }
    }
  GRAPHQL

  subject { Schema.execute(query) }

  it 'decorates fields' do
    expect(BlogDecorator).to receive(:new).exactly(1).times.and_call_original
    expect(subject['data']['blog']['name']).to eq('My Blog')
    expect(subject['data']['blog']['title']).to eq('my-blog')
  end

  context 'with decorated arrays' do
    let(:query) { <<-GRAPHQL }
    query {
      blog {
        posts {
          firstName
          name
        }
      }
    }
    GRAPHQL

    it 'decorates every element' do
      expect(BlogDecorator).to receive(:new).exactly(1).times.and_call_original
      expect(PostDecorator).to receive(:new).exactly(2).times.and_call_original
      expect(subject['data']['blog']['posts'].first['firstName']).to eq('Bob')
      expect(subject['data']['blog']['posts'].first['name']).to eq('Bob Boberson')
    end
  end

  context 'with decorated connections' do
    let(:query) { <<-GRAPHQL }
      query {
        blog {
          postConnection {
            nodes {
              firstName
              name
            }
          }
        }
      }
    GRAPHQL

    it 'decorates every element in the connection' do
      expect(BlogDecorator).to receive(:new).exactly(1).times.and_call_original
      expect(PostDecorator).to receive(:new).exactly(2).times.and_call_original
      expect(subject['data']['blog']['postConnection']['nodes'].first['firstName']).to eq('Bob')
      expect(subject['data']['blog']['postConnection']['nodes'].first['name']).to eq('Bob Boberson')
    end
  end

  context 'with decorated types that have more than one decorator class' do
    let(:query) { <<-GRAPHQL }
      query {
        blog {
          posts {
            comments {
              disclaimer
            }
          }
        }
      }
    GRAPHQL

    it 'switches between the two' do
      expect(BlogDecorator).to receive(:new).exactly(1).times.and_call_original
      expect(PostDecorator).to receive(:new).exactly(2).times.and_call_original
      expect(UnverifiedCommentDecorator).to receive(:new).exactly(2).times.and_call_original
      expect(VerifiedCommentDecorator).to receive(:new).exactly(2).times.and_call_original
      expect(subject['data']['blog']['posts'].first['comments'].first['disclaimer']).to eq('This user is verified')
      expect(subject['data']['blog']['posts'].first['comments'][1]['disclaimer']).to eq('This user is not verified')
    end
  end

  context 'with unresolved types' do
    let(:query) { <<-GRAPHQL }
      query {
        blog {
          posts {
            icon {
              ... on Image {
                url
                alternateText
              }
            }
          }
        }
      }
    GRAPHQL

    it 'decorates using the resolved type at runtime' do
      expect(BlogDecorator).to receive(:new).exactly(1).times.and_call_original
      expect(PostDecorator).to receive(:new).exactly(2).times.and_call_original
      expect(ImageDecorator).to receive(:new).exactly(2).times.and_call_original
      expect(subject['data']['blog']['posts'].first['icon']['url']).to eq('https://www.image.com')
      expect(subject['data']['blog']['posts'].first['icon']['alternateText']).to eq('Profile picture')
    end
  end

  context 'when decorator context is given' do
    let(:query) { <<-GRAPHQL }
      query {
        blog {
          activeStatus
        }
      }
    GRAPHQL

    it 'evaluates and adds context to the decorator' do
      expect(BlogDecorator).to receive(:new).exactly(1).times.and_call_original
      expect(subject['data']['blog']['activeStatus']).to be_truthy
    end
  end

  context 'when decorator context is given for a collection' do
    let(:query) { <<-GRAPHQL }
      query {
        blog {
          posts {
            publishedStatus
          }
        }
      }
    GRAPHQL

    it 'evaluates and adds context to the decorator' do
      expect(BlogDecorator).to receive(:new).exactly(1).times.and_call_original
      expect(PostDecorator).to receive(:new).exactly(2).times.and_call_original
      expect(subject['data']['blog']['posts'].first['publishedStatus']).to be_truthy
      expect(subject['data']['blog']['posts'][1]['publishedStatus']).to be_falsey
    end
  end

  context 'when scoped context is given' do
    let(:query) { <<-GRAPHQL }
      query {
        blog {
          owner
          posts {
            blogOwner
          }
        }
      }
    GRAPHQL

    it 'evaluates it and adds context to all child fields' do
      expect(BlogDecorator).to receive(:new).exactly(1).times.and_call_original
      expect(PostDecorator).to receive(:new).exactly(2).times.and_call_original
      expect(subject['data']['blog']['owner']).to eq('Bill Billerson')
      expect(subject['data']['blog']['posts'].first['blogOwner']).to eq('Bill Billerson')
    end
  end

  context 'when scoped context is passed from an array to child fields' do
    let(:query) { <<-GRAPHQL }
      query {
        blog {
          posts {
            owner
            comments {
              postOwner
              reaction {
                postOwner
              }
            }
          }
        }
      }
    GRAPHQL

    it 'evaluates it and adds context to all child fields' do
      expect(BlogDecorator).to receive(:new).exactly(1).times.and_call_original
      expect(PostDecorator).to receive(:new).exactly(2).times.and_call_original
      expect(UnverifiedCommentDecorator).to receive(:new).exactly(2).times.and_call_original
      expect(VerifiedCommentDecorator).to receive(:new).exactly(2).times.and_call_original
      expect(subject['data']['blog']['posts'].first['owner']).to eq('Bob')
      expect(subject['data']['blog']['posts'][1]['owner']).to eq('Tod')
      expect(subject['data']['blog']['posts'].first['comments'].first['postOwner']).to eq('Bob')
      expect(subject['data']['blog']['posts'].first['comments'][1]['postOwner']).to eq('Bob')
      expect(subject['data']['blog']['posts'][1]['comments'].first['postOwner']).to eq('Tod')
      expect(subject['data']['blog']['posts'][1]['comments'][1]['postOwner']).to eq('Tod')
      expect(subject['data']['blog']['posts'].first['comments'].first['reaction']['postOwner']).to eq('Bob')
      expect(subject['data']['blog']['posts'][1]['comments'].first['reaction']['postOwner']).to eq('Tod')
    end
  end
end
