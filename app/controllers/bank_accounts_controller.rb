class BankAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bank_account, :only => [:show, :edit, :update, :destroy]
  before_action :list_statement_parsers, :only => [:new, :edit, :create, :update] # needs to include :create/:update as failure will not result in a redirection
  before_action :list_bank_statements, :only => [:show]

  # GET /bank_accounts
  # GET /bank_accounts.json
  def index
    @bank_accounts = BankAccount.from_user(current_user).includes(:parser).order(:name)
  end

  # GET /bank_accounts/1
  # GET /bank_accounts/1.json
  def show
  end

  # GET /bank_accounts/new
  def new
    @bank_account = BankAccount.new
  end

  # GET /bank_accounts/1/edit
  def edit
  end

  # POST /bank_accounts
  # POST /bank_accounts.json
  def create
    account_params = bank_account_params
    @bank_account = BankAccount.new((account_params || {}).merge(:user_id => current_user.id))
    if account_params.present? && @bank_account.save
      respond_to do |format|
        format.html { redirect_to @bank_account, :flash => {:notice => i18n_message(:created, {:name => @bank_account.name})} }
        format.json { render :show, :status => :created, :location => @bank_account }
      end
    else
      on_error(@bank_account, :new)
    end
  end

  # PATCH/PUT /bank_accounts/1
  # PATCH/PUT /bank_accounts/1.json
  def update
    account_params = bank_account_params
    if (account_params.blank? && !account_params.nil?) || (account_params.present? && @bank_account.update_attributes(account_params))
      respond_to do |format|
        format.html { redirect_to @bank_account, :flash => {:notice => i18n_message(:updated, {:name => @bank_account.name})} }
        format.json { render :show, :status => :ok, :location => @bank_account }
      end
    else
      on_error(@bank_account, :edit)
    end
  end

  # DELETE /bank_accounts/1
  # DELETE /bank_accounts/1.json
  def destroy
    if @bank_account.destroy
      respond_to do |format|
        format.html { redirect_to bank_accounts_url, :flash => {:notice => i18n_message(:destroyed, {:name => @bank_account.name})} }
        format.json { head :no_content }
      end
    else
      on_error(@bank_account, bank_account_url(@bank_account), true)
    end
  end

  private
    def set_bank_account
      @bank_account = BankAccount.from_user(current_user).where(:id => params[:id]).last or not_found
    end

    def list_statement_parsers
      @statement_parsers = StatementParsers::ParserBase.order(:name).map { |p| [p.name, p.id] }
    end

    def list_bank_statements
      @bank_statements = BankStatement.from_user(current_user).where(:bank_account_id => @bank_account.id).order('year DESC, month DESC')
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bank_account_params
      params.require(:bank_account).permit(:name, :statement_parser_id)
    rescue ActionController::ParameterMissing
      nil
    end
end
