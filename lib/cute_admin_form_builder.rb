module ActionView
  module Helpers
    class FormBuilder
      def field_set(legend = nil, options = nil, &block)
        @template.field_set(legend, options, &block)
      end
    end

    module FormHelper
      def cute_admin_form_for(record_or_name_or_array, *args, &proc)
        options = args.extract_options!
        if options[:html].nil? then
         options[:html] = { :class => "cmxform" }
        else
         options[:html][:class] = (options[:html][:class].nil?) ? "cmxform" : "cmxform #{options[:html][:class]}"
        end
        options[:builder] = CuteAdminFormBuilder
        args << options
        form_for(record_or_name_or_array, *args, &proc)
      end

      def field_set(legend = nil, options = nil, &block)
        content = capture(&block)
        concat(tag(:fieldset, options, true))
        concat(content_tag(:legend, legend)) unless legend.blank?
        concat(content_tag(:ul, content))
        concat("</fieldset>")
      end
    end
  end
end

class CuteAdminFormBuilder < ActionView::Helpers::FormBuilder
  helpers = field_helpers +
            %w{date_select datetime_select time_select} +
            %w{collection_select select country_select time_zone_select} -
            %w{hidden_field label fields_for} # Don't decorate these

  helpers.each do |name|
    define_method(name) do |field, *args|
      options = args.extract_options!
      label = label(field, options[:label], :class => options[:label_class])
      errors = error_message_on(field)
      @template.content_tag(:li, label + " " + super + " " + errors)
    end
  end

end
