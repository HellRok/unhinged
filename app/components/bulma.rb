Mithril::Component.define(:BulmaPanel) do
  view do
    type = attrs.fetch(:type, "is-primary")
    nav(class: "panel #{type} #{attrs[:class]}") { children }
  end
end

Mithril::Component.define(:BulmaPanelHeading) do
  view do
    p(class: "panel-heading #{attrs[:class]}") { children }
  end
end

Mithril::Component.define(:BulmaPanelBlock) do
  view do
    div(class: "panel-block #{attrs[:class]}") { children }
  end
end

Mithril::Component.define(:BulmaCard) do
  view do
    nav(class: "card #{attrs[:class]}") { children }
  end
end

Mithril::Component.define(:BulmaCardHeader) do
  view do
    header(class: "card-header #{attrs[:class]}") { children }
  end
end

Mithril::Component.define(:BulmaCardContent) do
  view do
    div(class: "card-content #{attrs[:class]}") { children }
  end
end

Mithril::Component.define(:BulmaCardFooter) do
  view do
    div(class: "card-footer #{attrs[:class]}") { children }
  end
end
