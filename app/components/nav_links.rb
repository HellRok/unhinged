class Nav
  include Unhinged::Component

  def view
    div(class: "tabs") do
      ul do
        render Nav::Link.new(href: "/#!/", text: "Home")
        render Nav::Link.new(href: "/#!/counters", text: "Counters")
        render Nav::Link.new(href: "/#!/content", text: "Content")
        render Nav::Link.new(href: "/#!/loading", text: "Loading")
      end
    end
  end

  class Link
    include Unhinged::Component

    def initialize(href:, text:)
      @href = href
      @text = text
    end

    def view
      li { a(href: @href) { plain @text } }
    end
  end
end
