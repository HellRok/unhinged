module Mithril
  module HtmlRenderer
    # Taken from https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements
    TAGS = %w[
      a abbr address area article aside audio b base bdi bdo blockquote body br
      button canvas caption cite code col colgroup data datalist dd del details dfn
      dialog div dl dt em embed fencedframe fieldset figcaption figure footer form
      geolocation h1 head header hgroup hr i iframe img input ins kbd label
      legend li link main map mark math menu meta meter nav noscript object ol
      optgroup option output p picture pre progress q rp rt ruby s samp script search
      section select selectedcontent slot small source span strong style sub summary
      sup svg table tbody td template textarea tfoot th thead time title tr track u
      ul var video wbr
    ]

    def children
      _output << `#{native_vnode}.children`
    end

    def _output
      @output.last
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

        $$.m(tag, flattened_opts, block.call).to_n

      else
        $$.m(tag, opts, block.call).to_n
      end
    end

    def tag(tag, opts, &block)
      @depth += 1

      result = m(tag, opts) {
        if block_given?
          @output << []
          block.call
          @output.pop
        end
      }

      @depth -= 1

      if @depth.zero?
        @output << result
      else
        _output << result
      end
    end

    TAGS.each { |elem|
      define_method elem do |opts = {}, &block|
        tag(elem, opts, &block)
      end
    }

    def render(klass, opts={}, &block)
      tag($$[klass.name], opts, &block)
    end

    def plain(text)
      _output << text
    end

    def html(&block)
      @depth = 0
      @output = []

      block.call

      @output
    end
  end
end
