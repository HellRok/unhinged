class Home
  include Unhinged::Component

  def view
    render Nav

    section(class: "hero is-info") do
      div(class: "hero-body") do
        p(class: "title") { plain "Unhinged Framework" }
        p(class: "subtitle") { plain "My unhinged frontend experiment to use Ruby for frontend development." }
      end
    end
  end
end
