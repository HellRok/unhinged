Mithril::Component.define(:Content) do
  view do
    NavLinks()

    BulmaPanel {
      BulmaPanelHeading(class: "has-text-centered p-2") { plain "Controls" }
      BulmaPanelBlock { plain "Block 1" }
      BulmaPanelBlock { plain "Block 2" }
      BulmaPanelBlock { plain "Block 3" }
    }

    BulmaCard {
      BulmaCardContent(class: "content") {
        h1 { plain "Example Content" }
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

        p { plain "Image:" }
        img(src: "https://picsum.photos/500/300", alt: "A description")
      }
    }
  end
end
