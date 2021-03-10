# frozen_string_literal: true

require 'spec_helper'

describe GraphQL::Decorate::FieldIntegration do
  subject(:query_result) { Schema.execute(query) }

  let(:query) { <<-GRAPHQL }
    query {
      blog {
        name
        title
      }
    }
  GRAPHQL

  it 'decorates the blog once' do
    expect(BlogDecorator).to receive(:new).once.and_call_original
    query_result
  end

  it 'returns the correct name' do
    expect(query_result['data']['blog']['name']).to eq('My Blog')
  end

  it 'returns the decorated title' do
    expect(query_result['data']['blog']['title']).to eq('my-blog')
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

    it 'decorates the blog once' do
      expect(BlogDecorator).to receive(:new).once.and_call_original
      query_result
    end

    it 'decorates the post twice' do
      expect(PostDecorator).to receive(:new).twice.and_call_original
      query_result
    end

    it 'returns the decorated name' do
      expect(query_result['data']['blog']['posts'][0]['name']).to eq('Bob Boberson')
    end

    it 'returns the first name' do
      expect(query_result['data']['blog']['posts'][0]['firstName']).to eq('Bob')
    end
  end

  context 'with decorated connections' do
    let(:query) { <<-GRAPHQL }
      query {
        blog {
          postConnection {
            pageInfo {
              endCursor
            }
            nodes {
              firstName
              name
            }
          }
        }
      }
    GRAPHQL

    it 'decorates the blog once' do
      expect(BlogDecorator).to receive(:new).once.and_call_original
      query_result
    end

    it 'decorates the posts twice' do
      expect(PostDecorator).to receive(:new).twice.and_call_original
      query_result
    end

    it 'returns the decorated name' do
      expect(query_result['data']['blog']['postConnection']['nodes'][0]['name']).to eq('Bob Boberson')
    end

    it 'returns the first name' do
      expect(query_result['data']['blog']['postConnection']['nodes'][0]['firstName']).to eq('Bob')
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

    it 'decorates the blog once' do
      expect(BlogDecorator).to receive(:new).once.and_call_original
      query_result
    end

    it 'decorates the posts twice' do
      expect(PostDecorator).to receive(:new).twice.and_call_original
      query_result
    end

    it 'decorates unverified comments twice' do
      expect(UnverifiedCommentDecorator).to receive(:new).twice.and_call_original
      query_result
    end

    it 'decorates verified comments twice' do
      expect(VerifiedCommentDecorator).to receive(:new).twice.and_call_original
      query_result
    end

    it 'decorates the first comment as verified' do
      expect(query_result['data']['blog']['posts'][0]['comments'][0]['disclaimer']).to eq('This user is verified')
    end

    it 'decorates the second comment as unverified' do
      expect(query_result['data']['blog']['posts'][0]['comments'][1]['disclaimer']).to eq('This user is not verified')
    end
  end

  context 'with unresolved types' do
    let(:query) { <<-GRAPHQL }
      query {
        blog {
          posts {
            icons {
              ... on Image {
                url
                alternateText
              }
            }
          }
        }
      }
    GRAPHQL

    it 'decorates the blog once' do
      expect(BlogDecorator).to receive(:new).once.and_call_original
      query_result
    end

    it 'decorates the posts twice' do
      expect(PostDecorator).to receive(:new).twice.and_call_original
      query_result
    end

    it 'decorates the images twice' do
      expect(ImageDecorator).to receive(:new).twice.and_call_original
      query_result
    end

    it 'decorates the first icon as an image' do
      expect(query_result['data']['blog']['posts'][0]['icons'][0]['alternateText']).to eq('Profile picture')
    end

    it 'decorates the second icon as a placeholder' do
      expect(query_result['data']['blog']['posts'][0]['icons'][1]['alternateText']).to eq('Placeholder')
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

    it 'decorates the blog once' do
      expect(BlogDecorator).to receive(:new).once.and_call_original
      query_result
    end

    it 'sets activeStatus to true from the context' do
      expect(query_result['data']['blog']['activeStatus']).to be_truthy
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

    it 'decorates the blog once' do
      expect(BlogDecorator).to receive(:new).once.and_call_original
      query_result
    end

    it 'decorates the posts twice' do
      expect(PostDecorator).to receive(:new).twice.and_call_original
      query_result
    end

    it 'evaluates and adds context to the first decorator' do
      expect(query_result['data']['blog']['posts'][0]['publishedStatus']).to be_truthy
    end

    it 'evaluates and adds context to the second decorator' do
      expect(query_result['data']['blog']['posts'][1]['publishedStatus']).to be_falsey
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

    it 'decorates the blog once' do
      expect(BlogDecorator).to receive(:new).once.and_call_original
      query_result
    end

    it 'decorates the posts twice' do
      expect(PostDecorator).to receive(:new).twice.and_call_original
      query_result
    end

    it 'adds scoped context to the original field' do
      expect(query_result['data']['blog']['owner']).to eq('Bill Billerson')
    end

    it 'adds scoped context to child fields' do
      expect(query_result['data']['blog']['posts'][0]['blogOwner']).to eq('Bill Billerson')
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
            commentConnection {
              nodes {
                postOwner
              }
              edges {
                node {
                  postOwner
                  reaction {
                    postOwner
                  }
                }
              }
            }
          }
        }
      }
    GRAPHQL

    # rubocop:disable RSpec/ExampleLength
    # rubocop:disable RSpec/MultipleExpectations
    it 'evaluates it and adds context to all child fields' do
      expect(BlogDecorator).to receive(:new).once.and_call_original
      expect(PostDecorator).to receive(:new).twice.and_call_original
      expect(UnverifiedCommentDecorator).to receive(:new).exactly(6).times.and_call_original
      expect(VerifiedCommentDecorator).to receive(:new).exactly(6).times.and_call_original
      expect(ReactionDecorator).to receive(:new).exactly(8).times.and_call_original
      posts = query_result['data']['blog']['posts']
      expect(posts[0]['owner']).to eq('Bob')
      expect(posts[1]['owner']).to eq('Tod')
      expect(posts[0]['comments'][0]['postOwner']).to eq('Bob')
      expect(posts[0]['comments'][1]['postOwner']).to eq('Bob')
      expect(posts[1]['comments'][0]['postOwner']).to eq('Tod')
      expect(posts[1]['comments'][1]['postOwner']).to eq('Tod')
      expect(posts[0]['commentConnection']['nodes'][0]['postOwner']).to eq('Bob')
      expect(posts[0]['commentConnection']['nodes'][1]['postOwner']).to eq('Bob')
      expect(posts[1]['commentConnection']['nodes'][0]['postOwner']).to eq('Tod')
      expect(posts[1]['commentConnection']['nodes'][1]['postOwner']).to eq('Tod')
      expect(posts[0]['commentConnection']['edges'][0]['node']['postOwner']).to eq('Bob')
      expect(posts[0]['commentConnection']['edges'][1]['node']['postOwner']).to eq('Bob')
      expect(posts[1]['commentConnection']['edges'][0]['node']['postOwner']).to eq('Tod')
      expect(posts[1]['commentConnection']['edges'][1]['node']['postOwner']).to eq('Tod')
      expect(posts[0]['comments'][0]['reaction']['postOwner']).to eq('Rod')
      expect(posts[1]['comments'][0]['reaction']['postOwner']).to eq('Rod')
      expect(posts[0]['commentConnection']['edges'][0]['node']['reaction']['postOwner']).to eq('Rod')
      expect(posts[0]['commentConnection']['edges'][1]['node']['reaction']['postOwner']).to eq('Rod')
    end
    # rubocop:enable RSpec/ExampleLength
    # rubocop:enable RSpec/MultipleExpectations
  end
end
