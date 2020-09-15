include PersonHelper
class PeopleController < ApplicationController

  before_action :authenticate_user!

  def index
    if params[:name]
      @people = search_people(params[:name])
    else
      @people = []
    end
  end

  def show
    @person = Person.find(params[:id])
  end

  def show_gedcom
    content = gedcom ## Defined in PersonHelper
    render plain: content
  end

  def modify_parents
    @person = Person.find(params[:id])
    if params[:name]
      @people = search_people(params[:name])
    else
      @people = []
    end
  end

  def modify_children
    @person = Person.find(params[:id])
    if params[:name]
      @people = search_people(params[:name])
    else
      @people = []
    end
  end

  def modify_images
    @person = Person.find(params[:id])
  end

  def create_image
    @person = Person.find(params[:id])
    @person.images.attach params[:image]
    @person.save
    redirect_to images_path(@person)
  end

  def destroy_image
    @person = Person.find(params[:id])
    @person.images.find(params[:image_id]).purge_later
    redirect_to images_path(@person)
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
    params.require(:person).permit(:name, :gender, :birth, :birth_place, :death, :death_place, :notes)
  end

  def relationship_params
    params.permit(:child_id, :parent_id, :return_id)
  end

  def search_people(name)
    simple_name = ActiveSupport::Inflector.transliterate(name) # remove accents
    people = Person.where('search_name LIKE ?', "%#{simple_name}%")
    people
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
    out += "}\n"
    out
  end

  # relationship is a set of person objects
  def relationship_id(person, relationship)
    id = person.id.to_s
    relationship.each do |partner|
      id += "-#{partner.id}"
    end
    return "\"#{id}\""
  end

  def downgraph(person)
    person_label = "#{person.id}[label=\"#{person.name}\" URL=\"#{person_path(person)}\"];\n"
    if person.children.size == 0
      return person_label
    end
    out = ""
    ## get all partners and partner groups (relationships)
    partners = Set.new # set of people, excluding person
    relationships = [] # set of sets of people, excluding person
    person.children.sort do |a,b|
      if a.birth.nil? and b.birth.nil?
        0
      elsif a.birth.nil?
        -1
      elsif b.birth.nil?
        1
      else
        a.birth <=> b.birth
      end
    end.each do |child|
      relationship = Set.new # one relationship per child, adding is idempotent
      child.parents.each do |child_parent|
        partners.add(child_parent) unless (child_parent == person)
        relationship.add(child_parent) unless (child_parent == person)
      end
      relationships << relationship unless relationships.include? relationship
    end
    ## cluster with person, partners, and relationship nodes. 
    out += "subgraph \"cluster_#{person.id}\"{color=none\n"
    out += person_label
      ## person -> first relationship -> partners
      ## partners -> other relstionships -> person
      ## NOTE: reverse this order for rankdir=TB
    first_relationship = true
    relationships.each do |relationship|
      next if relationship.size < 1 # child has only 1 parent
      if first_relationship
        out += "#{person.id} -> #{relationship_id(person, relationship)}[dir=none];\n"
        relationship.each do |partner|
          out += "#{relationship_id(person, relationship)} -> #{partner.id}[dir=none];\n"
        end
        first_relationship = false
      else
        out += "#{relationship_id(person, relationship)} -> #{person.id}[dir=none];\n"
        relationship.each do |partner|
          out += "#{partner.id} -> #{relationship_id(person, relationship)}[dir=none];\n"
        end
      end
    end
    ## for each partner: define partner node
    partners.each do |partner|
      out += "#{partner.id}[label=\"#{partner.name}\" URL=\"#{person_path(partner)}\"];\n"
    end
    ## for each partner group: define relationship nodes
    relationships.each do |relationship|
      if (relationship.size > 0) ## child has more than 1 parent
        out += "#{relationship_id(person, relationship)}[shape=\"point\"];\n"
      end
    end
    ## same rank for person, relationships, and partners
    out += "{rank=same; #{person.id}" ## no trailing newline
    partners.each do |partner|
      out += ", #{partner.id}"
    end
    relationships.each do |relationship|
      out += ", #{relationship_id(person, relationship)}"
    end
    out += "}\n" ## end rank=same
    out += "}\n" ## end cluster
    ## for all children: relationship -> child, dg(child)
    person.children.each do |child|
      relationship = Set.new
      child.parents.each do |partner|
        relationship.add(partner) unless (partner == person)
      end
      out += "#{relationship_id(person, relationship)} -> #{child.id};\n"
      out += downgraph(child)
    end
    return out
  end

  def make_downgraph(person)
    out = ""
    out += "digraph G {\n"
    out += "rankdir=LR;\n"
    out += downgraph(person)
    out += "}\n"
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
