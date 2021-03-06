module AttrJson
  module Type
    # You can wrap any ActiveModel::Type in one of these, and it's magically
    # a type representing an Array of those things, always returning
    # an array of those things on cast, serialize, and deserialize.
    #
    # Meant for use with AttrJson::Record and AttrJson::Model, may or
    # may not do something useful or without exceptions in other contexts.
    #
    #     AttrJson::Type::Array.new(base_type)
    class Array < ::ActiveModel::Type::Value
      attr_reader :base_type
      def initialize(base_type)
        @base_type = base_type
      end

      def type
        @type ||= "array_of_#{base_type.type}".to_sym
      end

      def cast(value)
        convert_to_array(value).collect { |v| base_type.cast(v) }
      end

      def serialize(value)
        convert_to_array(value).collect { |v| base_type.serialize(v) }
      end

      def deserialize(value)
        convert_to_array(value).collect { |v| base_type.deserialize(v) }
      end

      # This is used only by our own keypath-chaining query stuff.
      def value_for_contains_query(key_path_arr, value)
        [
          if key_path_arr.present?
            base_type.value_for_contains_query(key_path_arr, value)
          else
            base_type.serialize(base_type.cast value)
          end
        ]
      end

      # Hacky, hard-coded classes, but used in our weird primitive implementation in NestedAttributes,
      # better than putting the conditionals there
      def base_type_primitive?
        !(base_type.is_a?(AttrJson::Type::Model) || base_type.is_a?(AttrJson::Type::PolymorphicModel))
      end

      protected
      def convert_to_array(value)
        if value.kind_of?(Hash)
          [value]
        else
          Array(value)
        end
      end

    end
  end
end
