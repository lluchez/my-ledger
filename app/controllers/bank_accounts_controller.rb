class BankAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bank_account, only: [:show, :edit, :update, :destroy]
  before_action :list_statement_parsers, only: [:new, :edit]

  # GET /bank_accounts
  # GET /bank_accounts.json
  def index
    @bank_accounts = BankAccount.where(:user_id => current_user.id).includes(:statement_parser).order(:name)
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
    @bank_account = BankAccount.new(bank_account_params.merge(:user_id => current_user.id))
    respond_to do |format|
      if @bank_account.save
        format.html { redirect_to @bank_account, notice: "Bank account #{@bank_account.name} was successfully created." }
        format.json { render :show, status: :created, location: @bank_account }
      else
        format.html { render :new, :flash => {:error => @bank_account.errors.full_messages} }
        format.json { render json: @bank_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bank_accounts/1
  # PATCH/PUT /bank_accounts/1.json
  def update
    respond_to do |format|
      if @bank_account.update(bank_account_params)
        format.html { redirect_to @bank_account, notice: "Bank account #{@bank_account.name} was successfully updated." }
        format.json { render :show, status: :ok, location: @bank_account }
      else
        format.html { render :edit, :flash => {:error => @bank_account.errors.full_messages} }
        format.json { render json: @bank_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bank_accounts/1
  # DELETE /bank_accounts/1.json
  def destroy
    respond_to do |format|
      if @bank_account.present?
        if @bank_account.destroy
          format.html { redirect_to bank_accounts_url, notice: "Bank account #{@bank_account.name} was successfully deleted." }
          format.json { head :no_content }
        else
          format.html { render :edit, :flash => {:error => @bank_account.errors.full_messages} }
          format.json { render json: @bank_account.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to bank_accounts_url, :flash => {:error => 'Unable to delete this bank account.'} }
        format.json { head :no_content, status: 404 }
      end
    end
  end

  private
    def set_bank_account
      @bank_account = BankAccount.where(:id => params[:id], :user_id => current_user.id).last or not_found
    end

    def list_statement_parsers
      @statement_parsers = StatementParsers::ParserBase.order(:name).map { |p| [p.name, p.id] }
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bank_account_params
      params.require(:bank_account).permit(:name, :statement_parser_id)
    end
end
