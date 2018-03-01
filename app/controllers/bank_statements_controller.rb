class BankStatementsController < ApplicationController
  NB_YEARS = 10

  before_action :authenticate_user!
  before_action :set_bank_statement, :only => [:show, :edit, :update, :destroy]
  before_action :list_bank_accounts #, :only => [:new, :edit] # needs to include :create/:update as failure will not result in a redirection
  before_action :list_months_names #, :only => [:new, :edit] # needs to include :create/:update as failure will not result in a redirection

  # GET /bank_statements
  # GET /bank_statements.json
  def index
    @bank_statements = BankStatement.where(:user_id => current_user.id).includes(:bank_account).joins(:bank_account).order('year DESC, month DESC, bank_accounts.name')
  end

  # GET /bank_statements/1
  # GET /bank_statements/1.json
  def show; end

  # GET /bank_statements/new
  def new
    @bank_statement = BankStatement.new
  end

  # GET /bank_statements/1/edit
  def edit; end

  # POST /bank_statements
  # POST /bank_statements.json
  def create
    statement_params = bank_statement_params || {}
    @bank_statement = BankStatement.new(statement_params.merge(:user_id => current_user.id))
    records_attributes = compute_records_attributes
    respond_to do |format|
      if statement_params.present? && create_bank_statement_and_records(records_attributes)
        format.html { redirect_to @bank_statement, :flash => {:notice => i18n_message(:created, {:name => @bank_statement.name})} }
        format.json { render :show, :status => :created, :location => @bank_statement }
      else
        format.html { render :new, :flash => {:error => @bank_statement.errors.full_messages} }
        format.json { render :json => @bank_statement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bank_statements/1
  # PATCH/PUT /bank_statements/1.json
  def update
    statement_params = bank_statement_params
    respond_to do |format|
      if (statement_params.blank? && !statement_params.nil?) || (statement_params.present? && update_bank_statement(statement_params))
        format.html { redirect_to @bank_statement, :flash => {:notice => i18n_message(:updated, {:name => @bank_statement.name})} }
        format.json { render :show, :status => :ok, :location => @bank_statement }
      else
        format.html { render :edit, :flash => {:error => @bank_statement.errors.full_messages} }
        format.json { render :json => @bank_statement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bank_statements/1
  # DELETE /bank_statements/1.json
  def destroy
    respond_to do |format|
      if @bank_statement.destroy
        format.html { redirect_to bank_statements_url, :flash => {:notice => i18n_message(:destroyed, {:name => @bank_statement.name})} }
        format.json { head :no_content }
      else
        format.html { redirect_to bank_statements_url, :flash => {:error => @bank_statement.errors.full_messages} }
        format.json { render :json => @bank_statement.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

    def set_bank_statement
      @bank_statement = BankStatement.where(:id => params[:id], :user_id => current_user.id).last or not_found
    end

    def list_bank_accounts
      @bank_accounts = BankAccount.where(:user_id => current_user.id).order(:name).map { |p| [p.name, p.id] }
    end

    def list_months_names
      @months = Date::MONTHNAMES[1..-1].each_with_index.map { |month,i| [month, i+1] } # first item is `nil`
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bank_statement_params
      params.require(:bank_statement).permit(:year, :month, :bank_account_id)
    rescue ActionController::ParameterMissing
      nil
    end

    def get_records_attributes
      @bank_statement.get_records_attributes_from_raw_text(get_records_text)
    end

    def get_records_text
      params.require(:bank_statement).permit(:records_text)[:records_text]
    end

    def create_bank_statement_and_records(records_attributes)
      ActiveRecord::Base.transaction do
        @bank_statement.save!
        records_attributes.each do |record|
          StatementRecord.create!(record.merge(:user_id => current_user.id, :statement_id => @bank_statement.id))
        end
      end
      true
    rescue ActiveRecord::RecordNotUnique => e
      # e.message => "Mysql2::Error: Duplicate entry '...' for key 'index_bank_statements_on_bank_account_id_and_month_and_year': INSERT INTO `bank_statements` (...)"
      @bank_statement.errors.add(:month, :date_taken)
      false
    rescue StandardError => e
      RollbarHelper.error("Unable to save records", :e => e, :fingerprint => :statements_controller_cant_save_records)
      @bank_statement.errors.add(:records, :generic_error) if @bank_statement.errors.blank?
      false
    end

    def update_bank_statement(statement_params)
      @bank_statement.update(statement_params)
    rescue ActiveRecord::RecordNotUnique => e
      # e.message => "Mysql2::Error: Duplicate entry '...' for key 'index_bank_statements_on_bank_account_id_and_month_and_year': INSERT INTO `bank_statements` (...)"
      @bank_statement.errors.add(:month, :date_taken)
      false
    end

    def compute_records_attributes
      records_attributes = []
      if @bank_statement.valid?
        records_attributes = get_records_attributes
        if records_attributes[:errors].present?
          @bank_statement.errors.add(:records_text, records_attributes[:errors])
        else
          records_attributes = records_attributes[:attributes]
        end
      end
      records_attributes
    end

end