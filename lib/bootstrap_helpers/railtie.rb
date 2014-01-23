class BootstrapHelpers::Railtie < ::Rails::Railtie
  initializer 'bootstrap_helpers', after: :after_initialize do
    ActionView::Base.send :include, BootstrapHelpers::FormHelpers
  end
end