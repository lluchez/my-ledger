class StatementRecordCategoryRulesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category_rule, only: [:show, :edit, :update, :destroy]
  before_action :list_categories, :only => [:new, :edit, :create, :update] # needs to include :create/:update as failure will not result in a redirection

  # GET /statement_record_category_rules
  # GET /statement_record_category_rules.json
  def index
    @category_rules = StatementRecordCategoryRules::CategoryRuleBase.includes(:category).from_user(current_user).order(:name)
  end

  # GET /statement_record_category_rules/1
  # GET /statement_record_category_rules/1.json
  def show; end

  # GET /statement_record_category_rules/new
  def new
    @category_rule = StatementRecordCategoryRules::CategoryRuleBase.new(:run_upon_update => true)
    @category_rule.run_upon_update = true
  end

  # GET /statement_record_category_rules/1/edit
  def edit
    @category_rule.run_upon_update = true
  end

  # POST /statement_record_category_rules
  # POST /statement_record_category_rules.json
  def create
    rule_params = statement_params
    @category_rule = StatementRecordCategoryRules::CategoryRuleBase.new((rule_params || {}).merge(:user_id => current_user.id))
    update_run_upon_update_attributes(@category_rule)
    if rule_params.present? && @category_rule.save
      respond_to do |format|
        format.html { redirect_to statement_record_category_rules_url, :flash => {:notice => i18n_message_for_updates(:created)} }
        format.json { render :show, :status => :created, location: statement_record_category_rule_url(@category_rule) }
      end
    else
      on_error(@category_rule, :new)
    end
  end

  # PATCH/PUT /statement_record_category_rules/1
  # PATCH/PUT /statement_record_category_rules/1.json
  def update
    rule_params = statement_params
    update_run_upon_update_attributes(@category_rule)
    if (rule_params.blank? && !rule_params.nil?) || (rule_params.present? && @category_rule.update_attributes(rule_params))
      respond_to do |format|
        format.html { redirect_to statement_record_category_rules_url, :flash => {:notice => i18n_message_for_updates(:updated)} }
        format.json { render :show, :status => :ok, :location => statement_record_category_rule_url(@category_rule) }
      end
    else
      on_error(@category_rule, :edit)
    end
  end

  # DELETE /statement_record_category_rules/1
  # DELETE /statement_record_category_rules/1.json
  def destroy
    if @category_rule.destroy
      respond_to do |format|
        format.html { redirect_to statement_record_category_rules_url, :flash => {:notice => i18n_message(:destroyed, {:name => @category_rule.name})} }
        format.json { head :no_content }
      end
    else
      on_error(@category_rule, statement_record_category_rule_url(@category_rule), true)
    end
  end

  private

  def set_category_rule
    # Note: adding `includes(:category)` will cause an Eager Load for HTML responses
    @category_rule = StatementRecordCategoryRules::CategoryRuleBase.from_user(current_user).find(params[:id])
  end

  def list_categories
    @categories = StatementRecordCategory.from_user(current_user).active.order(:name).map { |p| [p.name, p.id] }
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def statement_params
    params.require(:statement_record_category_rules_category_rule_base).permit(:name, :type, :category_id, :pattern, :case_insensitive, :active)
  rescue ActionController::ParameterMissing
    nil
  end

  def update_run_upon_update_attributes(rule)
    rule.run_upon_update = ActiveModel::Type::Boolean.new.cast(params[:run_upon_update])
  end

  def i18n_message_for_updates(type)
    type = "#{type}_with_record_update".to_sym if @category_rule.run_upon_update
    i18n_message(type, {:name => @category_rule.name, :records_updated => @category_rule.records_updated})
  end
end
