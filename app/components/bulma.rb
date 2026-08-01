Mithril::Component.define(:BulmaPanel) do
  view do
    type = attrs.fetch(:type, "is-primary")
    nav(class: "panel #{type}") { children }
  end
end

Mithril::Component.define(:BulmaHeading) do
  view do
    p(class: "panel-heading has-text-centered p-2") { children }
  end
end

Mithril::Component.define(:BulmaBlock) do
  view do
    div(class: "panel-block") { children }
  end
end
