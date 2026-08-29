require "../instrument"

module OpenTelemetry
  class Instrument
    class UpDownCounter < Instrument
      def initialize(name, unit = "", description = "")
        super(name, "up_down_counter", unit, description)
      end

      def add(value : Number, attributes : Hash(String, ValueTypes)? = nil) : Nil
        observe(value, attributes)
      end
    end
  end
end
