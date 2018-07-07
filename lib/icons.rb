class Icons

  AUDIT = "glyphicon glyphicon-th-list"

  STATEMENT_PARSER = "glyphicon glyphicon-flash"
  BANK_ACCOUNT = "glyphicon glyphicon-book"
  BANK_STATEMENT = "glyphicon glyphicon-list-alt"
  STATEMENT_RECORD = "glyphicon glyphicon-shopping-cart"
  STATEMENT_RECORD_CATEGORY = "glyphicon glyphicon-glass"
  STATEMENT_RECORD_CATEGORY_RULE = "glyphicon glyphicon-ok"

  ADD    = "glyphicon glyphicon-plus"
  EDIT   = "glyphicon glyphicon-pencil"
  DELETE = "glyphicon glyphicon-trash"
  INFO   = "glyphicon glyphicon-info-sign"
  IMPORT = "glyphicon glyphicon-import"
  UPLOAD = "glyphicon glyphicon-upload"

  MANAGE = "glyphicon glyphicon-cog"
  LOGOUT = "glyphicon glyphicon-log-out"

  def self.add_or_edit(editing)
    editing ? EDIT : ADD
  end

end
