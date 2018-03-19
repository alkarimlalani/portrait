require 'rails_helper'

describe SitesController, 'html' do
  before { login_as :admin }

  it 'handles / with GET' do
    gt :sites
    expect(response).to be_successful
  end

  it 'handles /sites with valid parameters and POST' do
    expect {
      pst :sites, site: { url: 'https://google.com' }
      expect(assigns(:site).user).to eq(@user)
      expect(response).to redirect_to(sites_path)
    }.to change(Site, :count).by(1)
  end

  it 'handles /sites with invalid url and POST' do
    expect {
      pst :sites, site: { url: 'invalid' }
      expect(response).to redirect_to(sites_path)
    }.not_to change(Site, :count)
  end
end

describe SitesController, 'js api' do
  before { login_as :admin }

  it 'handles / with valid parameters and POST' do
    expect {
      pst :sites, site: { url: 'https://google.com' }, format: :json
      expect(assigns(:site).user).to eq(@user)
      expect(response).to be_successful
      expect(response.body).to be_include('"status":"succeeded"')
    }.to change(Site, :count).by(1)
  end

  it 'handles / with empty url and POST' do
    expect {
      pst :sites, format: :json
      expect(response).to be_successful
      expect(response.body).to be_include(':{"errors":{"url":["is invalid"]}}')
    }.not_to change(Site, :count)
  end

  it 'handles /sites with invalid url and POST' do
    expect {
      pst :sites, site: { url: 'invalid' }, format: :json
      expect(response).to be_successful
      expect(response.body).to be_include(':{"errors":{"url":["is invalid"]}}')
    }.not_to change(Site, :count)
  end

  it 'handles /sites/history with GET' do
    expect {
      gt :sites_history, format: :json
      expect(response).to be_successful
      expect(response.body).to be_include('"status":"succeeded"')
    }.not_to change(Site, :count)
  end

  it 'handles /sites/search with GET' do
    expect {
      gt :sites_search, site: {url: 'https://google.com'}, format: :json
      expect(response).to be_successful
      expect(response.body).to be_include('"status":"succeeded"')
    }.not_to change(Site, :count)
  end

  it 'handles /sites/search with bad url and GET' do
    expect {
      gt :sites_search, site: {url: 'https://facebook.com'}, format: :json
      expect(response).to be_successful
      expect(response.body).not_to be_include('"status":"succeeded"')
    }.not_to change(Site, :count)
  end
end

describe SitesController, 'caching' do
  before do
    login_as :admin
    RestClient ||= double
    response = double
    @etag = "\"5aa6e194-4229\""
    allow(response).to receive(:headers).and_return({etag: @etag})
    allow(RestClient).to receive(:get).and_return(response)
  end

  it 'creates a portrait when not cached' do
    pst :sites, site: { url: 'https://basecamp.com' }, format: :json
    expect(response).to be_successful
    site = Site.find get_site_id
    expect(site.etag).to eq(@etag)
  end

  it 'uses existing image when already cached' do
    pst :sites, site: { url: 'https://basecamp.com' }, format: :json
    a = Site.find get_site_id
    pst :sites, site: { url: 'https://basecamp.com' }, format: :json
    b = Site.find get_site_id
    expect(a.etag).to eq(b.etag)
    expect(a.image.blob.key).to eq(b.image.blob.key)
    expect(a.image.blob.checksum).to eq(b.image.blob.checksum)
    expect(a.image.blob.filename).to eq(b.image.blob.filename)
  end
end
