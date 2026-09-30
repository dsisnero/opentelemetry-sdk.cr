require "spec"
require "opentelemetry-api/interfaces"
require "../src/meter"

describe OpenTelemetry::Meter do
  it "preserves provider and explicit meter configuration" do
    provider_exporter = OpenTelemetry::Exporter.new(:null)
    explicit_exporter = OpenTelemetry::Exporter.new(:null)
    provider = OpenTelemetry::MeterProvider.new(
      "provider-service",
      "1.0.0",
      "https://schema.example/provider",
      provider_exporter)

    inherited_meter = provider.meter
    inherited_meter.name.should eq("provider-service")
    inherited_meter.version.should eq("1.0.0")
    inherited_meter.schema_url.should eq("https://schema.example/provider")
    inherited_meter.exporter.should be(provider_exporter)
    inherited_meter.provider.should be(provider)

    meter = provider.meter(
      "worker",
      "2.0.0",
      "https://schema.example/worker",
      explicit_exporter,
      0.5)
    meter.name.should eq("worker")
    meter.version.should eq("2.0.0")
    meter.schema_url.should eq("https://schema.example/worker")
    meter.exporter.should be(explicit_exporter)
    meter.interval.should eq(0.5)
    meter.provider.should be(provider)

    provider_exporter.exporter.do_reap
    explicit_exporter.exporter.do_reap
  end

  it "creates the synchronous metric instruments required by metrics adapters" do
    meter = OpenTelemetry::Meter.new
    attributes = {} of String => OpenTelemetry::ValueTypes
    attributes["kind"] = "task"

    counter = meter.create_counter("events_total", description: "events")
    histogram = meter.create_histogram("duration_seconds", description: "duration")
    gauge = meter.create_up_down_counter("queue_depth", description: "depth")

    counter.should be_a(OpenTelemetry::Instrument::Counter)
    histogram.should be_a(OpenTelemetry::Instrument::Histogram)
    gauge.should be_a(OpenTelemetry::Instrument::UpDownCounter)

    counter.add(2, attributes)
    histogram.record(1.5, attributes)
    gauge.add(-1, attributes)

    counter.observations[0].value.should eq(2.0)
    histogram.observations[0].value.should eq(1.5)
    gauge.observations[0].value.should eq(-1.0)
    gauge.observations[0].attributes.should eq(attributes)
  end
end
