class Counters
  include Unhinged::Component

  def initialize
    @counters = [Counter.new, Counter.new]
  end

  def view
    render Nav

    div(class: "columns") {
      button(
        class: "button column mx-2",
        onclick: -> { @counters.unshift Counter.new }
      ) { plain "Unshift Counter" }

      button(
        class: "button column mx-2",
        onclick: -> { @counters.shift }
      ) { plain "Shift Counter" }

      button(
        class: "button column mx-2",
        onclick: -> { @counters.pop }
      ) { plain "Pop Counter" }

      button(
        class: "button column mx-2",
        onclick: -> { @counters.push Counter.new }
      ) { plain "push Counter" }
    }

    div(class: "columns") {
      @counters.each do |counter|
        div(class: "column") { render counter }
      end
    }
  end
end
