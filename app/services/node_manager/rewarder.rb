module NodeManager
  class Rewarder
    attr_accessor :node
    attr_reader :operator
    @@browser = nil

    def initialize(node)
      @node = node
      @operator = NodeManager::Operator.new(node)
    end

    def scrape
      if Rails.env != 'development'
        if @@browser.blank?
          options = Selenium::WebDriver::Chrome::Options.new
          options.binary = ENV['GOOGLE_CHROME_SHIM']
          options.add_argument('--headless')
          @@browser = Selenium::WebDriver.for :chrome, options: options
        end
        @@browser.navigate.to node.wallet_url
        sleep 5
      else
        driver = Watir::Browser.new
        driver.goto node.wallet_url
        sleep 5
        @@browser = driver.wd
      end

      begin
        case node.symbol
        when 'BLOCK'; RewardScraper.new(@@browser).scrape_blocknet(false, node, operator)
        when 'DASH';  RewardScraper.new(@@browser).scrape_dash(false, node, operator)
        when 'GBX';   RewardScraper.new(@@browser).scrape_gobyte(false, node, operator)
        when 'GIN';   RewardScraper.new(@@browser).scrape_gincoin(false, node, operator)
        when 'PHR';   RewardScraper.new(@@browser).scrape_phore(false, node, operator)
        when 'PIVX';  RewardScraper.new(@@browser).scrape_pivx(false, node, operator)
        when 'POLIS'; RewardScraper.new(@@browser).scrape_polis(false, node, operator)
        when 'SPD';   RewardScraper.new(@@browser).scrape_stipend(false, node, operator)
        when 'XZC';   RewardScraper.new(@@browser).scrape_zcoin(false, node, operator)
        end
      rescue => error
        Rails.logger.error "SCRAPE ERROR: #{error}"
        Rails.logger.error "SCRAPE ERROR PATH: #{node.wallet_url}"
      end
      if Rails.env == 'development'
        @@browser.quit
      end
    end
  end
end
