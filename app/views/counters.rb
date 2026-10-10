class Counters
  include Mithril::Component

  def view
    html do
      render Nav

      div(class: "columns") {
        div(class: "column") { render Counter }
        div(class: "column") { render Counter }
        div(class: "column") { render Counter }
        div(class: "column") { render Counter }
      }
    end
  end
end
