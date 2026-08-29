module OpenTelemetry
  abstract class Instrument
    alias Number = Int8 | Int16 | Int32 | Int64 | UInt8 | UInt16 | UInt32 | UInt64 | Float32 | Float64

    struct Observation
      getter value : Float64
      getter attributes : Hash(String, ValueTypes)

      def initialize(value : Number, @attributes : Hash(String, ValueTypes))
        @value = value.to_f64
      end
    end

    getter name : String
    getter key_name : String = ""
    getter kind : String
    getter unit : String = ""
    getter description : String = ""
    property attributes : Hash(String, AnyAttribute) = {} of String => AnyAttribute
    property labels : Hash(String, String) = {} of String => String
    getter observations = [] of Observation
    @observation_lock = Mutex.new

    def initialize(@name, @kind, @unit = "", @description = "")
      validate_fields
      set_key_name
    end

    private def validate_fields
      validate_name
      validate_kind
      validate_unit
    end

    private def validate_name
      message = if @name.empty?
                  "Instrument names can not be empty"
                elsif @name !~ /^[a-zA-Z]/
                  "Instrument names must start with an alphabetic character"
                elsif @name !~ /^[a-zA-Z][a-zA-Z0-9_\-\.]*$/
                  "Instrument name must be comprised of only alphanumeric characters and '_', '.', and '-' characters"
                elsif @name.size > 63
                  "Instrument names must be less than 64 characters in length"
                else
                  nil
                end

      raise Meter::InstrumentNameError.new(message) if message
    end

    private def validate_kind
    end

    private def validate_unit
      raise Meter::InstrumentUnitError.new("Unit names must be less than 64 characters in length") if @unit.size > 63
    end

    private def set_key_name
      @key_name = @name.downcase
    end

    protected def observe(value : Number, attributes : Hash(String, ValueTypes)? = nil) : Nil
      observation = Observation.new(value, attributes || {} of String => ValueTypes)
      @observation_lock.synchronize { @observations << observation }
    end
  end
end

require "./instrument/*"

module OpenTelemetry
  alias Instruments = Instrument::Counter | Instrument::Histogram | Instrument::UpDownCounter
end
