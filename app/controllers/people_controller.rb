class PeopleController < ApplicationController
  def index
    if params[:name]
      @people = Person.where('name LIKE ?', "%#{params[:name]}%")
    else
      #@people = Person.all
      @people = []
    end
  end

  def show
    @person = Person.find(params[:id])
  end

  def edit
    @person = Person.find(params[:id])
  end

  def new
    @person = Person.new
  end

  def create
    @person = Person.new(person_params)
    @person.save
    redirect_to @person
  end

  def update
    @person = Person.find(params[:id])
    if @person.update(person_params)
      redirect_to @person
    else
      render 'edit'
    end
  end

  def destroy
  end

  private

  def person_params
    params.require(:person).permit(:name, :birth, :notes)
  end

end
