module BootstrapHelpers
  class FormBuilder < ::ActionView::Helpers::FormBuilder
    def error_messages
      if object.errors.any?
        render_partial 'error_messages', errors: object.errors, inline: options[:inline]
      end
    end

    %w(text email date file password).each do |text_type|
      define_method "#{text_type}_field" do |field, *args|
        options = args.extract_options!

        group_options = options.delete(:group) || {}
        group field, group_options do
          add_class_to_options options, 'form-control'
          show_label = options.key?(:label) ? options.delete(:label) : true

          template.capture do
            if show_label
              label_options = show_label == true ? {} : show_label
              add_class_to_options label_options, 'sr-only' if self.options[:inline]
              options[:label] = label_options
              template.concat label(field, options)
            end
            template.concat input_field(field, *args, options) { |opts| super field, opts }
          end
        end
      end
    end

    def text_area field, *args
      options = args.extract_options!
      group_options = options.delete(:group) || {}

      group field, group_options do
        add_class_to_options options, 'form-control'
        show_label = options.key?(:label) ? options.delete(:label) : true

        template.capture do
          template.concat label(field, options) if show_label
          template.concat input_field(field, *args, options) { |opts| super field, opts }
        end
      end
    end

    def label field, *args, &block
      options = args.extract_options!
      label_options = options.delete(:label) || {}
      if options.key?(:required)
        add_class_to_options label_options, 'required' if options[:required]
      elsif field_required?(field)
        add_class_to_options label_options, 'required'
      end
      super field, *args, label_options
    end

    def select field, items, select_options = {}, options = {}
      group_options = options.delete(:group) || {}

      group field, group do
        add_class_to_options options, 'form-control'
        show_label = options.key?(:label) ? options.delete(:label) : true

        template.capture do
          template.concat label(field, options) if show_label
          template.concat input_field(field, options) { |opts| super field, items, select_options, opts }
        end
      end
    end

    def check_box field, *args
      options = args.extract_options!
      show_label = options.key?(:label) ? options.delete(:label) : true
      input_field(field, *args, options) do |input_options|
        if show_label
          label field, options do
            template.capture do
              template.concat super field, input_options
              template.concat ' '
              template.concat object.class.human_attribute_name field
            end
          end
        else
          super field, input_options
        end
      end
    end

    def group field, options = {}, &block
      options[:group] ||= {}
      add_class_to_options options[:group], 'has-error' if field_invalid?(field)

      in_group do
        content = template.capture { block.call }
        render_partial 'form_group', options: options[:group], help: options[:help], content: content
      end
    end

    def submit *args
      options = args.extract_options!
      add_class_to_options options, 'btn'
      super *args, options
    end

    private

    attr_reader :template

    def input_field field, options = {}, &block
      group_options = options.delete(:group) || {}
      unless in_group?
        return group(field, group_options) { input_field field, options, &block }
      end
      if self.options[:inline]
        options[:placeholder] ||= object.class.human_attribute_name field
      end
      if field_required?(field) && !options.key?(:required)
        options[:required] = true
      end
      if field_maxlength?(field) && !options.key(:maxlength)
        options[:maxlength] = field_maxlength field
      end
      if options.key?(:prefix) || options.key?(:suffix)
        render_partial 'input_group', prefix: options.delete(:prefix), suffix: options.delete(:suffix), content: block.call(options)
      else
        block.call options
      end
    end

    def render_partial partial_name, locals
      template.render partial: "bootstrap_helpers/#{partial_name}", locals: locals, format: [:html]
    end

    def in_group?
      @in_group
    end

    def in_group &block
      unless @in_group
        @in_group = true
        result = yield
        @in_group = false
        result
      end
    end

    def add_class_to_options options, class_name
      options[:class] ||= ''
      class_names = options[:class].split ' '
      unless class_names.include? class_name
        class_names << class_name
        options[:class] = class_names.join ' '
      end
    end

    def field_invalid? field
      object.errors[field].any?
    end

    def field_validators field
      object.class.validators_on(field)
    end

    def field_required? field
      validator_classes = field_validators(field).map(&:class)
      validator_classes.include?(ActiveRecord::Validations::PresenceValidator) ||
        validator_classes.include?(ActiveModel::Validations::PresenceValidator)
    end

    def field_maxlength? field
      field_validators(field).detect { |v| v.is_a? ActiveModel::Validations::LengthValidator }.present?
    end

    def field_maxlength field
      validator = field_validators(field).detect { |v| v.is_a? ActiveModel::Validations::LengthValidator }
      if validator
        validator_options = validator.instance_variable_get '@options'
        validator_options[:is] || validator_options[:maximum]
      end
    end
  end
end