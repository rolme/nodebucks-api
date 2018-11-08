class TestRewarder
  @@browser = nil

  def initialize(crypto, wallet, date)
    @crypto = crypto
    @wallet = wallet
    @date = date
    @total_amount_scraped = 0
    @invalid_wallet = false
  end

  def check
    begin
      @url = "#{@crypto.explorer_url}#{@wallet}"
      scrape_rewards(init_browser)
      if  @invalid_wallet
        { status: :error, message: 'Unable to find wallet.' }
      elsif @total_amount_scraped === 0
        { status: :error, message: 'Unable to find rewards after given date.' }
      else
        { total_amount_scraped: @total_amount_scraped, url: @url }
      end
    rescue Watir::Exception
      browser.quit if Rails.env == 'development'
      { status: :error, message: 'Unable to scrape URL.' }
    rescue
      browser.quit if Rails.env == 'development'
      { status: :error, message: 'Unable to find wallet.' }
    end
  end

  private

  def init_browser
    if Rails.env != 'development'
      if @@browser.blank?
        options = Selenium::WebDriver::Chrome::Options.new
        options.binary = ENV['GOOGLE_CHROME_SHIM']
        options.add_argument('--headless')
        @@browser = Selenium::WebDriver.for :chrome, options: options
      end
      @@browser.navigate.to @url
      sleep 5
    else
      driver = Watir::Browser.new
      driver.goto @url
      sleep 5
      @@browser = driver.wd
    end
    @@browser
  end

  def scrape_rewards(browser)
    case @crypto.slug
      when 'polis'
        @total_amount_scraped = RewardScraper.new(browser, @date).scrape_polis(true)
        @invalid_wallet =       RewardScraper.wallet_invalid?(browser)
      when 'gobyte'
        @total_amount_scraped = RewardScraper.new(browser, @date).scrape_gobyte(true)
      when 'phore'
        @total_amount_scraped = RewardScraper.new(browser, @date).scrape_phore(true)
      when 'dash'
        @total_amount_scraped = RewardScraper.new(browser, @date).scrape_dash(true)
      when 'zcoin'
        @total_amount_scraped = RewardScraper.new(browser, @date).scrape_zcoin(true)
      when 'pivx'
        @total_amount_scraped = RewardScraper.new(browser, @date).scrape_pivx(true)
      when 'blocknet'
        @total_amount_scraped = RewardScraper.new(browser, @date).scrape_blocknet(true)
      when 'stipend'
        @total_amount_scraped = RewardScraper.new(browser, @date).scrape_stipend(true)
      else
        not_supported
    end
    if Rails.env == 'development'
      browser.quit
    end
  end

  private

  def not_supported
    { status: :error, message: 'Reward scraping for this crypto is not supported.' }
  end
end
