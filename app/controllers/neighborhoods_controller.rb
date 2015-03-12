class NeighborhoodsController < ApplicationController

  def search
    if params[:query].present?
      terms = params[:query].split(',').map{|n| n.strip}

      neighborhoods = Neighborhood.where(city: terms[0], state: terms[1]).pluck(:name)

      render json: neighborhoods, status: :ok
    else
      render json: [errors: 'missing required parameter "query"'], status: :unprocessable_entity
    end
  end

end
