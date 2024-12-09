module Api
  module V1
    class HelloWorldController < Api::ApiController
      before_action :doorkeeper_authorize!

      def hello
        render json: { hello: "world" }
      end
    end
  end
end
