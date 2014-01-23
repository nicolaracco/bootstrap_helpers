module BootstrapHelpers
end

# load Rails/Railtie
begin
  require 'rails'
rescue LoadError
  # do nothing
end

$stderr.puts <<-EOC if !defined?(Rails)
warning: Rails not detected.

Your Gemfile might not be configured properly.
---- e.g. ----
    gem 'kaminari'
EOC

require "bootstrap_helpers/version"
require "bootstrap_helpers/form_builder"
require "bootstrap_helpers/form_helpers"

# Rails
require "bootstrap_helpers/railtie"
require "bootstrap_helpers/engine"