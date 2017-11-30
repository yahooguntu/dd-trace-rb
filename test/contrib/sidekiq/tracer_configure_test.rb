require 'contrib/sidekiq/tracer_test_base'

class TracerTest < TracerTestBase
  class EmptyWorker
    include Sidekiq::Worker

    def perform(); end
  end

  def test_configuration_defaults
    # it should configure the tracer with reasonable defaults
    Sidekiq::Testing.server_middleware do |chain|
      chain.add(Datadog::Contrib::Sidekiq::Tracer, tracer: @tracer)
    end
    EmptyWorker.perform_async()

    assert_equal(
      @writer.services,
      'sidekiq' => {
        'app' => 'sidekiq', 'app_type' => 'worker'
      }
    )
  end

  def test_configuration_custom
    # it should configure the tracer with users' settings
    Sidekiq::Testing.server_middleware do |chain|
      chain.add(
        Datadog::Contrib::Sidekiq::Tracer,
        tracer: @tracer,
        service_name: 'my-sidekiq'
      )
    end
    EmptyWorker.perform_async()

    assert_equal(false, @tracer.enabled)
    assert_equal(
      @tracer.services,
      'my-sidekiq' => {
        'app' => 'sidekiq', 'app_type' => 'worker'
      }
    )
  end
end
