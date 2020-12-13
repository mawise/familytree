module PersonHelper
  GENDER_MAP={nil=>"",""=>"","non_binary"=>"Non-Binary","male"=>"Male","female"=>"Female"}
  DATE_FMT = "%B %-d, %Y"
  DATE_OPTIONS = [
    ["Between", "between"],
    ["On", "on"],
    ["Before", "before"],
    ["After", "after"]]

  def date_in_words(date)
    if (date.nil?)
      ""
    else
      date.strftime(DATE_FMT)
    end
  end

  def spans_one_year?(date_start, date_end)
    if (date_start.nil? or date_end.nil?)
      false
    elsif (date_start.year != date_end.year)
      false
    elsif ((date_start.day == 1) & (date_start.month == 1) & (date_end.day == 31) & (date_end.month == 12))
      true
    else
      false
    end
  end

  def date_range_in_words(date_start, date_end)
    if (date_start.nil? and date_end.nil?)
      ""
    elsif (date_start == date_end)
      date_start.strftime(DATE_FMT)
    elsif (date_start.nil?)
      "Before #{date_end.strftime(DATE_FMT)}"
    elsif (date_end.nil?)
      "After #{date_start.strftime(DATE_FMT)}"
    elsif spans_one_year?(date_start, date_end)
      "#{date_start.year}"
    else
      ## TODO: identify full years or months and display just the year
      ## eg: 1838-01-01 - 1838-12-31, display as "1838"
      "Between #{date_start.strftime(DATE_FMT)} and #{date_end.strftime(DATE_FMT)}"
    end
  end ## TODO: Gedcom format of date range

  def display_gender(gender_enum)
    if GENDER_MAP.include? gender_enum
      return GENDER_MAP[gender_enum]
    else
      return ""
    end
  end

  def gedcom
    out="0 HEAD\n1 SUBM @SUBM@\n1 GEDC\n2 VERS 5.5.1\n2 FORM LINEAGE-LINKED\n1 CHAR UTF-8\n1 LANG English\n"
    out+="0 @SUBM@ SUBM\n1 NAME\n1 ADDR\n"
    families = gedcom_families
    Person.find_each do |person|
      out += gedcom_person(person, families)
    end
    families.values.each do |family|
      out += gedcom_family(family)
    end
    out += "0 TRLR\n"
    return out
  end

  private
 
  # iterates through all people
  # returns a map.  Set<Person> (as parents of a family) is the key
  # value: {"id" => int, 
  #         "husbands" => List<Person>, 
  #         "wives" => List<Person>, 
  #         "children" => List<Person> }
  def gedcom_families
    parents_to_families = {}
    next_fam_id = 1
    Person.find_each do |person|
      next if person.parents.size == 0
      parents_set = Set.new
      person.parents.each {|parent| parents_set.add(parent) }
      unless parents_to_families.include? parents_set
        family = {}
        family["id"] = next_fam_id.to_s.rjust(4, "0")
        next_fam_id += 1
        family["husbands"] = []
        family["wives"] = []
        family["children"] = []
        parents_set.each do |parent|
          if parent.male?
            family["husbands"] << parent
          else
            family["wives"] << parent
          end
        end
        parents_to_families[parents_set] = family
      end  # end unless include? parents_set.  Now value is initialized
      parents_to_families[parents_set]["children"] << person
    end  # end person.find_each
    return parents_to_families
  end

  def gedcom_family(family)
    out = ""
    out += "0 @F#{family["id"]}@ FAM\n"
    family["husbands"].each do |h|
      out += "1 HUSB @I#{get_person_id(h)}@\n"
    end
    family["wives"].each do |w|
      out += "1 WIFE @I#{get_person_id(w)}@\n"
    end
    family["children"].each do |c|
      out += "1 CHIL @I#{get_person_id(c)}@\n"
    end
    return out
  end

  def get_person_id(person)
    id = person.id
    id_string = id.to_s.rjust(4, "0")
    return id_string
  end

  def gedcom_date(date)
    return date.strftime("%d %^b %Y")
  end

  def gedcom_name(person)
    name = person.name
    givn, _, surn = name.rpartition(" ")
    combined = "#{givn} /#{surn}/"
    return "1 NAME #{combined}\n2 GIVN #{givn}\n2 SURN #{surn}\n"
  end

  def gedcom_person(person, families_map)
    # get parents set, lookup family, save FAMC IDs
    famc = []
    parents_set = Set.new
    person.parents.each {|parent| parents_set.add(parent) }
    if parents_set.size > 0
      family = families_map[parents_set]
      famc << family["id"]
    end
    # get partners, for each, lookup family, save FAMS IDs
    fams = []
    partners_sets = Set.new
    person.children.each do |child|
      child_parents = Set.new
      child.parents.each do |child_parent|
        child_parents.add(child_parent)
      end
      partners_sets.add(child_parents)
    end
    partners_sets.each do |partners|
      family = families_map[partners]
      fams << family["id"]
    end
    return gedcom_person_content(person, famc, fams)
  end

  def gedcom_person_content(person, families_as_child, families_as_spouse)
    out = ""
    out += "0 @I#{get_person_id(person)}@ INDI\n"
    out += gedcom_name(person)
    out += "1 SEX F\n" if person.female?
    out += "1 SEX M\n" if person.male?
    families_as_child.each do |famc_id|
      out += "1 FAMC @F#{famc_id}@\n"
    end
    families_as_spouse.each do |fams_id|
      out += "1 FAMS @F#{fams_id}@\n"
    end
    out += "1 BIRT\n"
    out += "2 DATE #{gedcom_date(person.birth)}\n" unless person.birth.nil?
    out += "2 PLAC #{person.birth_place}\n" unless person.birth_place.nil?
    out += "1 DEAT\n"
    out += "2 DATE #{gedcom_date(person.death)}\n" unless person.death.nil?
    out += "2 PLAC #{person.death_place}\n" unless person.death_place.nil?
    unless person.notes.nil?
      first_line = true
      person.notes.each_line do |line|
        if (first_line)
          out += "1 NOTE #{line.strip}\n"
          first_line = false
        else
          out += "2 CONT #{line.strip}\n"
        end
      end
    end
    return out
  end

end
