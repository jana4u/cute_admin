class CuteAdminGenerator < Rails::Generator::NamedBase
  require 'cute_admin_generated_attribute'
  default_options :force_plural => false, :add_associated => false

  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_underscore_name,
                :controller_singular_name,
                :controller_plural_name
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
    @controller_singular_name=base_name.singularize
    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end

    @form_attributes = []
    if model_class.respond_to?(:cute_admin_form_columns)
      for column in model_class.cute_admin_form_columns do
        attribute = CuteAdminGeneratedAttribute.new(column.name, column.type, class_name, false)
        @form_attributes << attribute
      end
    else
      raise Rails::Generator::UsageError, "Model #{class_name} is not set as acts_as_cute_admin."
    end

    @list_attributes = []
    for column in model_class.cute_admin_list_columns do
      attribute = CuteAdminGeneratedAttribute.new(column.name, column.type, class_name, options[:add_associated])
      @list_attributes << attribute
    end
    @show_attributes = @list_attributes.clone

    if options[:add_associated]
      all_attributes = []
      for attribute in @list_attributes do
        all_attributes << attribute
        all_attributes += attribute.associated_attributes
      end
      @list_attributes = all_attributes
    end
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      #m.class_collisions(controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}Helper")
      #m.class_collisions(class_path, "#{class_name}")

      # Controller, helper, views, test and stylesheets directories.
      m.directory(File.join('app/models', class_path))
      m.directory(File.join('app/controllers', controller_class_path))
      m.directory(File.join('app/helpers', controller_class_path))
      m.directory(File.join('app/views', controller_class_path, controller_file_name))
      m.directory(File.join('app/views/layouts', controller_class_path))
      #m.directory(File.join('test/functional', controller_class_path))
      #m.directory(File.join('test/unit', class_path))
      m.directory(File.join('public/stylesheets', class_path))

      for action in scaffold_views
        m.template(
          "view_#{action}.html.erb",
          File.join('app/views', controller_class_path, controller_file_name, "#{action}.html.erb")
        )
      end

      # Layout and stylesheet.
      #m.template('layout.html.erb', File.join('app/views/layouts', controller_class_path, "#{controller_file_name}.html.erb"))
      m.template('layout.html.erb', File.join('app/views/layouts', controller_class_path, "cute_admin.html.erb"))
      m.template('style.css', 'public/stylesheets/cute_admin.css')

      m.template(
        'controller.rb', File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
      )

      #m.template('functional_test.rb', File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))
      m.template('helper.rb',          File.join('app/helpers',     controller_class_path, "#{controller_file_name}_helper.rb"))

      m.route_resources controller_file_name

      #m.dependency 'model', [name] + @args, :collision => :skip
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
             "Add all fields from associated (belongs_to) models to listing") { |v| options[:add_associated] = v }
    end

    def scaffold_views
      %w[ index show new edit _form ]
    end

    def model_name
      class_name.demodulize
    end

    def model_class
      begin
        @model_class ||= class_name.constantize
      rescue
        raise Rails::Generator::UsageError, "Model #{class_name} does not exist. Enter a valid model name or use model generator to create this one."
      end
    end

    def list_attributes
      @list_attributes
    end

    def form_attributes
      @form_attributes
    end

    def show_attributes
      @show_attributes
    end
end
