%x{
  window.mithrilise = function(name, klass) {
    window[name] = () => {
      let instance;

      const run = (method, vnode) => {
        instance["$vnode="](vnode);
        return instance[`$${method}`]();
      };

      return {
        oninit: (vnode) => {
          instance = klass.$new(vnode);
          instance["$vnode="](vnode);
        },

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

module Mithril
  module Component
    include Mithril::Vnode
    include Mithril::HtmlRenderer

    def initialize(vnode)
      self.vnode = vnode
      @output = []
    end

    def create = puts "create"
    def update = puts "update"
    def before_remove = puts "before_remove"
    def remove = puts "remove"
    def before_update = puts "before_update"
    def view = puts "view"

    def self.included(base)
      $$.mithrilise(base.name, base)
    end
  end
end
