Mithril::Component.define(:Home) do
  view do
    # div(class: "columns") {
    #   div(class: "column") { Counter() }
    #   div(class: "column") { Counter() }
    # }

    # BulmaPanel {
    #   BulmaHeading { plain "Controls" }
    #   BulmaBlock { plain "Block 1" }
    #   BulmaBlock { plain "Block 2" }
    #   BulmaBlock { plain "Block 3" }
    # }

    div(class: "content") {
      h1 { "Example Page" }
      p { plain "This is a paragraph demonstrating basic text." }

      ul {
        li { plain "List item one" }
        li { plain "List item two" }
        li { plain "List item three" }
      }

      p {
        plain "Visit our site: "
        a(href: "https://example.com") { plain "Example Link" }
      }

      p { plain "Image placeholder:" }
      img(src: "https://picsum.photos/500/300", alt: "A description")
    }
  end
end
