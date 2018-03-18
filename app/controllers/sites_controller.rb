class SitesController < ApplicationController
  before_action :user_required

  # GET /sites
  def index
    @sites = Site.latest.page params[:page]
    @site  = Site.new
  end

  # POST /sites
  def create
    @site = @current_user.sites.build params.fetch(:site, {}).permit(:url)
    @site.save
    respond_to do |format|
      format.html { redirect_to sites_url }
      format.json
    end
  end

  # GET /sites/history
  def history
    @sites = @current_user.sites.latest.page params[:page]
  end

end
