class SitesController < ApplicationController
  before_action :user_required

  # GET /sites
  def index
    @sites = Site.latest.page params[:page]
    @site  = Site.new
  end

  # POST /sites
  def create
    @site = @current_user.sites.build site_url
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

  # GET /sites/search
  def search
    @sites = @current_user.sites.where(url: site_url[:url]).latest
  end

  protected

  def site_url
    params.fetch(:site, {}).permit(:url)
  end
end
