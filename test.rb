require "selenium-webdriver"
require "rspec"
require "pry"

describe('Selenium 4') do
  before(:each) do
    @driver = Selenium::WebDriver.for :chrome
  end

  after(:each) do
    @driver.quit
  end

  # ok
  it('Navigates to Google') do
    @driver.navigate.to "http://google.com"
    expect(@driver.title).to eql "Google"
  end

  # ok
  it('Stubs Compass Logo') do
    @driver.intercept do |request, &continue|
      if request.url.match?(/\logo.svg$/)
        request.url = 'https://upload.wikimedia.org/wikipedia/commons/d/d5/Selenium_Logo.png'
      end
      continue.call(request)
    end
    @driver.navigate.to 'https://compass.uol'
  end

  # ok
  it('Stubs DuckDuckGo Logo') do
    @driver.intercept do |request, &continue|
      if request.url.match?(/\.svg$/)
        request.url = 'https://upload.wikimedia.org/wikipedia/commons/d/d5/Selenium_Logo.png'
      end
      continue.call(request)
    end
    @driver.navigate.to 'https://duckduckgo.com'
  end

  # ok
  it('Authenticates with basic auth (old way)') do
    @driver.navigate.to "https://admin:admin@the-internet.herokuapp.com/basic_auth"
    p_message_authenticated = @driver.find_element(css: ".example p")
    expect(p_message_authenticated.text).to eql 'Congratulations! You must have the proper credentials.'
  end

  # ok
  it('Authenticates with basic auth (new way)') do
    @driver.devtools.new
    @driver.register(username: 'admin', password: 'admin')
    @driver.get "https://the-internet.herokuapp.com/basic_auth"
    p_message_authenticated = @driver.find_element(css: ".example p")
    expect(p_message_authenticated.text).to eql 'Congratulations! You must have the proper credentials.'
  end

  # ok
  it('Finds by relative locator') do
    @driver.navigate.to "https://compass.uol"
    a_header_careers = @driver.find_element(css: ".Menu_menu__Orucn a[href*='/careers/']")
    a_lets_talk = @driver.find_element(relative: { tag_name: "a", right: a_header_careers })
    a_our_work = @driver.find_element(relative: { tag_name: "a", left: a_header_careers })
    img_logo = @driver.find_element(relative: { tag_name: "img", left: a_header_careers })
    expect(a_lets_talk.text).to eql "Let's talk"
    expect(a_our_work.text).to eql "Our work"
    expect(img_logo[:src]).to eql "https://compass.uol/triangle.svg"
  end
  
  it('Runs on Selenium Grid') do
    caps = Selenium::WebDriver::Remote::Capabilities.chrome("goog:chromeOptions" => {"args" => ["--headless"]})
    @driver = Selenium::WebDriver.for(:remote,
      :url => "http://localhost:4444/wd/hub",
      :capabilities => caps)
    @driver.navigate.to "http://google.com"
    expect(@driver.title).to eql "Google"
  end
end

# https://www.selenium.dev/selenium/docs/api/rb/Selenium/WebDriver/DriverExtensions/HasNetworkInterception.html
# https://www.selenium.dev/pt-br/documentation/webdriver/bidirectional/bidi_api/
