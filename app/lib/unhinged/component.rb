%x{
  (() => {
    window.register_component = function(name, klass) {
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

          view: (vnode) => { return run("_view_wrapper", vnode); },
          oncreate: (vnode) => { return run("create", vnode); },
          onupdate: (vnode) => { return run("update", vnode); },
          onbeforeremove: (vnode) => { return run("before_remove", vnode); },
          onremove: (vnode) => { return run("remove", vnode); },
          onbeforeupdate: (vnode) => { return run("before_update", vnode); },
        };
      };
    };
  })();
}

%x{
  (() => {
    const run = (method, vnode) => {
      vnode.state.instance["$vnode="](vnode);
      return vnode.state.instance[`$${method}`]();
    };

    window.UnhingedInstanceComponent = {
      oninit: (vnode) => {
        vnode.state.instance = vnode.attrs.instance;
      },
      view: (vnode) => { return run("_view_wrapper", vnode); },
      oncreate: (vnode) => { return run("create", vnode); },
      onupdate: (vnode) => { return run("update", vnode); },
      onbeforeremove: (vnode) => { return run("before_remove", vnode); },
      onremove: (vnode) => { return run("remove", vnode); },
      onbeforeupdate: (vnode) => { return run("before_update", vnode); },
    };
  })();
}

module Unhinged
  module Component
    include Unhinged::Vnode
    include Unhinged::HtmlRenderer

    def create = nil
    def update = nil
    def before_remove = nil
    def remove = nil
    def before_update = nil
    def view = nil

    def self.included(base)
      $$.register_component(base.name, base)
    end
  end
end
