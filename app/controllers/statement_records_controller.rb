class StatementRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bank_statement # to be done before `set_statement_record`
  before_action :set_statement_record, :only => [:show, :edit, :update, :destroy]
  before_action :list_bank_accounts_with_statements, :only => [:new, :edit, :create, :update] # needs to include :create/:update as failure will not result in a redirection

  # GET /statement_records
  # GET /statement_records.json
  def index
    query = StatementRecord.from_user(current_user)
    order = 'date DESC'
    if @bank_statement.present?
      query = query.where(:statement_id => @bank_statement.id)
    else
      includes = {:statement => :bank_account}
      query = query.includes(includes).joins(includes)
      order = "#{order}, bank_accounts.name"
    end
    @statement_records = query.order(order)
  end

  # GET /statement_records/1
  # GET /statement_records/1.json
  def show; end

  # GET /statement_records/new
  def new
    @statement_record = StatementRecord.new
  end

  # GET /statement_records/1/edit
  def edit; end

  # POST /statement_records
  # POST /statement_records.json
  def create
    record_params = statement_record_params || {}
    @statement_record = StatementRecord.new(record_params.merge(:user_id => current_user.id))
    verify_statement_id_from_attributes(record_params)
    if record_params.present? && @statement_record.errors.blank? && @statement_record.save
      respond_to do |format|
        format.html {redirect_to_saved_record(:created) }
        format.json { render :show, :status => :created, :location => @statement_record }
      end
    else
      on_error(@statement_record, :new)
    end
  end

  # PATCH/PUT /statement_records/1
  # PATCH/PUT /statement_records/1.json
  def update
    record_params = statement_record_params || {}
    verify_statement_id_from_attributes(record_params)
    if record_params.blank? || (@statement_record.errors.blank? && @statement_record.update_attributes(record_params))
      respond_to do |format|
        format.html { redirect_to_saved_record(:updated) }
        format.json { render(:show, :status => :ok, :location => @statement_record) }
      end
    else
      on_error(@statement_record, :edit)
    end
  end

  # DELETE /statement_records/1
  # DELETE /statement_records/1.json
  def destroy
    url = get_index_page
    if @statement_record.destroy
      respond_to do |format|
        format.html { redirect_to(url, :flash => {:notice => i18n_message(:destroyed, {:name => @statement_record.name})}) }
        format.json { head(:no_content) }
      end
    else
      on_error(@statement_record, url, true)
    end
  end

  # GET /bank_statements/1/statement_records/upload_csv
  def upload_csv
    list_bank_accounts_with_statements unless @bank_statement.present?
  end

  # POST /bank_statements/1/statement_records/import_csv
  def import_csv
    if validate_csv_import_params
      imported_records = import_records_from_csv
      if imported_records
        redirect_to(@bank_statement, :flash => {:notice => i18n_message(:csv_import_successful, {records_count: imported_records.count})})
        return
      end
    end
    redirect_to(request.referer, :flash => {:error => @errors})
  end

  private

    def set_statement_record
      @statement_record = StatementRecord.from_user(current_user).where(:id => params[:id]).last or not_found
    end

    def set_bank_statement
      if params[:bank_statement_id].present?
        @bank_statement = BankStatement.from_user(current_user).find_by_id(params[:bank_statement_id]) or not_found
      end
    end

    def list_bank_accounts_with_statements
      @bank_accounts = BankAccount.from_user(current_user).includes(:statements).joins(:statements).order('bank_accounts.name, bank_statements.year DESC, bank_statements.month DESC')
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def statement_record_params
      params.require(:statement_record).permit(:date, :description, :amount, :statement_id)
    rescue ActionController::ParameterMissing
      nil
    end

    def verify_statement_id_from_attributes(attrs)
      if attrs[:statement_id].present? || !@statement_record.persisted?
        if BankStatement.from_user(current_user).find_by_id(attrs[:statement_id]).blank?
          @statement_record.errors.add(:statement_id, :invalid)
        end
      end
    end

    def redirect_to_saved_record(type)
      if @bank_statement.present?
        url = bank_statement_statement_record_path(@statement_record.statement_id, @statement_record)
      else
        url = @statement_record
      end
      redirect_to(url, :flash => {:notice => i18n_message(type, {:name => @statement_record.name})})
    end

    def get_index_page
      if @bank_statement.present?
        bank_statement_statement_records_url(@bank_statement)
      else
        statement_records_url
      end
    end

    def validate_csv_import_params
      @errors = []
      @errors << i18n_message(:invalid_statement) unless @bank_statement.present?
      @errors << i18n_message(:blank_csv_file) if params[:file].blank?

      @errors.blank?
    end

    def import_records_from_csv
      StatementRecord.import(params[:file], @bank_statement, params[:clear_existing_records].present?)
    rescue CsvFileParsingException => e
      @errors = e.exceptions.map(&:message)
      false
    rescue StandardError => e
      @errors = [e.message] # message is already sanitized and Rollbar raised
      false
    end
end
