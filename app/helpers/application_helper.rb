module ApplicationHelper

  def date_format(date)
    date.to_formatted_s(:short)
  end

end
