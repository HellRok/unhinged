require "native"

require "lib/mithril"

require "components/bulma"
require "components/counter"

require "views/home"

$$.document.addEventListener("DOMContentLoaded", -> {
  root = $$.document.getElementById("main")
  Mithril.route(
    root,
    "/",
    {
      "/": $$[:Home],
    },
  )
})
