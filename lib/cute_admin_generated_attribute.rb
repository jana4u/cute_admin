class CuteAdminGeneratedAttribute < Rails::Generator::GeneratedAttribute
  attr_reader :model, :association, :associated_attributes, :parent, :resource_association

  def initialize(db_column, model_name, include_associations = false, parent = nil)
    @column = db_column
    @name, @type = db_column.name, db_column.type
    unless model_name.kind_of?(ActiveRecord::Reflection::AssociationReflection)
      @model = model_name.to_s.camelize.constantize
    else
      @model = model_name.klass
      @resource_association = model_name
    end
    @parent = parent
    @association = model.belongs_to_association_by_attribute(name)
    @associated_attributes = []
    for column in association.klass.cute_admin_list_columns do
      attr = CuteAdminGeneratedAttribute.new(column, association, false, model)
      @associated_attributes << attr
    end if association and include_associations
  end

  def field_type
    @field_type ||= case type
    when :integer, :float, :decimal   then :text_field
    when :datetime, :timestamp        then :datetime_select
    when :time                        then :time_select
    when :date                        then :date_select
    when :string                      then :text_field
    when :text                        then :text_area
    when :boolean                     then :check_box
    else
      :text_field
    end
  end

  def display_name
    if association
      @display_name ||= parent ? "\"#\{#{parent_display_name}} &ndash; #\{#{association.class_name}.human_name}\"" : "#{association.class_name}.human_name"
    else
      @display_name ||= parent ? "\"#\{#{parent_display_name}} &ndash; #\{#{model}.human_attribute_name(\"#{name}\")}\"" : "#{model}.human_attribute_name(\"#{name}\")"
    end
  end

  def parent_display_name
    @parent_display_name ||= parent ? "#{resource_association.class_name}.human_name" : ""
  end

  def order_by
    @order_by ||= parent ? "{:#{resource_association.name} => #{order_columns}}" : "#{order_columns}"
  end

  def order_columns
    @order_columns ||= association ? (association.klass.order_by_columns.size > 1 ? "{:#{association.name} => [#{association.klass.order_by_columns.map{|oc| ":#{oc}"}.join(", ")}]}" : "{:#{association.name} => :#{association.klass.order_by_columns.first}}") : ":#{name}"
  end

  def column_class
    @column_class ||= association ? "string-column" : "#{type}-column"
  end

  def formatted_value(object_name)
    value_call = value_accessor(object_name)
    existence_check = existence_check(value_call)
    return "h(#{value_call})#{existence_check}" if association

    formatted_value = case type
    when :integer, :float, :decimal   then "number_with_delimiter(#{value_call})#{existence_check}"
      #when :datetime, :timestamp        then :datetime_select
    when :time                        then "#{value_call}.to_s(:time_only)#{existence_check}"
      #when :date                        then :date_select
    when :string, :text               then "h(#{value_call})#{existence_check}"
    when :boolean                     then "nice_boolean(#{value_call})#{existence_check}"
    else
      "#{value_call}#{existence_check}"
    end
    return formatted_value
  end

  def value_accessor(object_name)
    access_name = association ? "#{association.name}.display_name" : name
    @value_accessor = parent ? "#{object_name}.#{model.name.underscore}.#{access_name}" : "#{object_name}.#{access_name}"
  end

  def existence_check(accessor)
    accessor_parts = accessor.split(".")
    conditions = []
    if accessor_parts.size > 2
      while accessor_parts.size > 2 do
        accessor_parts.pop
        conditions << accessor_parts.join(".")
      end
    end
    existence_check = conditions.empty? ? "" : " if #{conditions.reverse.join(" and ")}"
    return existence_check
  end

  def searchgasm_field(search_object_name, parent_checked = false)
    if parent_checked or not parent
      unless association
        if type == :boolean
          "<%= #{search_object_name}.select :#{name}_equals, [[I18n.t(:all, :default => '[ all ]', :scope => [:railties, :scaffold]), nil], [nice_boolean(true), true], [nice_boolean(false), false]] %>"
        else
          "<%= #{search_object_name}.text_field :#{name}_contains %>"
        end
      else
        "<%= #{search_object_name}.select :#{name}_equals, #{association.class_name}.for_select_with_all %>"
      end
    else
      "<% #{search_object_name}.fields_for #{search_object_name}.object.#{resource_association.name} do |#{resource_association.name}| %>#{searchgasm_field(resource_association.name, true)}<% end %>"
    end
  end

  def form_field
    unless association
      @form_field ||= "#{field_type} :#{name}"
    else
      @form_field ||= "select :#{name}, #{association.class_name}.for_select#{select_include_blank}"
    end
  end

  def select_include_blank
    @select_include_blank ||= column.null ? ", { :include_blank => true }" : ""
  end
end
