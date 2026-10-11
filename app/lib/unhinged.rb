if RUBY_ENGINE == "opal"
  require_relative "unhinged/setup.js"

  require_relative "unhinged/vnode"

  require_relative "unhinged/html_renderer"
  require_relative "unhinged/component"

  require_relative "unhinged/components/link"

  module Unhinged
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
