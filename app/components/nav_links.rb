Mithril::Component.define(:NavLinks) do
  view do
    div(class: "tabs") do
      ul do
        li { a(href: "/#!/") { plain "Home" } }
        li { a(href: "/#!/counters") { plain "Counters" } }
        li { a(href: "/#!/content") { plain "Content" } }
        li { a(href: "/#!/loading") { plain "Loading" } }
      end
    end
  end
end
