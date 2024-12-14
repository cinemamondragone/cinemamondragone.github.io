class DateRangeFormatter < Bridgetown::Component
  def initialize(from:, to:)
    @from, @to = Date.parse(from), Date.parse(to)
  end

  def formatted_date_range
    return I18n.l(@from, format: :day_month) if @from == @to

    if @from.month == @to.month
      "#{I18n.t("from")} #{@from.day} " <<
        "#{I18n.t("to")} #{@to.day} " <<
        I18n.l(@from, format: :month)
    else
      "#{I18n.t("from")} #{I18n.l(@from, format: :day_month)} " <<
        "#{I18n.t("to")} #{I18n.l(@to, format: :day_month)} "
    end
  end
end
