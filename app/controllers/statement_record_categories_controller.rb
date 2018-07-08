class StatementRecordCategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, :only => [:show, :edit, :update, :destroy]

  # GET /statement_record_categories
  # GET /statement_record_categories.json
  def index
    @categories = StatementRecordCategory.from_user(current_user).order(:name)
  end

  # GET /statement_record_categories/1
  # GET /statement_record_categories/1.json
  def show; end

  # GET /statement_record_categories/new
  def new
    @category = StatementRecordCategory.new(:active => true)
  end

  # GET /statement_record_categories/1/edit
  def edit; end

  # POST /statement_record_categories
  # POST /statement_record_categories.json
  def create
    category_params = statement_record_category_params
    @category = StatementRecordCategory.new((category_params || {}).merge(:user_id => current_user.id))
    if category_params.present? && @category.save
      respond_to do |format|
        format.html { redirect_to @category, :flash => {:notice => i18n_message(:created, {:name => @category.name})} }
        format.json { render :show, :status => :created, :location => @category }
      end
    else
      on_error(@category, :new)
    end
  end

  # PATCH/PUT /statement_record_categories/1
  # PATCH/PUT /statement_record_categories/1.json
  def update
    category_params = statement_record_category_params
    if (category_params.blank? && !category_params.nil?) || (category_params.present? && @category.update_attributes(category_params))
      respond_to do |format|
        format.html { redirect_to @category, :flash => {:notice => i18n_message(:updated, {:name => @category.name})} }
        format.json { render :show, :status => :ok, :location => @category }
      end
    else
      on_error(@category, :edit)
    end
  end

  # DELETE /statement_record_categories/1
  # DELETE /statement_record_categories/1.json
  def destroy
    if @category.destroy
      respond_to do |format|
        format.html { redirect_to statement_record_categories_url, :flash => {:notice => i18n_message(:destroyed, {:name => @category.name})} }
        format.json { head :no_content }
      end
    else
      on_error(@category, statement_record_category_url(@category), true)
    end
  end

  private

    def set_category
      @category = StatementRecordCategory.from_user(current_user).where(:id => params[:id]).last or not_found
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def statement_record_category_params
      params.require(:statement_record_category).permit(:name, :color, :icon, :active)
    rescue ActionController::ParameterMissing
      nil
    end
end
