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
    parser_params = statement_params
    @parser = StatementParsers::ParserBase.new(parser_params || {})
    if parser_params.present? && @parser.save
      respond_to do |format|
        format.html { redirect_to statement_parsers_url, :flash => {:notice => i18n_message(:created, {:name => @parser.name}) } }
        format.json { render :show, :status => :created, location: statement_parser_url(@parser) }
      end
    else
      on_error(@parser, :new)
    end
  end

  # PATCH/PUT /statement_parsers/1
  # PATCH/PUT /statement_parsers/1.json
  def update
    parser_params = statement_params
    if (parser_params.blank? && !parser_params.nil?) || (parser_params.present? && @parser.update_attributes(parser_params))
      respond_to do |format|
        format.html { redirect_to statement_parsers_url, :flash => {:notice => i18n_message(:updated, {:name => @parser.name})} }
        format.json { render :show, :status => :ok, :location => statement_parser_url(@parser) }
      end
    else
      on_error(@parser, :edit)
    end
  end

  # DELETE /statement_parsers/1
  # DELETE /statement_parsers/1.json
  def destroy
    if @parser.destroy
      respond_to do |format|
        format.html { redirect_to statement_parsers_url, :flash => {:notice => i18n_message(:destroyed, {:name => @parser.name})} }
        format.json { head :no_content }
      end
    else
      on_error(@parser, statement_parser_url(@parser), true)
    end
  end

  private
    def set_statement
      @parser = StatementParsers::ParserBase.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def statement_params
      params.require(:statement_parsers_parser_base).permit(:name, :description, :type, :plain_text_regex, :plain_text_date_format)
    rescue ActionController::ParameterMissing
      nil
    end
end
