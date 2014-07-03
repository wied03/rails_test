class AddBodyToPost < ActiveRecord::Migration
  def change
    add_column :blog_posts, :body, :string
  end
end
