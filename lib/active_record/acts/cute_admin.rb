module ActiveRecord
  module Acts #:nodoc:
    module CuteAdmin #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end

      # This +acts_as+ extension provides methods for cute_admin.
      # Example:
      #
      #   class User < ActiveRecord::Base
      #     acts_as_cute_admin :display_name => :full_name, :order_by => [:last_name, :first_name]
      #   end
      #
      module ClassMethods
        # Configuration options are:
        #
        # * +display_name+ - specifies the method called to display data (default: +name+)
        # * +order_by+ - specifies column(s) for default ordering (default: same value as +display_name+);
        #   you can pass string or symbol or array of these
        #   Example: <tt>acts_as_cute_admin :display_name => :full_name, :order_by => [:first_name, :last_name]</tt>
        def acts_as_cute_admin(options = {})
          configuration = { :display_name => :name }
          configuration.update(options) if options.is_a?(Hash)

          configuration[:order_by] = configuration[:display_name] unless configuration[:order_by]
          configuration[:order_by] = [configuration[:order_by]] unless configuration[:order_by].is_a?(Array)

          class_eval <<-EOV
            include ActiveRecord::Acts::CuteAdmin::InstanceMethods

            def acts_as_cute_admin_class
              ::#{self.name}
            end

            class << self
              def display_name_method
                '#{configuration[:display_name]}'
              end

              def order_by_columns
                [#{configuration[:order_by].map{|col| "'#{col}'"}.join(", ")}]
              end
            end

          EOV
        end

        def for_select_with_all(conditions = nil, include = nil)
          [[I18n.t(:all, :default => '[ all ]', :scope => [:railties, :scaffold]), nil]] + for_select(conditions, include)
        end

        def for_select(conditions = nil, include = nil)
          return find(:all, :conditions => conditions, :include => include, :order => order_by_columns.join(", ")).map{|x| [x.display_name, x.id]}
        end

        def belongs_to_association_by_attribute(attribute)
          return reflect_on_all_associations(:belongs_to).find{|x| x.primary_key_name == attribute.to_s}
        end

        def has_many_associations
          return reflect_on_all_associations(:has_many)
        end

        def association_by_name(association_name)
          return reflect_on_all_associations.find{|x| x.name == association_name.to_sym}
        end

        def timestamp_column_names
          @timestamp_column_names ||= %w(created_at created_on updated_at updated_on deleted_at deleted_on)
        end

        def cute_admin_list_columns
          @cute_admin_list_columns ||= columns.reject { |c| c.primary || c.name == inheritance_column }
        end

        def cute_admin_form_columns
          @cute_admin_form_columns ||= cute_admin_list_columns.reject { |c| timestamp_column_names.include?(c.name) }
        end

        def column_by_name(column_name)
          columns.detect { |c| c.name == column_name }
        end
      end

      # All the methods available to a record that has had <tt>acts_as_cute_admin</tt> specified.
      module InstanceMethods
        def display_name
          @display_name ||= send(self.class.display_name_method)
        end

        def to_param
          @to_param ||= "#{id}-#{ActiveSupport::Inflector.parameterize(display_name)}"
        end
      end
    end
  end
end
