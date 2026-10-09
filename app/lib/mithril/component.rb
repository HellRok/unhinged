module Component
  include Mithril::Vnode

  def create = puts "create"
  def update = puts "update"
  def before_remove = puts "before_remove"
  def remove = puts "remove"
  def before_update = puts "before_update"
  def view = puts "view"

  def html(&block)
    Mithril::HtmlRenderer.new(self, &block).call(vnode)
  end
end

class Beep
  class Blah
    include Component

    def initialize(vnode)
      self.vnode = vnode
      @blah = "hello"
    end

    def view
      #$$.m("div", "jest").to_n
      html do
        p { plain "??-#{@blah}-??" }
      end
    end
  end
end

class Thing
  include Component

  def view
    html do
      div(class: "box") {
        h1() { plain "hello" }
        children
      }
    end
  end
end

%x{
  window.r = function(name, klass) {
    window[name] = () => {
      let instance;

      const run = (method, vnode) => {
        instance["$vnode="](vnode);
        return instance[`$${method}`](vnode);
      };

      return {
        oninit: (vnode) => { instance = klass.$new(vnode); },

        view: (vnode) => { return run("view", vnode); },
        oncreate: (vnode) => { return run("create", vnode); },
        onupdate: (vnode) => { return run("update", vnode); },
        onbeforeremove: (vnode) => { return run("before_remove", vnode); },
        onremove: (vnode) => { return run("remove", vnode); },
        onbeforeupdate: (vnode) => { return run("before_update", vnode); },
      }
    }
  }
}

def r(klass)
  $$.r(
    klass.name,
    klass
  )
end

r(Beep::Blah)
r(Thing)

puts $$["Beep::Blah"]

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
        HtmlRenderer.new(self, &block).call(native_vnode)
      }
    end
  end
end
