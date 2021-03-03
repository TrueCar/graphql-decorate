class Decorator
  attr_reader :object, :context

  def initialize(object, context:)
    @object = object
    @context = context
  end

  class << self
    def decorate(object, context:)
      new(object, context: context)
    end
    private

    def method_missing(method, *args, &block)
      @object.class.send(method, *args, &block)||super
    end

    def respond_to_missing?(method, include_private=false)
      @object.class.respond_to?(method, include_private)
    end
  end

  private

  def method_missing(method, *args, &block)
    @object.send(method, *args, &block)||super
  end

  def respond_to_missing?(method, include_private=false)
    @object.respond_to?(method, include_private)
  end
end
