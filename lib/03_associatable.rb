require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    variables = {
      foreign_key: "#{name.to_s.underscore}_id".to_sym,
      primary_key: :id,
      class_name: name.to_s.camelcase
    }.merge(options)
    @foreign_key = variables[:foreign_key]
    @primary_key = variables[:primary_key]
    @class_name = variables[:class_name]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    variables = {
      foreign_key: "#{self_class_name.underscore}_id".to_sym,
      primary_key: :id,
      class_name: name.to_s.camelcase.singularize
    }.merge(options)

    @foreign_key = variables[:foreign_key]
    @primary_key = variables[:primary_key]
    @class_name = variables[:class_name]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    assoc_options[name] = options

    define_method(name) do
      foreign_key_value = send(options.foreign_key)
      target_model_class = options.model_class
      primary_key = options.primary_key
      target_model_class.where(primary_key => foreign_key_value).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    define_method(name) do
      target_model_class = options.model_class
      foreign_key = options.foreign_key
      primary_key_value = send(options.primary_key)
      target_model_class.where(foreign_key => primary_key_value)

    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
