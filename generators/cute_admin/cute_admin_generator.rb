class CuteAdminGenerator < Rails::Generator::NamedBase
  require 'cute_admin_generated_attribute'
  default_options :force_plural => false, :add_associated => false, :use_ajax => false

  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_underscore_name,
                :controller_singular_name,
                :controller_plural_name,
                :list_attributes,
                :form_attributes,
                :show_attributes
  alias_method  :controller_file_name,  :controller_underscore_name
  alias_method  :controller_table_name, :controller_plural_name

  def initialize(runtime_args, runtime_options = {})
    super

    if @name == @name.pluralize && !options[:force_plural]
      logger.warning "Plural version of the model detected, using singularized version.  Override with --force-plural."
      @name = @name.singularize
    end

    @controller_name = @name.pluralize

    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_underscore_name, @controller_plural_name = inflect_names(base_name)
    @controller_singular_name = base_name.singularize
    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end

    @form_attributes = []
    if model_class.respond_to?("acts_as_cute_admin?")
      model_class.cute_admin_form_columns.each do |column|
        attribute = CuteAdminGeneratedAttribute.new(column, model_name, false)
        @form_attributes << attribute
      end
    else
      raise Rails::Generator::UsageError, "Model '#{model_name}' is not set as acts_as_cute_admin."
    end

    @list_attributes = []
    model_class.cute_admin_list_columns.each do |column|
      attribute = CuteAdminGeneratedAttribute.new(column, model_name, options[:add_associated])
      @list_attributes << attribute
    end
    @show_attributes = @list_attributes.clone

    if model_class.custom_list_columns.nil?
      if options[:add_associated]
        all_attributes = []
        @list_attributes.each do |attribute|
          all_attributes << attribute
          all_attributes += attribute.associated_attributes
        end
        @list_attributes = all_attributes
        model_class.has_many_and_has_and_belongs_to_many_associations.each do |has_many_association|
          @list_attributes << CuteAdminGeneratedAttribute.new(has_many_association.klass.column_by_name(has_many_association.klass.display_name_method) || ActiveRecord::ConnectionAdapters::Column.new(association.klass.display_name_method, nil, "string"), has_many_association, false, model_class)
        end
      end
    else
      @list_attributes = []
      model_class.custom_list_columns.each do |custom_column|
        @list_attributes << create_attribute(model_class, custom_column)
      end
    end
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      #m.class_collisions(controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}Helper")
      #m.class_collisions(class_path, "#{class_name}")

      # Controller, helper, views, test and stylesheets directories.
      m.directory(File.join('app/controllers', controller_class_path))
      m.directory(File.join('app/helpers', controller_class_path))
      m.directory(File.join('app/views', controller_class_path, controller_file_name))
      m.directory(File.join('app/views/layouts'))
      m.directory(File.join('test/functional', controller_class_path))
      m.directory(File.join('public/stylesheets'))

      for action in scaffold_views
        m.template(
          "view_#{action}.html.erb",
          File.join('app/views', controller_class_path, controller_file_name, "#{action}.html.erb")
        )
      end

      # Layout and stylesheet.
      m.template('layout.html.erb', 'app/views/layouts/cute_admin.html.erb')
      m.template('style.css', 'public/stylesheets/cute_admin.css')

      m.template(
        'controller.rb', File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
      )

      m.template('functional_test.rb', File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))
      m.template('helper.rb',          File.join('app/helpers',     controller_class_path, "#{controller_file_name}_helper.rb"))

      m.route_resources controller_file_name
    end
  end

  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} cute_admin ModelName [field:type, field:type]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--force-plural",
             "Forces the generation of a plural ModelName") { |v| options[:force_plural] = v }
      opt.on("--add-associated",
             "Add fields from associated models to listing") { |v| options[:add_associated] = v }
      opt.on("--use-ajax",
             "Use ajax in index.") { |v| options[:use_ajax] = v }
    end

    def scaffold_views
      %w[ index show new edit _form ]
    end

    def model_name
      @model_name ||= class_name.demodulize
    end

    def model_class
      begin
        @model_class ||= model_name.constantize
      rescue NameError
        raise Rails::Generator::UsageError, "Model '#{model_name}' does not exist. Enter a valid model name or use model generator to create this one."
      end
    end

    def nested_routes?
      @nested_routes ||= !controller_class_path.empty?
    end

    def form_nesting
      @form_nesting ||= controller_class_path.map { |part| ":#{part}" }.join(", ")
    end

    def singular_route_path
      @singular_route_path ||= (controller_class_path + [singular_name, "path"]).compact.join("_")
    end

    def plural_route_path
      @plural_route_path ||= (controller_class_path + [plural_name, "path"]).compact.join("_")
    end

    def singular_route_url
      @singular_route_url ||= (controller_class_path + [singular_name, "url"]).compact.join("_")
    end

    def plural_route_url
      @plural_route_url ||= (controller_class_path + [plural_name, "url"]).compact.join("_")
    end

    def url_namespace
      @url_namespace ||= nested_routes? ? "/#{controller_class_path.compact.join("/")}" : ""
    end

    def create_attribute(model_class_param, column_config, full_column_config = nil, resource_association = nil)
      full_column_config = column_config unless full_column_config
      if column_config.is_a?(Hash)
        raise Rails::Generator::UsageError, "Too complicated column specification: #{full_column_config.inspect}." if model_class_param != model_class
        resource_association = model_class_param.association_by_name(column_config.keys.first)
        raise Rails::Generator::UsageError, "Model '#{model_class_param}' does not have association called '#{column_config.keys.first}'." unless resource_association
        return create_attribute(resource_association.klass, column_config.values.first, full_column_config, resource_association)
      else
        column = model_class_param.column_by_name(column_config)
        unless column
          association = model_class_param.association_by_name(column_config)
          column = model_class_param.column_by_name(association.primary_key_name) if association and association.macro == :belongs_to
        end
        if column
          return CuteAdminGeneratedAttribute.new(column, resource_association || "#{model_class_param}") unless resource_association
          return CuteAdminGeneratedAttribute.new(column, resource_association, false, "#{model_class_param}")
        end
        raise Rails::Generator::UsageError, "Model '#{model_class_param}' does not have column or association called '#{column_config}'." if column.nil? and association.nil?
        raise Rails::Generator::UsageError, "Model '#{association.klass}' is not set as acts_as_cute_admin." unless association.klass.respond_to?("acts_as_cute_admin?")
        return CuteAdminGeneratedAttribute.new(association.klass.column_by_name(association.klass.display_name_method) || ActiveRecord::ConnectionAdapters::Column.new(association.klass.display_name_method, nil, "string"), resource_association || association, false, model_class_param)
      end
    end
end
