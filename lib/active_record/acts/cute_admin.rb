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
      #     acts_as_cute_admin :display_name => :full_name, :order_by => [:last_name, :first_name],
      #     :index_columns => [:first_name, :last_name, :phone_numbers, :employer, {:employer => :city}]
      #   end
      #
      module ClassMethods
        # Configuration options are:
        #
        # * +display_name+ - specifies the method called to display data (default: +name+)
        # * +order_by+ - specifies column(s) for default ordering (default: same value as +display_name+)
        #   You can pass string or symbol or array of these.
        # * +index_columns+ - specifies columns displayed in generated index view
        #   If nothing is set then all columns will be displayed. Expected value is array of attribute names
        #   or names of associations or the same for associations (specified as hash).
        #   Nested hashes are not allowed.
        #   Example: <tt>acts_as_cute_admin :display_name => :full_name, :order_by => [:first_name, :last_name],
        #   :index_columns => [:first_name, :last_name, :phone_numbers, :employer, {:employer => :city}]</tt>
        def acts_as_cute_admin(options = {})
          configuration = { :display_name => :name }
          configuration.update(options) if options.is_a?(Hash)

          configuration[:order_by] = configuration[:display_name] unless configuration[:order_by]
          configuration[:order_by] = [configuration[:order_by]] unless configuration[:order_by].is_a?(Array)
          configuration[:index_columns] = nil unless configuration[:index_columns].is_a?(Array)

          class_eval <<-EOV
            include ActiveRecord::Acts::CuteAdmin::InstanceMethods

            def acts_as_cute_admin_class
              ::#{self.name}
            end

            class << self
              def acts_as_cute_admin?
                true
              end

              def display_name_method
                '#{configuration[:display_name]}'
              end

              def order_by_columns
                [#{configuration[:order_by].map{|col| "'#{col}'"}.join(", ")}]
              end

              def custom_list_columns
                #{configuration[:index_columns] ? configuration[:index_columns].inspect : "nil"}
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

              def has_many_and_has_and_belongs_to_many_associations
                return reflect_on_all_associations(:has_many) + reflect_on_all_associations(:has_and_belongs_to_many)
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
                columns.detect { |c| c.name == column_name.to_s }
              end
            end

          EOV
        end
      end

      # All the methods available to a record that has had <tt>acts_as_cute_admin</tt> specified.
      module InstanceMethods
        def display_name
          @display_name ||= send(self.class.display_name_method)
        end

        def display_name_to_param
          @display_name_to_param ||=
            if display_name
              param = ActiveSupport::Inflector.parameterize("#{display_name}")
              if param.empty?
                nil
              else
                param
              end
            else
              nil
            end
        end

        def to_param
          @to_param ||= display_name_to_param ? "#{super}-#{display_name_to_param}" : super
        end
      end
    end
  end
end
