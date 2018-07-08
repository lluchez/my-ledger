class BankStatementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bank_statement, :only => [:show, :edit, :update, :destroy]
  before_action :list_bank_accounts, :only => [:new, :edit, :create, :update] # needs to include :create/:update as failure will not result in a redirection
  before_action :list_months_names, :only => [:new, :edit, :create, :update] # needs to include :create/:update as failure will not result in a redirection
  before_action :list_statement_records, :only => [:show]

  NB_YEARS = 10

  # GET /bank_statements
  # GET /bank_statements.json
  def index
    @bank_statements = BankStatement.from_user(current_user).includes(:bank_account).joins(:bank_account).order('year DESC, month DESC, bank_accounts.name')
  end

  # GET /bank_statements/1
  # GET /bank_statements/1.json
  def show; end

  # GET /bank_statements/new
  def new
    @bank_statement = BankStatement.new(:bank_account_id => params[:bank_account_id])
  end

  # GET /bank_statements/1/edit
  def edit; end

  # POST /bank_statements
  # POST /bank_statements.json
  def create
    statement_params = bank_statement_params || {}
    @bank_statement = BankStatement.new(statement_params.merge(:user_id => current_user.id))
    records_attributes = compute_records_attributes
    if statement_params.present? && @bank_statement.errors.blank? && create_bank_statement_and_records(records_attributes)
      respond_to do |format|
        format.html { redirect_to @bank_statement, :flash => {:notice => i18n_message(:created, {:name => @bank_statement.name})} }
        format.json { render :show, :status => :created, :location => @bank_statement }
      end
    else
      on_error(@bank_statement, :new)
    end
  end

  # PATCH/PUT /bank_statements/1
  # PATCH/PUT /bank_statements/1.json
  def update
    statement_params = bank_statement_params
    if (statement_params.blank? && !statement_params.nil?) || (statement_params.present? && update_bank_statement(statement_params))
      respond_to do |format|
        format.html { redirect_to @bank_statement, :flash => {:notice => i18n_message(:updated, {:name => @bank_statement.name})} }
        format.json { render :show, :status => :ok, :location => @bank_statement }
      end
    else
      on_error(@bank_statement, :edit)
    end
  end

  # DELETE /bank_statements/1
  # DELETE /bank_statements/1.json
  def destroy
    if @bank_statement.destroy
      respond_to do |format|
        format.html { redirect_to bank_statements_url, :flash => {:notice => i18n_message(:destroyed, {:name => @bank_statement.name})} }
        format.json { head :no_content }
      end
    else
      on_error(@bank_statement, bank_statement_url(@bank_statement), true)
    end
  end

  private

    def set_bank_statement
      @bank_statement = BankStatement.from_user(current_user).where(:id => params[:id]).last or not_found
    end

    def list_bank_accounts
      @bank_accounts = BankAccount.from_user(current_user).order(:name).map { |p| [p.name, p.id] }
    end

    def list_statement_records
      @statement_records = StatementRecord.from_user(current_user).includes(:category).where(:statement_id => @bank_statement.id).order('date DESC')
    end

    def list_months_names
      @months = Date::MONTHNAMES[1..-1].each_with_index.map { |month,i| [month, i+1] } # first item is `nil`
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bank_statement_params
      params.require(:bank_statement).permit(:year, :month, :bank_account_id, :records_text, :csv_parsing)
    rescue ActionController::ParameterMissing
      nil
    end

    def get_records_attributes
      params = bank_statement_params
      records_text = params.try(:[], :records_text)
      csv_parsing  = params.try(:[], :csv_parsing)
      return if records_text.blank?
      if checked?(csv_parsing)
        begin
          {:attributes => BankStatementsCsvParser.new(current_user).parse(records_text)}
        rescue CsvFileParsingException => e
          {:errors => e.exceptions.map(&:message)}
        end
      else
        @bank_statement.get_records_attributes_from_raw_text(records_text)
      end
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
      @bank_statement.update_attributes(statement_params)
    rescue ActiveRecord::RecordNotUnique => e
      # e.message => "Mysql2::Error: Duplicate entry '...' for key 'index_bank_statements_on_bank_account_id_and_month_and_year': INSERT INTO `bank_statements` (...)"
      @bank_statement.errors.add(:month, :date_taken)
      false
    end

    def compute_records_attributes
      records_attributes = []
      if @bank_statement.valid?
        records_attributes = get_records_attributes || {:attributes => []}
        if records_attributes[:errors].present?
          @bank_statement.errors.add(:records_text, records_attributes[:errors])
        end
        records_attributes = records_attributes[:attributes]
      end
      records_attributes
    end

end
