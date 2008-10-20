namespace :cute_admin do

  # command line usage: rake cute_admin:generate
  desc "Generates cute_admin for given model or for all models. Specify single model with MODEL=x or all models will be processed."
  task :generate => :environment do
    if ENV["MODEL"]
      process_models=[ENV["MODEL"]]
    else
      models=[]
      process_models=[]
      Dir.chdir("app/models") do
        Dir.foreach(".") {|x|
          models << x.gsub(".rb","") if x.match(/.*\.rb$/)
        }
      end
      for model in models do
        process_models << model if model.camelize.constantize.respond_to?(:cute_admin_list_columns)
      end
    end

    for pmodel in process_models do
      require 'rails_generator'
      require 'rails_generator/scripts/generate'
      Rails::Generator::Scripts::Generate.new.run(["cute_admin", pmodel])
      puts "Created cute_admin for #{pmodel.camelize}"
    end
  end

  # command line usage: rake cute_admin:generate_with_associations
  desc "Generates cute_admin for given model, including belongs_to associations in index. You must specify model with MODEL=x."
  task :generate_with_associations => :environment do
    if ENV["MODEL"]
      model=ENV["MODEL"]
      params=["cute_admin", model]

      params << "--add-associated"

      require 'rails_generator'
      require 'rails_generator/scripts/generate'
      Rails::Generator::Scripts::Generate.new.run(params)
      puts "Created cute_admin with associations for #{model.camelize}"
    else
      puts "You must specify model with MODEL=x."
    end
  end

end
