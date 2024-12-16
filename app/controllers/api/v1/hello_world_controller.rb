module Api
  module V1
    class HelloWorldController < Api::ApiController
      def hello
        render json: { hello: "world" }
      end
    end
  end
end
