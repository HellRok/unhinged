module Bulma
  class Panel
    include Mithril::Component

    def view
      html do
        type = attrs.fetch(:type, "is-primary")
        nav(class: "panel #{type} #{attrs[:class]}") { children }
      end
    end

    class Heading
      include Mithril::Component

      def view
        html do
          p(class: "panel-heading #{attrs[:class]}") { children }
        end
      end
    end

    class Block
      include Mithril::Component

      def view
        html do
          div(class: "panel-block #{attrs[:class]}") { children }
        end
      end
    end
  end

  class Card
    include Mithril::Component

    def view
      html do
        nav(class: "card #{attrs[:class]}") { children }
      end
    end

    class Header
      include Mithril::Component

      def view
        html do
          header(class: "card-header #{attrs[:class]}") { children }
        end
      end
    end

    class Content
      include Mithril::Component

      def view
        html do
          div(class: "card-content #{attrs[:class]}") { children }
        end
      end
    end

    class Footer
      include Mithril::Component

      def view
        html do
          div(class: "card-footer #{attrs[:class]}") { children }
        end
      end
    end
  end

  class Skeleton
    include Mithril::Component

    def view
      html do
        div(class: "skeleton-block #{attrs[:class]}") { children }
      end
    end
  end

  class Box
    include Mithril::Component

    def view
      html do
        div(class: "box #{attrs[:class]}") { children }
      end
    end
  end
end
