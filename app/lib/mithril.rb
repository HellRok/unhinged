if RUBY_ENGINE == "opal"
  require_relative "mithril/setup.js"

  require_relative "mithril/vnode"

  require_relative "mithril/component"
  require_relative "mithril/html_renderer"

  require_relative "mithril/components/link"

  module Mithril
    def self.route(elem, path, routes)
      $$.m_route(elem, path, routes.to_n)
    end

    def self.request(url:, method: "GET", body: {}, credentials: true)
      $$.m_request({
        method: method,
        url: url,
        body: body,
        withCredentials: credentials
      }.to_n)
    end

    def self.redraw
      $$.m_redraw()
    end

    def self.mount(element, component)
      $$.m_mount(element, $$[component])
    end
  end

else
  require 'opal'

  Opal.append_path File.dirname(__FILE__)
end
