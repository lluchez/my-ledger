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
  def show
  end

  # GET /statement_record_category_rules/new
  def new
    @category_rule = StatementRecordCategoryRules::CategoryRuleBase.new
  end

  # GET /statement_record_category_rules/1/edit
  def edit
  end

  # POST /statement_record_category_rules
  # POST /statement_record_category_rules.json
  def create
    rule_params = statement_params
    @category_rule = StatementRecordCategoryRules::CategoryRuleBase.new((rule_params || {}).merge(:user_id => current_user.id))
    if rule_params.present? && @category_rule.save
      respond_to do |format|
        format.html { redirect_to statement_record_category_rules_url, :flash => {:notice => i18n_message(:created, {:name => @category_rule.name}) } }
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
    if (rule_params.blank? && !rule_params.nil?) || (rule_params.present? && @category_rule.update_attributes(rule_params))
      respond_to do |format|
        format.html { redirect_to statement_record_category_rules_url, :flash => {:notice => i18n_message(:updated, {:name => @category_rule.name})} }
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
      @category_rule = StatementRecordCategoryRules::CategoryRuleBase.includes(:category).from_user(current_user).find(params[:id])
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
end
