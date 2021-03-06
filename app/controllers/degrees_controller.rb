class DegreesController < ApplicationController
    before_action :set_degree, only: [:show]
    before_action :logged_in_user

    # GET degree_path(degree)
    def show
      # Visualizza i gruppi relativi ai corsi di studio (degree_courses) di un corso di laurea
      @degrees_courses = @degree.groups

      render json: @degrees_courses
    end

    private
    def set_degree
      begin
        @degree = Degree.find(params[:id]) or not_found
      rescue ActionController::RoutingError
        render file: "#{Rails.root}/public/404", layout: false, status: :not_found
      end
    end

    def degree_params
      params.require(:degree).permit(:name)
    end
end
