Gem::Specification.new do |gem|
  gem.name = "opal-mithril"
  gem.version = "0.0.1"
  gem.summary = "Configure Mithril to work in Opal"
  gem.authors = ["Sean Earle"]
  gem.email = ["sean.r.earle@gmail.com"]

  gem.files = `git ls-files`.split($\)
  gem.require_paths = ["app/lib"]

  gem.license = "MIT"

  gem.add_runtime_dependency 'opal'
end
