module Taza
  class Browser

    # Create a browser instance depending on configuration.  Configuration should be read in via Taza::Settings.config.
    #
    # Example:
    #     browser = Taza::Browser.create(Taza::Settings.config)
    #
    def self.create(params={})
      self.send("create_#{params[:driver]}".to_sym,params)
    end


    private

    def self.create_watir(params)
      require 'watir'
      Watir::Browser.new params[:browser].to_sym
    end
    #
    #def self.create_selenium(params)
    #  require 'selenium'
    #  Selenium::SeleniumDriver.new(params[:server_ip],params[:server_port],'*' + params[:browser].to_s,params[:timeout])
    #end

    def self.create_selenium_webdriver(params)
      require 'selenium-webdriver'
      #Small hack. :)
      Selenium::WebDriver::Driver.class_eval do
        def goto(params)
          navigate.to params
        end
      end
      Selenium::WebDriver.for params[:browser].to_sym
    end


    def self.create_remote(params)
      require 'selenium-webdriver'
      require 'watir-webdriver'

      caps = Selenium::WebDriver::Remote::Capabilities.new
      caps[:browser_name] = params[:browser].humanize.downcase #"internet explorer" #.humanize.downcase #params[:browser].to_sym
      caps[:platform] = params[:platform]
      caps[:version] = params[:browser_version]
      caps[:native_events] = true

      Watir::Browser.new(
          :remote,
          :url => params[:hub],
          :desired_capabilities => caps)
    end

    #TODO: create_external_grid (Sauce, Browserstack, etc. )

  end

  # We don't know how to create the browser you asked for
  class BrowserUnsupportedError < StandardError; end
end

