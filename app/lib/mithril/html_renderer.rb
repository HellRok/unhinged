module Mithril
  class HtmlRenderer
    include Vnode

    # Taken from https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements
    TAGS = %w[
      a abbr address area article aside audio b base bdi bdo blockquote body br
      button canvas caption cite code col colgroup data datalist dd del details dfn
      dialog div dl dt em embed fencedframe fieldset figcaption figure footer form
      geolocation h1 head header hgroup hr html i iframe img input ins kbd label
      legend li link main map mark math menu meta meter nav noscript object ol
      optgroup option output p picture pre progress q rp rt ruby s samp script search
      section select selectedcontent slot small source span strong style sub summary
      sup svg table tbody td template textarea tfoot th thead time title tr track u
      ul var video wbr
    ]

    def initialize(component, &block)
      @output = []
      @block = block
      @component = component
    end

    def call(vnode)
      @native_vnode = vnode
      instance_exec(&@block)
      @output.to_n
    end

    def children
      @output.concat([`#{@native_vnode}.children`])
    end

    def m(tag, opts = {}, &block)
      @output << $$.m(tag, opts, block.call).to_n
    end

    def tag(tag, opts, &block)
      m(tag, opts) {
        HtmlRenderer.new(@component, &block).call(@native_vnode) if block_given?
      }
    end

    def self.register(klass)
      define_method klass do |opts = {}, &block|
        tag($$[klass], opts, &block)
      end
    end

    TAGS.each { |elem|
      define_method elem do |opts = {}, &block|
        tag(elem, opts, &block)
      end
    }

    def plain(text)
      @output << text
    end

    def method_missing(m, *args, &block)
      @component.send(m, *args, *block)
    end
  end
end
