module PersonHelper
  def date_in_words(date)
    if (date.nil?)
      ""
    else
      date.strftime("%b %-d %Y")
    end
  end

end
