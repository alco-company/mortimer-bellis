# Fix for amazing_print compatibility with Rails 8
# The gem tries to access ActiveSupport::LogSubscriber.colorize_logging which was removed

if defined?(AmazingPrint) && defined?(ActiveSupport::LogSubscriber)
  # Provide a fallback for the removed method
  unless ActiveSupport::LogSubscriber.respond_to?(:colorize_logging)
    class ActiveSupport::LogSubscriber
      def self.colorize_logging
        true
      end
    end
  end
end
