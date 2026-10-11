class Counter
  include Mithril::Component

  def initialize(vnode)
    super
    @count = 0
  end

  def view
    html do
      render Bulma::Card do
        render Bulma::Card::Header do
          p(class: "card-header-title") {
            plain "Counter"
          }
        end

        render Bulma::Card::Content do
          div(class: "block") {
            plain "Current count: #{@count}"
          }
        end

        render Bulma::Card::Footer do
          a(
            class: "card-footer-item",
            onclick: ->(e) {
              e.JS.preventDefault
              @count -= 1
            },
            href: "#"
          ) { plain "-" }

          a(
            class: "card-footer-item",
            onclick: ->(e) {
              e.JS.preventDefault
              @count = 0
            },
            href: "#"
          ) { plain "Reset" }

          a(
            class: "card-footer-item",
            onclick: ->(e) {
              e.JS.preventDefault
              @count += 1
            },
            href: "#"
          ) { plain "+" }
        end
      end
    end
  end
end
