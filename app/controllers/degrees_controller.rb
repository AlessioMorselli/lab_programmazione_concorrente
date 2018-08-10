class DegreesController < ApplicationController
    before_action :set_degree, only: [:show, :edit, :update, :destroy]

    # GET degree_path(degree)
    def show
      # Visualizza i corsi di studio (degree_courses) di un corso di laurea
      @degrees_courses = @degree.degrees_courses
    end

    private
    def set_degree
      @degree = Degree.find(params[:id])
    end

    def degree_params
      params.require(:degree).permit(:name)
    end
end
