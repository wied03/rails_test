class BlogsController < ApplicationController
  def index
    @blogs = BlogPost.all
  end
end
