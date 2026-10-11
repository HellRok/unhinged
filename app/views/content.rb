class Content
  include Mithril::Component

  def view
    render Nav

    render Bulma::Panel do
      render Bulma::Panel::Heading, class: "has-text-centered" do
        plain "Controls"
      end
      render Bulma::Panel::Block do
        plain "Block 1"
      end
      render Bulma::Panel::Block do
        plain "Block 2"
      end
      render Bulma::Panel::Block do
        plain "Block 3"
      end
    end

    render Bulma::Card do
      render Bulma::Card::Content, class: "content" do
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
      end
    end
  end
end
