module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    # around_command :set_user

    def connect
      self.current_user = find_verified_user
      Current.user = current_user if current_user.class == User
      logger.add_tags "ActionCable", "User #{current_user.id}"
    rescue
      Rails.logger.error { "ActionCable: Connection refused -----------------------------" }
    end

    protected

      def set_user
        Current.user = find_verified_user
        Rails.logger.error { "ActionCable: Current.user #{Current.user.name} -----------------------------" }
        yield
      end

      def find_verified_user
        if current_user =  env["warden"].user
          current_user
        else
          reject_unauthorized_connection
        end
      rescue => error
        Rails.logger.error { "ActionCable: Current.user #{current_user&.name} is unauthorized (#{error}) -----------------------------" }
        false
      end
  end
end
