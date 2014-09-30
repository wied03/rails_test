require 'rails_helper'

RSpec.describe BlogPost, :type => :model do
  it 'should pass' do
    # arrange
    post = BlogPost.create(title: 'the post')

    # act
    result = BlogPost.all

    # assert
    expect(result).to eq [post]
  end
end
