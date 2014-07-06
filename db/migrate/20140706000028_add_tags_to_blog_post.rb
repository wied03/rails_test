class AddTagsToBlogPost < ActiveRecord::Migration
  def change
    add_column :blog_posts, :tags, :string
  end
end
