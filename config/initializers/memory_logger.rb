#
# this is courtesy of Benjamin Silva, @bsilva96
#
memory_logger = ActiveSupport::Logger.new(Rails.root.join("log/memory.log"))
memory_logger.formatter = Logger::Formatter.new
Rails.application.config.memory_logger = memory_logger

module MemoryTracking
  extend ActiveSupport::Concern

  included do
    around_action :measure_memory_usage
  end

  private

  def measure_memory_usage
    mem_before = GetProcessMem.new.mb
    yield
    mem_after = GetProcessMem.new.mb

    memory_logger = Rails.application.config.memory_logger
    memory_logger.info("#{controller_name}##{action_name}: #{mem_after - mem_before} MB \n#{request.url}\n")
  end
end

# ActiveSupport.on_load(:action_controller) { include MemoryTracking }
