Mithril::Component.define(:Counter) do
  oninit do
    state[:count] = 0
  end

  view do
    div(class: "card") {
      header(class: "card-header") {
        p(class: "card-header-title") {
          plain "Counter"
        }
      }
      div(class: "card-content") {
        div(class: "block") {
          plain "Current count: #{state[:count]}"
        }
      }

      div(class: "card-footer") {
        a(
          class: "card-footer-item",
          onclick: -> { state[:count] -= 1 },
          href: "#"
        ) { plain "-" }

        a(
          class: "card-footer-item",
          onclick: -> { state[:count] = 0 },
          href: "#"
        ) { plain "Reset" }

        a(
          class: "card-footer-item",
          onclick: -> { state[:count] += 1 },
          href: "#"
        ) { plain "+" }
      }
    }
  end
end
