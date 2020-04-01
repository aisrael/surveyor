class ResponsesController < ApiController
    def index
        render json: Response.all
    end

    def create
        logger.debug "params: #{params.inspect}"
        render json: []
    end
end
