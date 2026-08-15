Mithril::Component.define(:Counter) do
  oninit do
    state[:count] = 0
  end

  view do
    BulmaCard {
      BulmaCardHeader {
        p(class: "card-header-title") {
          plain "Counter"
        }
      }
      BulmaCardContent {
        div(class: "block") {
          plain "Current count: #{state[:count]}"
        }
      }

      BulmaCardFooter {
        a(
          class: "card-footer-item",
          onclick: ->(e) {
            e.JS.preventDefault
            state[:count] -= 1
          },
          href: "#"
        ) { plain "-" }

        a(
          class: "card-footer-item",
          onclick: ->(e) {
            e.JS.preventDefault
            state[:count] = 0
          },
          href: "#"
        ) { plain "Reset" }

        a(
          class: "card-footer-item",
          onclick: ->(e) {
            e.JS.preventDefault
            state[:count] += 1
          },
          href: "#"
        ) { plain "+" }
      }
    }
  end
end
