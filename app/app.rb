require "native"

require "lib/mithril"

require "components/bulma"
require "components/counter"
require "components/data_loading_example"
require "components/nav_links"

require "views/home"
require "views/content"
require "views/counters"
require "views/loading"

$$.document.addEventListener("DOMContentLoaded", -> {
  root = $$.document.getElementById("main")
  Mithril.route(
    root,
    "/",
    {
      "/": $$[:Home],
      "/counters": $$[:Counters],
      "/content": $$[:Content],
      "/loading": $$[:Loading],
    }
  )
})
