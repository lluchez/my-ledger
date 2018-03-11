class Audit < Audited::Audit

  class << self
    def format_column(column)
      column.humanize.capitalize
    end

    def format_value(value)
      return "[NULL]" if value.nil?
      return '""' if value.class == String && value.blank?
      value.to_s
    end
  end

  alias_attribute :timestamp, :created_at

  def date_formatted
    self.created_at.in_time_zone.strftime("%F %H:%M:%S")
  end

  def action_formatted
    self.action.capitalize
  end

  def model_formatted
    model_name = self.auditable_type
    return "Transaction" if model_name == "StatementRecord"
    return "Parser" if model_name.starts_with?("StatementParsers")
    model_name = model_name.gsub(/([a-z])([A-Z])/) {|m| "#{m[0]} #{m[1]}" }
    model_name
  end

  def auditable_url
    router = Rails.application.routes.url_helpers
    model = self.auditable_type.underscore
    model = "statement_parser" if model.starts_with?("statement_parsers/")
    path_attr = "#{model}_path"
    router.respond_to?(path_attr) ? router.send(path_attr, self.auditable_id) : nil
  end

end
