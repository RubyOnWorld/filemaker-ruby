require 'filemaker/model/types/email'
require 'filemaker/model/types/attachment'

module Filemaker
  module Model
    class Field
      attr_reader :name, :type, :default_value, :fm_name

      def initialize(name, type, options = {})
        @name = name
        @type = type
        @default_value = coerce(options.fetch(:default) { nil })

        # We need to downcase because Filemaker::Record is
        # HashWithIndifferentAndCaseInsensitiveAccess
        @fm_name = (options.fetch(:fm_name) { name }).to_s.downcase
      end

      # From FileMaker to Ruby.
      #
      # If the value is `==` (match empty) or `=*` (match record), then we will
      # skip coercion.
      #
      # Date and DateTime will be special. If the value is a String, the query
      # may be '2016', '3/2016' or '3/24/2016' for example.
      def coerce(value, klass = nil)
        return nil if value.nil?
        return value if value =~ /^==|=\*/
        return value if value =~ /(\.\.\.)/

        if @type == String
          value.to_s
        elsif @type == Integer
          value.to_i
        elsif @type == BigDecimal
          BigDecimal(value.to_s)
        elsif @type == Date
          return value if value.is_a? Date
          return value.to_s if value.is_a? String
          Date.parse(value.to_s)
        elsif @type == DateTime
          return value if value.is_a? DateTime
          return value.to_s if value.is_a? String
          DateTime.parse(value.to_s)
        elsif @type == Filemaker::Model::Types::Email
          return value if value.is_a? Filemaker::Model::Types::Email
          Filemaker::Model::Types::Email.new(value)
        elsif @type == Filemaker::Model::Types::Attachment
          return value if value.is_a? Filemaker::Model::Types::Attachment
          Filemaker::Model::Types::Attachment.new(value, klass)
        else
          value
        end
      rescue StandardError => e
        warn "[#{e.message}] Could not coerce #{name}: #{value}"
        value
      end

      # When update_attributes(params[:model]) at the controller for a form
      # we do not need to care for range query or string date query
      def coerce_for_assignment(value, klass = nil)
        return nil if value.nil?
        return value if value =~ /^==|=\*/
        return value if value =~ /(\.\.\.)/

        if @type == String
          value.to_s
        elsif @type == Integer
          value.to_i
        elsif @type == BigDecimal
          BigDecimal(value.to_s)
        elsif @type == Date
          return value if value.is_a? Date
          Date.parse(value.to_s)
        elsif @type == DateTime
          return value if value.is_a? DateTime
          DateTime.parse(value.to_s)
        elsif @type == Filemaker::Model::Types::Email
          return value if value.is_a? Filemaker::Model::Types::Email
          Filemaker::Model::Types::Email.new(value)
        elsif @type == Filemaker::Model::Types::Attachment
          return value if value.is_a? Filemaker::Model::Types::Attachment
          Filemaker::Model::Types::Attachment.new(value, klass)
        else
          value
        end
      rescue StandardError => e
        warn "[#{e.message}] Could not coerce #{name}: #{value}"
        value
      end
    end
  end
end
