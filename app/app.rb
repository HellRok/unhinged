require "native"

require "lib/mithril"

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
