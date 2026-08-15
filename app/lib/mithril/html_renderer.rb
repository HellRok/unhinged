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
      call_wrapper
      @output.to_n
    end

    def call_wrapper
      # This lets us use `return` in the blocks and have it react in a sensible way
      # The try catch is due to this bug: https://github.com/opal/opal/issues/2608
      %x[
        try { #{instance_exec(&@block)} } catch (e) {
          if (e.$thrower_type !== "return") {
            throw e;
          }
        }
      ]
    end

    def children
      @output.concat([`#{@native_vnode}.children`])
    end

    def m(tag, opts = {}, &block)
      if tag.is_a?(String)
        flattened_opts = opts.each_with_object({}) do |(key, value), result|
          if value.is_a?(Hash) && key != :style
            value.each do |val_key, val_value|
              result["#{key}-#{val_key}"] = val_value
            end

          else
            result[key] = value
          end
        end

        @output << $$.m(tag, flattened_opts, block.call).to_n

      else
        @output << $$.m(tag, opts, block.call).to_n
      end
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
