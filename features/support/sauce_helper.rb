# You should edit this file with the browsers you wish to use
# For options, check out http://saucelabs.com/docs/platforms
require 'sauce'
require "sauce/capybara"
require 'sauce/cucumber'

Capybara.default_driver = :sauce

Sauce.config do |config|
  config[:browsers] = [
      ["Windows 8", "Internet Explorer", "10"]
  ]
  config[:start_tunnel] = true
end
