class Nav
  include Unhinged::Component

  def view
    div(class: "tabs") do
      ul do
        render Nav::Link, href: "/#!/", text: "Home"
        render Nav::Link, href: "/#!/counters", text: "Counters"
        render Nav::Link, href: "/#!/content", text: "Content"
        render Nav::Link, href: "/#!/loading", text: "Loading"
      end
    end
  end

  class Link
    include Unhinged::Component

    def href = attrs[:href]
    def text = attrs[:text]

    def view
      li { a(href: href) { plain text } }
    end
  end
end
