require 'rest-client'

class Site < ApplicationRecord

  enum status: %i[submitted started succeeded failed]

  belongs_to :user, counter_cache: true

  has_one_attached :image

  scope :latest, ->{ order(created_at: :desc) }

  after_create :process!
  def process!
    started!
    if file_exists?
      attach_file get_file
    else
      handle generate_png
    end
  end

  after_create :store_etag, if: :succeeded?
  def store_etag
    update etag: get_etag
  end

  def get_etag
    @etag ||= RestClient.get(url).headers[:etag]
  end

  def file_exists?
    get_etag.nil? ? false : Site.exists?(etag: @etag)
  end

  def get_file
    Site.find_by(etag: get_etag).image.blob
  end

  # Set the png located at path to the image
  def handle(path)
    File.exist?(path) ? attach_from_path(path) : failed!
  end

  def attach_file(file)
    image.attach file
    succeeded!
  end

  def attach_from_path(path)
    image.attach io: File.open(path), filename: "#{id}.png", content_type: 'image/png'
    succeeded!
  ensure
    FileUtils.rm path
  end

  def generate_png
    node      = `which node`.chomp
    file_name = "#{id}-full.png"
    command   = "#{node} #{Rails.root}/app/javascript/puppeteer/generate_screenshot.js --url='#{url}' --fullPage=true --omitBackground=true --savePath='#{Rails.root}/tmp/' --fileName='#{file_name}'"

    system command

    return "#{Rails.root}/tmp/#{file_name}"
  end

  validates :user_id, presence: true
  validates :url, format: /\A((http|https):\/\/)*[a-z0-9_-]{1,}\.*[a-z0-9_-]{1,}\.[a-z]{2,5}(\/)?\S*\z/i

end
