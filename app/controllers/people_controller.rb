class PeopleController < ApplicationController

  before_action :authenticate_user!

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

  def modify_children
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
    if (@return_person == @child)
      redirect_to modify_parents_path(@return_person)
    else
      redirect_to modify_children_path(@return_person)
    end
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

  def show_upgraph
    @person = Person.find(params[:id])
    graph_text = make_upgraph(@person)
    @graph = create_svg(graph_text).html_safe
    render :graph
  end

  def show_downgraph
    @person = Person.find(params[:id])
    graph_text = make_downgraph(@person).html_safe
    @graph = create_svg(graph_text).html_safe
    render :graph
  end

  private

  def person_params
    params.require(:person).permit(:name, :birth, :notes)
  end

  def relationship_params
    params.permit(:child_id, :parent_id, :return_id)
  end

  ## do not call directly, used for recursive calls
  def upgraph(person)
    out = ""
    out += "#{person.id}[label=\"#{person.name}\" URL=\"#{person_path(person)}\"];\n"
    person.parents.each do |parent|
      out += "#{parent.id} -> #{person.id};\n"
      out += upgraph(parent)
    end
    out
  end

  def make_upgraph(person)
    out = ""
    out += "digraph G {\n"
    out += "rankdir=LR;\n"
    out += upgraph(person)
    out += "}"
    out
  end

  ## Note, there is probably a bug when multiple children have the same set of
  ## three-or-more parents but the parents are in different orders
  def downgraph(person)
    out = "#{person.id}[label=\"#{person.name}\" URL=\"#{person_path(person)}\"];\n"
    parents_ids = Set.new
    person.children.each do |child|
      parents_id = "\"#{person.id}"
      parents_set = Set.new
      if (child.parents.size == 1)  ## Single parent, child points to them
        out += "#{person.id} -> #{child.id};\n"
      else  ## Multiple parents, create relationship node
        
        child.parents.each do |child_parent|
          unless child_parent == person
            parents_set.add(child_parent)
            parents_id += "-#{child_parent.id}"
          end
        end
        parents_id += "\""
 
        unless (parents_ids.include? parents_id)
          parents_ids.add(parents_id)
          rank = "{rank=same; #{person.id}, #{parents_id}"
          parents_set.each do |child_parent|
            rank += ", #{child_parent.id}"
          end
          rank += "}\n"
          out += "subgraph \"cluster_#{parents_id.gsub("\"","")}\"{color=none\n"
            out += rank
            out += "#{parents_id}[shape=\"point\"];\n"
            out += "#{person.id} -> #{parents_id}[dir=none];\n"
            parents_set.each do |child_parent|
              out += "#{parents_id} -> #{child_parent.id}[dir=none];\n"
              out += "#{child_parent.id}[label=\"#{child_parent.name}\" URL=\"#{person_path(person)}\"];\n"
            end
          out += "}\n"  ## end cluster subgraph
        end

        out += "#{parents_id} -> #{child.id};\n"
      end ## end if-else on child.parents.size == 1
      out += downgraph(child)
    end
    out
  end

  def make_downgraph(person)
    out = ""
    out += "digraph G {\n"
    out += "rankdir=LR;\n"
    out += downgraph(person)
    out += "}"
    out
  end

  def create_svg(graph_text)
    ## TODO check if `dot` command exists
    tmp_path = "tmp/storage/" ## TODO: create path if not exists
    filename = graph_text.hash.abs.to_s
    ## TODO if hash.svg already exists, return it as-is?
    File.open("#{tmp_path}#{filename}.dot", 'w') do |f|
      f.write(graph_text)
    end
    `cat #{tmp_path}#{filename}.dot | dot -T svg -o #{tmp_path}#{filename}.svg`
    svg_text = ""
    File.open("#{tmp_path}#{filename}.svg", 'r') do |f|
      svg_text = f.read
    end
    svg_text
  end

end
