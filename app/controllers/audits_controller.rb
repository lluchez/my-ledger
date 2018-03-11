class AuditsController < ApplicationController
  before_action :authenticate_user!

  # GET /audits
  # GET /audits.json
  def index
    @audits = Audit.where(:user => current_user).where("auditable_type NOT IN (?)", ['User']).order('id DESC')
  end

end
