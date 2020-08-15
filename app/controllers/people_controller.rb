class PeopleController < ApplicationController
  def index
    if params[:name]
      @people = Person.where('name LIKE ?', "%#{params[:name]}%")
    else
      @people = []
    end
  end

  def show
    @person = Person.find(params[:id])
  end

  def modify_parents
    @person = Person.find(params[:id])
    if params[:name]
      @people = Person.where('name LIKE ?', "%#{params[:name]}%")
    else
      @people = []
    end
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

  def create_relationship
    @child = Person.find(relationship_params[:child_id])
    @parent = Person.find(relationship_params[:parent_id])
    @return_person = Person.find(relationship_params[:return_id])
    @child.parents << @parent
    redirect_to @return_person
  end

  def remove_child
    @child = Person.find(relationship_params[:child_id])
    @parent = Person.find(relationship_params[:parent_id])
    @parent.children.delete(@child)
    redirect_to @parent
  end

  def remove_parent
    @child = Person.find(relationship_params[:child_id])
    @parent = Person.find(relationship_params[:parent_id])
    @child.parents.delete(@parent)
    redirect_to @child
  end

  private

  def person_params
    params.require(:person).permit(:name, :birth, :notes)
  end

  def relationship_params
    params.permit(:child_id, :parent_id, :return_id)
  end

end
