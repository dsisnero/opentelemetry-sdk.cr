require "./provider"
require "./meter"

module OpenTelemetry
  # A MeterProvider encapsulates a set of meter configuration, and provides an interface for creating Meter instances.
  class MeterProvider < Provider
    def meter
      Meter.new
    end

    def meter(
      service_name = nil,
      service_version = nil,
      schema_url = nil,
      exporter = nil,
      interval = nil,
    )
      Meter.new(service_name || "", service_version || "", schema_url || "")
    end

    def meter(&)
      new_meter = meter
      yield new_meter

      new_meter
    end
  end
end
