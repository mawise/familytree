module PersonHelper
  GENDER_MAP={nil=>"",""=>"","non_binary"=>"Non-Binary","male"=>"Male","female"=>"Female"}

  def date_in_words(date)
    if (date.nil?)
      ""
    else
      date.strftime("%B %-d, %Y")
    end
  end
  def display_gender(gender_enum)
    if GENDER_MAP.include? gender_enum
      return GENDER_MAP[gender_enum]
    else
      return ""
    end
  end
end
