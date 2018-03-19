class AddEtagToSites < ActiveRecord::Migration[5.2]
  def change
    add_column :sites, :etag, :string
  end
end
