class Home
  include Mithril::Component

  def view
    html do
      # div(class: "box 1") {
      #   plain "box 1"
      #   p(class: "box 2") {
      #     plain "box 2"

      #     b(class: "sub-box 2.5") { plain "sub-box 2.5" }
      #   }
      #   span(class: "box 3") { plain "box 3" }
      #   puts "HI"
      # }

      # nav(class: "box 4") { plain "box 4" }
      render Nav

      section(class: "hero is-info") do
        div(class: "hero-body") do
          p(class: "title") { plain "Opal Mithril" }
          p(class: "subtitle") { plain "My unhinged frontend experiment" }
        end
      end
    end
  end
end
