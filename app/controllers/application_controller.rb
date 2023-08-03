class ApplicationController < ActionController::API
  rescue_from ActionController::BadRequest do |ex|
    render json: { error: ex.message }, status: 400
  end

  rescue_from ActiveRecord::RecordInvalid do |ex|
    render json: { error: ex.message }, status: 422
  end

  rescue_from ActiveRecord::RecordNotFound do |ex|
    render json: { error: ex.message }, status: 404
  end

  def route_not_found
    render json: { error: 'not found' }, status: 404
  end
end
