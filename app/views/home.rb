class Home
  include Mithril::Component

  def view
    render Nav

    section(class: "hero is-info") do
      div(class: "hero-body") do
        p(class: "title") { plain "Opal Mithril" }
        p(class: "subtitle") { plain "My unhinged frontend experiment" }
      end
    end
  end
end
