class AddJunkToBlogPost < ActiveRecord::Migration
  def change
    add_column :blog_posts, :junk, :string
  end
end
