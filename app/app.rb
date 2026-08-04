require "native"

require "lib/mithril"

require "components/bulma"
require "components/counter"
require "components/data_loading_example"

require "views/home"

$$.document.addEventListener("DOMContentLoaded", -> {
  root = $$.document.getElementById("main")
  Mithril.route(
    root,
    "/",
    {
      "/": $$[:Home]
    }
  )
})
