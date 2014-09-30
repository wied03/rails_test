module BswTech
  class WatirNode < Capybara::Driver::Node

  end

  class WatirDriver < Capybara::Driver::Base
    DEFAULT_OPTIONS = {
        :browser => :firefox
    }
    SPECIAL_OPTIONS = [:browser]

    attr_reader :app, :options, :browser

    def initialize(app, options={})
      @app = app
      # TODO: Somehow check Capybara and create the proper browser object
      require 'watir-webdriver'
      @browser = Watir::Browser.new
      browser_obj = @browser
      at_exit do
        browser_obj.quit
      end
      @exit_status = nil
      @frame_handles = {}
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def needs_server?;
      true;
    end

    def quit
      @browser.quit if @browser
    rescue Errno::ECONNREFUSED
      # Browser must have already gone
    ensure
      @browser = nil
    end

    def visit(path)
      browser.goto path
    end

    def find_xpath(selector)
      browser.elements(:xpath => selector).map {|node| BswTech::WatirNode.new(self,node)}
    end

    def reset!
      # Use instance variable directly so we avoid starting the browser just to reset the session
      if @browser
        begin
          begin
            @browser.cookies.clear
          rescue Selenium::WebDriver::Error::UnhandledError
            # delete_all_cookies fails when we've previously gone
            # to about:blank, so we rescue this error and do nothing
            # instead.
          end
          @browser.goto("about:blank")
        rescue Selenium::WebDriver::Error::UnhandledAlertError
          # This error is thrown if an unhandled alert is on the page
          # Firefox appears to automatically dismiss this alert, chrome does not
          # We'll try to accept it
          begin
            @browser.alert.ok
          rescue Selenium::WebDriver::Error::NoAlertPresentError
            # The alert is now gone - nothing to do
          end
          # try cleaning up the browser again
          retry
        end
      end
    end
  end
end

# Using Capybara for its lifecycle stuff, but expose the native Watir API underneath
class Cucumber::Rails::World
  def browser
    page.driver.browser
  end
end

Capybara.register_driver :bsw_watir do |app|
  BswTech::WatirDriver.new(app)
end

Capybara.default_driver = :bsw_watir

# if ENV['FIREFOX']
#   require 'watir-webdriver'
#   Browser = Watir::Browser
#   browser = Browser.new :ff
# else
#   case RUBY_PLATFORM
#     when /darwin/
#       require 'safariwatir'
#       Browser = Watir::Safari
#     when /win32|mingw/
#       require 'watir'
#       Browser = Watir::IE
#     when /java/
#       require 'celerity'
#       Browser = Celerity::Browser
#     else
#       raise "This platform is not supported (#{RUBY_PLATFORM})"
#   end
#
#   # "before all"
#   browser = Browser.new
# end
#
# Before do
#   @browser = browser
# end
#
# at_exit do
#   browser.close
# end