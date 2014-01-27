module BootstrapHelpers
  module FormHelpers
    %w(form_for fields_for).each do |method|
      define_method "bootstrap_#{method}" do |*args, &block|
        options = args.extract_options!
        if method == 'form_for'
          options[:html] ||= {}
          options[:html][:role] ||= 'form'
          if options[:inline]
            options[:html][:class] ||= ''
            options[:html][:class] << ' form-inline'
            options[:html][:class].strip!
          end
        end
        options[:builder] = FormBuilder

        with_customized_error_wrapper do
          send method, *args, options, &block
        end
      end
    end

    private

    def with_customized_error_wrapper &block
      original_field_error_proc = ::ActionView::Base.field_error_proc
      ::ActionView::Base.field_error_proc = Proc.new do |tag, instance|
        locals = { tag: tag.html_safe, instance: instance }
        render partial: 'bootstrap_helpers/input_error_wrapper', locals: locals, format: [:html]
      end
      yield
    ensure
      ::ActionView::Base.field_error_proc = original_field_error_proc
    end
  end
end