class Loading
  include Mithril::Component

  def initialize(vnode)
    super
    @loading = true
    fetch_data
  end

  def view
    html do
      render Nav

      render Bulma::Card do
        if @loading
          render Bulma::Skeleton
        else
          render Bulma::Box do
            pre(class: "mb-2") {
              plain @data.to_s
            }

            button(
              class: "button",
              onclick: -> { fetch_data }
            ) { plain "reload" }
          end
        end
      end
    end
  end

  def fetch_data
    @loading = true
    $$.setTimeout(-> {
      Mithril.request(url: "/data.json").then do |response|
        @loading = false
        @data = Hash.new(response)
      end
    }, 3000)
  end
end
