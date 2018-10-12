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
        when 'polis'; scrape_polis(@@browser)
        when 'dash'; scrape_dash(@@browser)
        when 'xzc'; scrape_zcoin(@@browser)
        when 'pivx'; scrape_pivx(@@browser)
        when 'spd'; scrape_stipend(@@browser)
        when 'gbx'; scrape_gobyte(@@browser)
        when 'block'; scrape_blocknet(@@browser)
        when 'phr'; scrape_phore(@@browser)
        end
      rescue => error
        Rails.logger.error "SCRAPE ERROR: #{error}"
        Rails.logger.error "SCRAPE ERROR PATH: #{node.wallet_url}"
      end
      if Rails.env == 'development'
        @@browser.quit
      end
    end

    def scrape_polis(browser)
      balance = browser.find_element(class_name: 'summary-table').find_elements(tag_name: 'td')[2].text.to_f
      node.update_attribute(:balance, balance)

      if Rails.env != 'development'
        rows = browser.find_elements(tag_name: 'table')[2].find_element(tag_name: 'tbody').find_elements(tag_name: 'tr')
      else
        rows = browser.find_element(id: 'DataTables_Table_0').find_element(tag_name: 'tbody').find_elements(tag_name: 'tr')
      end

      rows.reverse!.each do |row|
        data = row.find_elements(tag_name: 'td')
        next if data.blank?

        timestamp = data[0].text
        txhash    = data[1].find_element(tag_name: 'a').text
        amount    = data[2].text&.split(/\s/)[1]&.to_f

        if has_new_rewards?(timestamp) && !stake_amount?(amount)
          operator.reward(timestamp, amount, txhash)
        end
      end
    end

    def scrape_dash(browser)
      balance = browser.find_element(tag_name: 'pre').text.split(/\s/)[1].to_f
      node.update_attribute(:balance, balance)

      rows = browser.find_element(tag_name: 'tbody').find_elements(:class, 'direct')
      rows.reverse!.each do |row|
        data = row.find_elements(tag_name: 'td')
        next if data.blank?

        txhash    = data[0].find_element(tag_name: 'a').attribute('href').split("/")[-1]
        timestamp = data[2].text
        amount    = data[3].text&.to_f

        if has_new_rewards?(timestamp)
          operator.reward(timestamp, amount, txhash) unless stake_amount?(amount)
        end
      end
    end

    def scrape_zcoin(browser)
      balance = browser.find_element(class_name: 'summary-table').find_elements(tag_name: 'td')[2].text.to_f
      node.update_attribute(:balance, balance)

      if Rails.env != 'development'
        rows = browser.find_elements(tag_name: 'table')[2].find_element(tag_name: 'tbody').find_elements(tag_name: 'tr')
      else
        rows = browser.find_element(id: 'DataTables_Table_0').find_element(tag_name: 'tbody').find_elements(tag_name: 'tr')
      end
      rows.reverse!.each do |row|
        data = row.find_elements(tag_name: 'td')
        next if data.blank?

        timestamp = data[0].text
        txhash    = data[1].find_element(tag_name: 'a').text
        amount    = data[2].text&.split(/\s/)[1]&.to_f

        if has_new_rewards?(timestamp)
          operator.reward(timestamp, amount, txhash) unless stake_amount?(amount)
        end
      end
    end

    def scrape_pivx(browser)
      balance = browser.find_elements(tag_name: 'tbody')[1].find_elements(tag_name: 'tr')[1].find_elements(tag_name: 'td')[1].text.split(" ")[0].to_f
      node.update_attribute(:balance, balance)

      rows = browser.find_elements(tag_name: 'tbody')[2].find_elements(tag_name: 'tr')
      rows.reverse!.each do |row|
        data = row.find_elements(tag_name: 'td')
        next if data.blank?

        timestamp = data[2].text
        txhash    = data[0].text
        amount    = data[3].text.gsub(/[A-Z ]/, '').to_f

        if has_new_rewards?(timestamp) && amount > 0.0
          operator.reward(timestamp, amount, txhash) unless stake_amount?(amount)
        end
      end
    end

    def scrape_phore(browser)
      balance = browser.find_elements(tag_name: 'tbody')[1].find_elements(tag_name: 'tr')[1].find_elements(tag_name: 'td')[1].text.split(" ")[0].to_f
      node.update_attribute(:balance, balance)

      rows = browser.find_elements(tag_name: 'tbody')[2].find_elements(tag_name: 'tr')
      rows.reverse.each do |row|
        data = row.find_elements(tag_name: 'td')
        next if data.blank?

        timestamp = data[2].text
        txhash    = data[0].text.gsub('.', '')
        amount    = data[3].text.gsub(/[+A-Z, ]/, '').to_f

        if has_new_rewards?(timestamp) && amount > 0.0
          operator.reward(timestamp, amount, txhash) unless stake_amount?(amount)
        end

      end
    end

    def scrape_blocknet(browser)
      balance = browser.find_elements(tag_name: 'tbody')[1].find_elements(tag_name: 'tr')[1].find_elements(tag_name: 'td')[1].text.split(" ")[0].to_f
      node.update_attribute(:balance, balance)

      rows = browser.find_elements(tag_name: 'tbody')[2].find_elements(tag_name: 'tr')
      rows.reverse!.each do |row|
        data = row.find_elements(tag_name: 'td')
        next if data.blank?

        timestamp = data[2].text
        txhash    = data[0].text
        amount    = data[3].text.gsub(/[A-Z ]/, '').to_f

        if has_new_rewards?(timestamp) && amount > 0.0
          operator.reward(timestamp, amount, txhash) unless stake_amount?(amount)
        end
      end
    end

    def scrape_stipend(browser)
      balance = browser.find_element(class_name: 'summary-table').find_elements(tag_name: 'td')[2].text.to_f
      node.update_attribute(:balance, balance)

      if Rails.env != 'development'
        rows = browser.find_elements(tag_name: 'table')[2].find_element(tag_name: 'tbody').find_elements(tag_name: 'tr')
      else
        rows = browser.find_element(id: 'DataTables_Table_0').find_element(tag_name: 'tbody').find_elements(tag_name: 'tr')
      end

      rows.reverse!.each do |row|
        data = row.find_elements(tag_name: 'td')
        next if data.blank?

        timestamp = data[0].text
        txhash    = data[1].find_element(tag_name: 'a').text
        amount    = data[2].text&.split(/\s/)[1]&.to_f

        if has_new_rewards?(timestamp)
          operator.reward(timestamp, amount, txhash) unless stake_amount?(amount)
        end
      end
    end

    def scrape_gobyte(browser)
      balance = browser.find_element(class_name: 'summary-table').find_elements(tag_name: 'td')[2].text.to_f
      node.update_attribute(:balance, balance)

      if Rails.env != 'development'
        rows = browser.find_elements(tag_name: 'table')[2].find_element(tag_name: 'tbody').find_elements(tag_name: 'tr')
      else
        rows = browser.find_element(id: 'DataTables_Table_0').find_element(tag_name: 'tbody').find_elements(tag_name: 'tr')
      end
      rows.reverse!.each do |row|
        data = row.find_elements(tag_name: 'td')
        next if data.blank?

        timestamp = data[0].text
        txhash    = data[1].find_element(tag_name: 'a').text
        amount    = data[2].text&.split(/\s/)[1]&.to_f

        if has_new_rewards?(timestamp)
          operator.reward(timestamp, amount, txhash) unless stake_amount?(amount)
        end
      end
    end

  private

    def has_new_rewards?(timestamp)
      return false if node.online_at.blank?

      last_reward_timestamp   = node.rewards.last&.timestamp
      last_reward_timestamp ||= node.online_at

      last_reward_timestamp < DateTime.parse(timestamp)
    end

    def stake_amount?(amount)
      amount == node.stake
    end
  end
end
