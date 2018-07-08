module ViewsHelper

  def yes_no(value)
    I18n.t("general.#{value ? 'yes' : 'no'}_key") # there is an issue when using only `yes`/`no`/`true`/`false` for key names
  end

end
