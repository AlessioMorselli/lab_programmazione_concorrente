class DegreesController < ApplicationController
    before_action :set_degree, only: [:show]

    # GET degree_path(degree)
    def show
        # Visualizza i corsi di studio (degree_courses) di un corso di laurea
    end

    private
    def set_degree
      @degree = Degree.find(params[:id])
    end

    def group_params
      params.require(:degree).permit(:name)
    end
end
