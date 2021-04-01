[![Gem Version](https://badge.fury.io/rb/graphql-decorate.svg)](https://badge.fury.io/rb/graphql-decorate)
![CI](https://github.com/TrueCar/graphql-decorate/actions/workflows/ci.yml/badge.svg)

# GraphQL Decorate

`graphql-decorate` adds an easy-to-use interface for decorating types in [`graphql-ruby`](https://github.com/rmosolgo/graphql-ruby). It lets 
you move logic out of your type files and keep them declarative. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql-decorate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install graphql-decorate

Once the gem is installed, you need to add the plugin to  your schema and the integration into 
your base object class. 
```ruby
class Schema < GraphQL::Schema
  use GraphQL::Decorate
end

class BaseObject < GraphQL::Schema::Object
  include GraphQL::Decorate::ObjectIntegration
end
```
Note that `use GraphQL::Decorate` must be included in the schema _after_ `query` and `mutation` 
so that the fields to be extended are initialized first.

## Usage

### Basic use case
```ruby
class Rectangle
  attr_reader :length

  def initialize(length)
    @length = length
  end
end

class RectangleDecorator < BaseDecorator
  def area
    length * 2
  end
end

class RectangleType < BaseObject
  decorate_with RectangleDecorator
  
  field :area, Int, null: false
end
```
In this example, the `Rectangle` type is being decorated with a `RectangleDecorator`. Whenever a 
`Rectangle` gets resolved in the graph, the underlying object will be wrapped with a 
`RectangleDecorator`. All of the methods on the decorator are accessible on the type.

### Decorators
By default, `graphql-decorate` is set up to work with [`draper`](https://github.com/drapergem/draper) style decorators. These decorators 
provide a `decorate` method that wraps the original object and returns an instance of the 
decorator. They can also take in additional metadata.
```ruby
RectangleDecorator.decorate(rectangle, context: metadata)
```
If you are using a different decorator pattern then you can override this default behavior in 
the configuration.
```ruby
GraphQL::Decorate.configure do |config|
  config.decorate do |decorator_class, object, _metadata|
    decorator_class.decorate_differently(object)
  end
end
```

### Types
Two methods are made available on your type classes: `decorate_with` and `decorate_metadata`. 
Every method that yields the underlying object will also yield the current GraphQL `context`. 
If decoration depends on some context in the current query then you can access it when the field is resolved.

#### decorate_with
`decorate_with` accepts a decorator class that will decorate every instance of your type.
```ruby
class Rectangle < GraphQL::Schema::Object
  decorate_with RectangleDecorator
end
```

`decorate_with` optionally accepts a block which yields the underlying object. If you have multiple 
possible decorator classes you can return the one intended for the underling object.
```ruby
class Rectangle < GraphQL::Schema::Object
  decorate_with do |object, _graphql_context|
    if object.length == object.width
      SquareDecorator
    else
      RectangleDecorator
    end
  end
end
```

#### decorate_metadata
If your decorator pattern allows additional metadata to be passed into the decorators, you can 
define it here. By default every metadata hash will contain `{ graphql: true }`. This is 
useful if your decorator logic needs to diverge when used in a GraphQL context. Ideally your 
decorators are agnostic to where they are being used, but it is available if needed.

`decorate_metadata` yields a `GraphQL::Decorate::Metadata` metadata instance. It responds to two 
methods: `unscoped` and `scoped`. `unscoped` sets metadata for a resolved field. `scoped` sets 
metadata for a resolved field and all of its child fields. `unscoped` and `scoped` are expected 
to return `Hash`s.

```ruby
class Rectangle < GraphQL::Schema::Object
  decorate_metadata do |metadata| 
    metadata.unscoped do |object, _graphql_context| 
      { 
        name: object.name
      }
    end
   
    metadata.scoped do |object, _graphql_context|
      {
        inside_rectangle: true
      }
    end
  end
end
```
`RectangleDecorator` will be initialized with metadata `{ name: <object_name>,
inside_rectangle: true, graphql: true }`. All child fields of `Rectangle` will be initialized 
with metadata `{ inside_rectangle: true, graphql: true }`.

#### Combinations
You can mix and match these methods to suit your needs. Note that if `unscoped` and 
`scoped` are both provided for metadata that `scoped` will override any shared keys.
```ruby
class Rectangle < GraphQL::Schema::Object
  decorate_with RectangleDecorator
  decorate_metadata do |metadata|
    metadata.scoped do |object, _graphql_context|
      {
        name: object.name
      } 
    end
  end
end
```

### Collections
By default `graphql-decorate` recognizes `Array` and `ActiveRecord::Relation` object types and 
decorates every element in the collection. If you have other collection types that should have 
their elements decorated, you can add them in the configuration. Custom collection classes must 
respond to `#map`.
```ruby
GraphQL::Decorate.configure do |config|
  config.custom_collection_classes = [Mongoid::Relations::Targets::Enumerable]
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to 
run the tests. You can also run `bin/console` for an interactive prompt that will allow you to 
experiment.

## License

The gem is available as open source under the terms of the 
[MIT License](https://opensource.org/licenses/MIT).
