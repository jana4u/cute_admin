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
        model_class = model.camelize.constantize
        model_class = nil unless model_class.respond_to?("acts_as_cute_admin?")
      rescue
        model_class = nil
      end

      if model_class
        Rails::Generator::Scripts::Generate.new.run(["cute_admin", "#{model_class}"])
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
        model_class = model.camelize.constantize
        model_class = nil unless model_class.respond_to?("acts_as_cute_admin?")
      rescue
        model_class = nil
      end

      if model_class
        Rails::Generator::Scripts::Generate.new.run(["cute_admin", "#{model_class}", "--use-ajax"])
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
        model_class = model.camelize.constantize
        model_class = nil unless model_class.respond_to?("acts_as_cute_admin?")
      rescue
        model_class = nil
      end

      if model_class
        Rails::Generator::Scripts::Generate.new.run(["cute_admin", "#{model_class}", "--add-associated"])
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
        model_class = model.camelize.constantize
        model_class = nil unless model_class.respond_to?("acts_as_cute_admin?")
      rescue
        model_class = nil
      end

      if model_class
        Rails::Generator::Scripts::Generate.new.run(["cute_admin", "#{model_class}", "--add-associated", "--use-ajax"])
        puts "Created ajax cute_admin with associations for #{model_class}"
      end
    end
  end

end
