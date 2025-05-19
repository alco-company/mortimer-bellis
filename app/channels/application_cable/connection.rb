module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      set_current_user || reject_unauthorized_connection
    end

    private
      def set_current_user
        if session = Session.find_by(id: cookies.signed[:session_id])
          self.current_user = session.user
          true
        else
          find_verified_user
        end
      end

      def find_verified_user
        token = request.params[:token] || request.headers["Authorization"]&.split(" ")&.last
        decoded_token = JWT.decode(token, JWT_SECRET_KEY, true, { algorithm: JWT_ALGORITHM })
        if decoded_token && (user = User.find_by(id: decoded_token.first["user_id"]))
          self.current_user = user
          true
        else
          false
        end
      end
  end
end
