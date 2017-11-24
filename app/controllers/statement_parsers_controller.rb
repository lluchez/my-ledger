class StatementParsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_statement, only: [:show, :edit, :update, :destroy]

  # def default_url_options
  #   { :controller => "statement_parsers" }
  # end

  # GET /statement_parsers
  # GET /statement_parsers.json
  def index
    @parsers = StatementParsers::ParserBase.order(:name)
  end

  # GET /statement_parsers/1
  # GET /statement_parsers/1.json
  def show
  end

  # GET /statement_parsers/new
  def new
    @parser = StatementParsers::ParserBase.new
  end

  # GET /statement_parsers/1/edit
  def edit
  end

  # POST /statement_parsers
  # POST /statement_parsers.json
  def create
    @parser = StatementParsers::ParserBase.new(statement_params)
    respond_to do |format|
      if @parser.save
        format.html { redirect_to statement_parsers_url, notice: "Parser #{@parser.name} was successfully created." }
        format.json { render :show, status: :created, location: @parser }
      else
        format.html { render :new, :flash => {:error => @parser.errors.full_messages} }
        format.json { render json: @parser.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /statement_parsers/1
  # PATCH/PUT /statement_parsers/1.json
  def update
    respond_to do |format|
      if @parser.update(statement_params)
        format.html { redirect_to statement_parsers_url, notice: "Parser #{@parser.name} was successfully updated." }
        format.json { render :show, status: :ok, location: @parser }
      else
        format.html { render :edit, :flash => {:error => @parser.errors.full_messages} }
        format.json { render json: @parser.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /statement_parsers/1
  # DELETE /statement_parsers/1.json
  def destroy
    respond_to do |format|
      if @parser.present?
        if @parser.destroy
          format.html { redirect_to statement_parsers_url, notice: "Parser #{@parser.name} was successfully deleted." }
          format.json { head :no_content }
        else
          format.html { redirect_to statement_parsers_url, :flash => {:error => @parser.errors.full_messages} }
          format.json { render json: @parser.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to statement_parsers_url, :flash => {:error => 'Unable to delete this bank account.'} }
        format.json { head :no_content, status: 404 }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_statement
      @parser = StatementParsers::ParserBase.where(:id => params[:id]).last or not_found
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def statement_params
      params.require(:statement_parsers_parser_base).permit(:name, :description, :type, :plain_text_regex, :plain_text_date_format)
    end
end