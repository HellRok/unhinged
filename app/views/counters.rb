class Counters
  include Unhinged::Component

  def view
    render Nav

    div(class: "columns") {
      div(class: "column") { render Counter.new }
      div(class: "column") { render Counter.new }
      div(class: "column") { render Counter.new }
      div(class: "column") { render Counter.new }
    }
  end
end
