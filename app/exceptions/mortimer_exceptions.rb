class MortimerExceptions
  class SessionExpiringError < StandardError; end
  class SessionExpiringSoonError < StandardError; end
  class SessionExpiredError < StandardError; end
  class SessionExpired < StandardError; end
  class InvalidSession < StandardError; end
  class InvalidTenant < StandardError; end
  class InvalidUser < StandardError; end
  class PermissionDenied < StandardError; end
  class FeatureNotAvailable < StandardError; end
  class ExternalServiceError < StandardError; end
end
