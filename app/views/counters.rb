Mithril::Component.define(:Counters) do
  view do
    NavLinks()

    div(class: "columns") {
      div(class: "column") { Counter() }
      div(class: "column") { Counter() }
      div(class: "column") { Counter() }
      div(class: "column") { Counter() }
    }
  end
end
