class CuteAdminGeneratedAttribute < Rails::Generator::GeneratedAttribute
  attr_reader :model, :association, :associated_attributes, :parent, :resource_association

  def initialize(db_column, model_name, include_associations = false, parent = nil)
    @column = db_column
    @name, @type = db_column.name, db_column.type
    unless model_name.kind_of?(ActiveRecord::Reflection::AssociationReflection)
      @model = model_name.to_s.camelize.constantize
      cute_admin_check(model)
    else
      @model = model_name.klass
      cute_admin_check(model)
      @resource_association = model_name
      @type = :string if is_association_to_many? and model_name.klass.order_by_columns.size > 1
    end
    @parent = parent
    @association = model.belongs_to_association_by_attribute(name) unless is_association_to_many?
    cute_admin_check(association.klass) if association
    @associated_attributes = []
    association.klass.cute_admin_list_columns.each do |column|
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
    @display_name ||=
      if association
        if parent
          "\"#\{#{parent_display_name}} &ndash; #\{#{association.class_name}.human_name}\""
        else
          "#{association.class_name}.human_name"
        end
      else
        if parent
          if is_association_to_many?
            "#{model}.human_name(:count => 2)"
          else
            "\"#\{#{parent_display_name}} &ndash; #\{#{model}.human_attribute_name(\"#{name}\")}\""
          end
        else
          "#{model}.human_attribute_name(\"#{name}\")"
        end
      end
  end

  def parent_display_name
    @parent_display_name ||= parent ? "#{resource_association.class_name}.human_name" : ""
  end

  def order_by
    @order_by ||= parent ? "{:#{resource_association.name} => #{order_columns}}" : "#{order_columns}"
  end

  def order_columns
    @order_columns ||=
      if association
        if association.klass.order_by_columns.size > 1
          "{:#{association.name} => [#{association.klass.order_by_columns.map{|oc| ":#{oc}"}.join(", ")}]}"
        else
          "{:#{association.name} => :#{association.klass.order_by_columns.first}}"
        end
      elsif is_association_to_many?
        order_cols = resource_association.klass.order_by_columns
        order_cols.size > 1 ? "[#{order_cols.map{|oc| ":#{oc}"}.join(", ")}]" : ":#{order_cols.first}"
      else
        ":#{name}"
      end
  end

  def column_class
    @column_class ||= association ? "string-column" : "#{type}-column"
  end

  def formatted_value(object_name)
    value_call = value_accessor(object_name)
    existence_check = existence_check(value_call)
    return "h(#{value_call})#{existence_check}" if association
    return "#{output_value_formatted(value_call)}#{existence_check}" unless is_association_to_many?
    return "#{value_call}#{existence_check}"
  end

  def value_accessor(object_name)
    access_name =
      if association
        "#{association.name}.display_name"
      elsif is_association_to_many?
        resource_association.klass.display_name_method
      else
        name
      end
    value_accessor =
      if parent
        if is_association_to_many?
          "#{object_name}.#{resource_association.name}.map{|x| #{output_value_formatted("x.#{access_name}")}}.sort.join(\"<br />\")"
        else
          "#{object_name}.#{resource_association.name}.#{access_name}"
        end
      else
        "#{object_name}.#{access_name}"
      end
    return value_accessor
  end

  def existence_check(accessor)
    accessor_parts = accessor.split(".")
    conditions = []
    if accessor_parts.size > 2 and not is_association_to_many?
      while accessor_parts.size > 2 do
        accessor_parts.pop
        conditions << accessor_parts.join(".")
      end
    end
    existence_check = conditions.empty? ? "" : " if #{conditions.reverse.join(" and ")}"
    return existence_check
  end

  def searchlogic_field(search_object_name, parent_checked = false)
    if parent_checked or not parent
      unless association
        if type == :boolean
          "<%= #{search_object_name}.select :#{name}_equals, booleans_for_select %>"
        else
          "<%= #{search_object_name}.text_field :#{name}_contains %>"
        end
      else
        "<%= #{search_object_name}.select :#{name}_equals, #{association.class_name}.for_select_with_all %>"
      end
    else
      "<% #{search_object_name}.fields_for #{search_object_name}.object.#{resource_association.name} do |#{resource_association.name}| %>#{searchlogic_field(resource_association.name, true)}<% end %>"
    end
  end

  def form_field
    unless association
      @form_field ||= "#{field_type} :#{name}"
    else
      @form_field ||= "select :#{name}, #{association.class_name}.for_select, { :label => #{association.class_name}.human_name#{select_include_blank} }"
    end
  end

  def select_include_blank
    @select_include_blank ||= column.null ? ", :include_blank => true" : ""
  end

  def is_association_to_many?
    @has_many_association ||= resource_association ? (resource_association.macro == :has_many || resource_association.macro == :has_and_belongs_to_many) : false
  end

  def output_value_formatted(value_call)
    case type
    when :float, :decimal             then return "number_with_delimiter(#{value_call})"
    when :datetime                    then return "cute_datetime(#{value_call})"
    when :time                        then return "cute_time(#{value_call})"
    when :date                        then return "cute_date(#{value_call})"
    when :string, :text               then return "h(#{value_call})"
    when :boolean                     then return "cute_boolean(#{value_call})"
    else
      return "#{value_call}"
    end
  end

  private

  def cute_admin_check(checked_class)
    raise Rails::Generator::UsageError, "Model '#{checked_class}' is not set as acts_as_cute_admin." unless checked_class.respond_to?("acts_as_cute_admin?")
  end
end
