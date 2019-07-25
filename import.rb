class Import
  @@ids = {}

  class << self
    def bulk_import(objects)
      ActiveRecord::Base.connection.execute(generate_sql(objects))
    end

    private 

    def generate_ids(objects)

      model_class = objects.first.class
      
      relations = relations(model_class).select do |key, relation|
        relation.instance_of?(ActiveRecord::Reflection::HasManyReflection)
      end
      
      if relations.any?
        model_class = objects.first.class
        key = model_class.to_s.downcase + "_ids"
        next_id = next_id(model_class)
        @@ids[key] = (next_id...next_id + objects.count).to_a
        set_next_id(model_class, next_id + objects.count)

        relations(model_class).select do |key, relation|
          relation.instance_of?(ActiveRecord::Reflection::BelongsToReflection)
        end.each do |key, relation|
          
            
          count = objects.inject(0) do |t, o|
             t + (o.send(relation.name).present? ? 1 : 0)
          end

          init_val = next_id(relation.klass)
          end_val = init_val + count

          @@ids[relation.name.to_s + "_ids"] = (init_val...end_val).to_a
          set_next_id(relation.klass, end_val)
          
        end
      end

    end

    def generate_sql(objects)
      generate_ids(objects)
      model_class = objects.first.class
      relations = relations(model_class)
      sql = ''
      include_id = false

      if relations.any?
        has_many_relations = relations.select { |_, r| r.instance_of?(ActiveRecord::Reflection::HasManyReflection) }
        belongs_to_relations = relations.select { |_, r| r.instance_of?(ActiveRecord::Reflection::BelongsToReflection) }

        if has_many_relations.any?
          add_id_to_objects_and_references(objects, relations, model_class)
          include_id = true
        end

        objects_from_relations(objects, has_many_relations).each do |objects|
          sql += SqlGenerator.new(objects, false).generate_sql
        end

        objects_from_relations(objects, belongs_to_relations).each do |objects|
          sql += SqlGenerator.new(objects, true).generate_sql
        end
      end

      sql += SqlGenerator.new(objects, include_id).generate_sql
      sql
    end

    def relations(model_class)
      model_class.reflections.select do |key, reflection|
        reflection.instance_of?(ActiveRecord::Reflection::HasManyReflection) ||
        reflection.instance_of?(ActiveRecord::Reflection::BelongsToReflection)
      end
    end

    def next_id(model_class)
      model_class.connection.execute(
        "SELECT nextval('#{model_class.sequence_name}')"
      ).first['nextval']
    end

    def set_next_id(model_class, next_id)
      model_class.connection.execute(
        "ALTER SEQUENCE #{model_class.sequence_name} RESTART WITH #{next_id};"
      )
      
    end

    def add_id_to_objects_and_references(objects, relations, model_class)
      
      objects.each do |o|
        key = model_class.to_s.downcase + "_ids"
        o.id = @@ids[key].shift

        relations.each do |key, relation|
          if relation.instance_of?(ActiveRecord::Reflection::HasManyReflection)
            objects_from_relation = o.send(relation.plural_name)
            objects_from_relation.each do |object_from_relation|
              object_from_relation.send("#{relation.foreign_key}=", o.id)
            end
          elsif relation.instance_of?(ActiveRecord::Reflection::BelongsToReflection)
            if object_from_relation = o.send(relation.name)
              key = relation.klass.to_s.downcase + "_ids"
              object_from_relation.id = @@ids[key].shift
              o.send("#{relation.foreign_key}=", object_from_relation.id)
              o.send("#{relation.name}=", object_from_relation)
            end
          end
        end
      end
    end

    def objects_from_relations(objects, relations)
      relations.map do |key, relation|
        if relation.instance_of?(ActiveRecord::Reflection::HasManyReflection)
          objects.map do |o|
            o.send(relation.plural_name)
          end.flatten.compact
        elsif relation.instance_of?(ActiveRecord::Reflection::BelongsToReflection)
          objects.map do |o|
            o.send(relation.name)
          end.compact
        end
      end
    end
  end
end

class SqlGenerator
  def initialize(objects, include_id = false)
    @objects = objects

    if @objects.any?
      @include_id = include_id
      @fields = valid_attributes(objects.first)
      @values = valid_values(objects)
      @table_name = objects.first.class.table_name
    end
  end

  def generate_sql
    if @objects.any?
      "INSERT INTO #{@table_name} (#{@fields.join(', ')}) VALUES #{@values}; "
    else
      ""
    end
  end

  private

  def valid_attributes(object)
    if @include_id
      object.attributes.keys
    else
      object.attributes.reject { |key, value| [object.class.primary_key].include?(key) }.keys
    end
  end

  def valid_values(objects)
    objects.map do |o|
      "(#{values_of_object(o)})"
    end.join(', ')
  end

  def values_of_object(object)
    @fields.map do |field|
      if value = object.send(field)
        if value.is_a? Integer
          value
        else
          "'#{value.gsub("'", "''")}'"
        end
      else
        "NULL"
      end
    end.join(', ')
  end
end