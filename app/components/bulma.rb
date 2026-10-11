module Bulma
  class Panel
    include Mithril::Component

    def view
      type = attrs.fetch(:type, "is-primary")
      nav(class: "panel #{type} #{attrs[:class]}") { children }
    end

    class Heading
      include Mithril::Component

      def view
        p(class: "panel-heading #{attrs[:class]}") { children }
      end
    end

    class Block
      include Mithril::Component

      def view
        div(class: "panel-block #{attrs[:class]}") { children }
      end
    end
  end

  class Card
    include Mithril::Component

    def view
      nav(class: "card #{attrs[:class]}") { children }
    end

    class Header
      include Mithril::Component

      def view
        header(class: "card-header #{attrs[:class]}") { children }
      end
    end

    class Content
      include Mithril::Component

      def view
        div(class: "card-content #{attrs[:class]}") { children }
      end
    end

    class Footer
      include Mithril::Component

      def view
        div(class: "card-footer #{attrs[:class]}") { children }
      end
    end
  end

  class Skeleton
    include Mithril::Component

    def view
      div(class: "skeleton-block #{attrs[:class]}") { children }
    end
  end

  class Box
    include Mithril::Component

    def view
      div(class: "box #{attrs[:class]}") { children }
    end
  end
end
