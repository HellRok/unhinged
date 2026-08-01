module Mithril
  class Component
    include Vnode

    def self.define(klass, &block)
      new(klass, &block)
    end

    def initialize(klass, &block)
      @klass = klass
      @component = {view: -> {}}
      instance_exec(&block)
      $$[@klass] = @component.to_n
      HtmlRenderer.register(@klass)
    end

    %w[oninit
    oncreate
    onupdate
    onbeforeremove
    onremove
    onbeforeupdate].each do |method|
      define_method method do |&block|
        @component[method] = ->(native_vnode) {
          @native_vnode = native_vnode
          block.call(vnode)
        }
      end
    end

    def view(&block)
      @component[:view] = ->(native_vnode) {
        @native_vnode = native_vnode
        HtmlRenderer.new(&block).call(native_vnode)
      }
    end
  end
end
