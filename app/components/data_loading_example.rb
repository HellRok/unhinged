Mithril::Component.define(:DataLoadingExample) do
  def fetch_data
    state[:loading] = true
    $$.setTimeout(-> {
      Mithril.request(url: "/data.json").then do |response|
        state[:loading] = false
        state[:data] = Hash.new(response)
      end
    }, 3000)
  end

  oninit do
    state[:loading] = true

    fetch_data
  end

  view do
    BulmaCard {
      if state[:loading]
        BulmaSkeleton()
      else
        BulmaBox {
          pre(class: "mb-2") {
            plain state[:data].to_s
          }

          button(
            class: "button",
            onclick: -> { fetch_data }
          ) { plain "reload" }
        }
      end
    }
  end
end
