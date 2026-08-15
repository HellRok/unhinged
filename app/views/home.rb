Mithril::Component.define(:Home) do
  view do
    NavLinks()

    section(class: "hero is-info") do
      div(class: "hero-body") do
        p(class: "title") { plain "Opal Mithril" }
        p(class: "subtitle") { plain "My unhinged frontend experiment" }
      end
    end
  end
end
