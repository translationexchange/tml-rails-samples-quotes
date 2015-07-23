class AuthorsController < ApplicationController

  def index
    @authors = Author.order('name asc')

    unless params[:search].blank?
      @authors = @authors.where('name like ?', "%#{params[:search]}%")
    end

    unless params[:filter].blank?
      @authors = @authors.where('name like ?', "#{params[:filter]}%")
    end

    @authors = @authors.page(page).per(per_page)
  end

end
