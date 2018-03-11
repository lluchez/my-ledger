
# From article "Best way to disable auditing in test environment?"
# https://github.com/collectiveidea/audited/issues/410
def update_auditing_enabled_on_all_models(enabled)
  # puts "Audited: #{enabled ? 'Enabled' : 'Disabled'}"
  Audited.audit_class.audited_class_names.map(&:constantize).each do |klass|
    klass.auditing_enabled = enabled
  end
end

def disable_audited_on_all_models
  update_auditing_enabled_on_all_models(false)
end

def enable_audited_on_all_models
  update_auditing_enabled_on_all_models(true)
end
