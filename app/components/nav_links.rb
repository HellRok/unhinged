class Nav
  include Mithril::Component

  def view
    html do
      div(class: "tabs") do
        ul do
          render Nav::Link, href: "/#!/", text: "Home"
          render Nav::Link, href: "/#!/counters", text: "Counters"
          render Nav::Link, href: "/#!/content", text: "Content"
          render Nav::Link, href: "/#!/loading", text: "Loading"
        end
      end
    end
  end

  class Link
    include Mithril::Component

    def initialize(vnode)
      super
      @href = attrs[:href]
      @text = attrs[:text]
    end

    def view
      html do
        li { a(href: @href) { plain @text } }
      end
    end
  end
end
