require "lib/mithril/setup.js"

require "lib/mithril/vnode"

require "lib/mithril/component"
require "lib/mithril/html_renderer"

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
end
