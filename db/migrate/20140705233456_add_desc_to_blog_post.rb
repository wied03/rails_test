class AddDescToBlogPost < ActiveRecord::Migration
  def change
    add_column :blog_posts, :desc, :string
  end
end
