namespace :cute_admin do

  # command line usage: rake cute_admin:generate
  desc "Generates cute_admin for given model or for all models. Specify single model with MODEL=x or all models will be processed."
  task :generate => :environment do
    require 'rails_generator'
    require 'rails_generator/scripts/generate'

    if ENV["MODEL"]
      models = [ENV["MODEL"]]
    else
      models = []
      Dir.chdir("app/models") do
        Dir.foreach(".") do |filename|
          if filename.match(/.*\.rb$/)
            models << filename.gsub(".rb", "")
          end
        end
      end
    end

    models.each do |model|
      begin
        model_class = model.singularize.camelize.demodulize.constantize
        model_class = nil unless model_class.respond_to?("acts_as_cute_admin?")
      rescue
        model_class = nil
      end

      if model_class
        Rails::Generator::Scripts::Generate.new.run(["cute_admin", "#{model}"])
        puts "Created cute_admin for #{model_class}"
      end
    end
  end

  # command line usage: rake cute_admin:generate_with_ajax
  desc "Generates ajax cute_admin for given model or for all models. Specify single model with MODEL=x or all models will be processed."
  task :generate_with_ajax => :environment do
    require 'rails_generator'
    require 'rails_generator/scripts/generate'

    if ENV["MODEL"]
      models = [ENV["MODEL"]]
    else
      models = []
      Dir.chdir("app/models") do
        Dir.foreach(".") do |filename|
          if filename.match(/.*\.rb$/)
            models << filename.gsub(".rb", "")
          end
        end
      end
    end

    models.each do |model|
      begin
        model_class = model.singularize.camelize.demodulize.constantize
        model_class = nil unless model_class.respond_to?("acts_as_cute_admin?")
      rescue
        model_class = nil
      end

      if model_class
        Rails::Generator::Scripts::Generate.new.run(["cute_admin", "#{model}", "--use-ajax"])
        puts "Created ajax cute_admin for #{model_class}"
      end
    end
  end

  # command line usage: rake cute_admin:generate_with_associations
  desc "Generates cute_admin for given model or for all models, including associations in index. Specify single model with MODEL=x or all models will be processed."
  task :generate_with_associations => :environment do
    require 'rails_generator'
    require 'rails_generator/scripts/generate'

    if ENV["MODEL"]
      models = [ENV["MODEL"]]
    else
      models = []
      Dir.chdir("app/models") do
        Dir.foreach(".") do |filename|
          if filename.match(/.*\.rb$/)
            models << filename.gsub(".rb", "")
          end
        end
      end
    end

    models.each do |model|
      begin
        model_class = model.singularize.camelize.demodulize.constantize
        model_class = nil unless model_class.respond_to?("acts_as_cute_admin?")
      rescue
        model_class = nil
      end

      if model_class
        Rails::Generator::Scripts::Generate.new.run(["cute_admin", "#{model}", "--add-associated"])
        puts "Created cute_admin with associations for #{model_class}"
      end
    end
  end

  # command line usage: rake cute_admin:generate_with_ajax_and_associations
  desc "Generates ajax cute_admin for given model or for all models, including associations in index. Specify single model with MODEL=x or all models will be processed."
  task :generate_with_ajax_and_associations => :environment do
    require 'rails_generator'
    require 'rails_generator/scripts/generate'

    if ENV["MODEL"]
      models = [ENV["MODEL"]]
    else
      models = []
      Dir.chdir("app/models") do
        Dir.foreach(".") do |filename|
          if filename.match(/.*\.rb$/)
            models << filename.gsub(".rb", "")
          end
        end
      end
    end

    models.each do |model|
      begin
        model_class = model.singularize.camelize.demodulize.constantize
        model_class = nil unless model_class.respond_to?("acts_as_cute_admin?")
      rescue
        model_class = nil
      end

      if model_class
        Rails::Generator::Scripts::Generate.new.run(["cute_admin", "#{model}", "--add-associated", "--use-ajax"])
        puts "Created ajax cute_admin with associations for #{model_class}"
      end
    end
  end

  # command line usage: rake cute_admin:activerecord_i18n_ruby
  desc "Prints i18n locale for ActiveRecord models and attributes in ruby format. Specify single model with MODEL=x or all models will be processed."
  task :activerecord_i18n_ruby => :environment do
    if ENV["MODEL"]
      models = [ENV["MODEL"]]
    else
      models = []
      Dir.chdir("app/models") do
        Dir.foreach(".") do |filename|
          if filename.match(/.*\.rb$/)
            models << filename.gsub(".rb", "")
          end
        end
      end
    end

    i18n_models = <<-CODE
      # ActiveRecord models
      :models => {
CODE
    i18n_attributes = <<-CODE
      # ActiveRecord model attributes
      :attributes => {
CODE

    models.each do |model|
      begin
        model_class = model.camelize.constantize
        model_class = nil unless model_class.respond_to?("acts_as_cute_admin?")
      rescue
        model_class = nil
      end

      if model_class
        model_underscored = "#{model_class}".underscore
        i18n_models << <<-CODE
        :#{model_underscored} => {
          :one => "",
          :other => "",
        },
CODE
        i18n_attributes << <<-CODE
        :#{model_underscored} => {
CODE
        model_class.cute_admin_form_columns.each do |column|
        i18n_attributes << <<-CODE
          :#{column.name} => "",
CODE
        end
        i18n_attributes << <<-CODE
        },
CODE
      end
    end
    i18n_models << <<-CODE
      },
CODE
    i18n_attributes << <<-CODE
      },
CODE
    puts i18n_models
    puts ""
    puts i18n_attributes
    puts ""
    puts "Simply copy this code to :activerecord section in your i18n locale file (it must be in ruby format, not YAML)."
  end
end

