class RewardScraper
  attr_accessor :browser

  def initialize(browser, date = nil)
    @browser = browser
    @total_amount_scraped = 0
    @date = date
  end

  def scrape_polis(test_mode = false, node = nil, operator = nil)
    update_node_balance(node, browser.find_element(class_name: 'summary-table').find_elements(tag_name: 'td')[2].text.to_f) unless test_mode

    polis_rows.reverse!.each do |row|
      data = row.find_elements(tag_name: 'td')
      next if data.blank?

      timestamp = data[0].text
      txhash    = data[1].find_element(tag_name: 'a').text
      amount    = data[2].text&.split(/\s/)[1]&.to_f

      if !test_mode && has_new_rewards?(node, timestamp) && !stake_amount?(node, amount)
        operator.reward(timestamp, amount, txhash)
      else
        @total_amount_scraped += amount if !!@date && Time.parse(timestamp) >= @date
      end
    end
    @total_amount_scraped if test_mode
  end

  def scrape_dash(test_mode = false, node = nil, operator = nil)
    update_node_balance(node, browser.find_element(tag_name: 'pre').text.split(/\s/)[1].to_f) unless test_mode

    dash_rows.reverse!.each do |row|
      data = row.find_elements(tag_name: 'td')
      next if data.blank?

      txhash    = data[0].find_element(tag_name: 'a').attribute('href').split("/")[-1]
      timestamp = data[2].text
      amount    = data[3].text&.to_f

      if !test_mode && has_new_rewards?(node, timestamp) && !stake_amount?(node, amount)
        operator.reward(timestamp, amount, txhash)
      else
        @total_amount_scraped += amount if !!@date && Time.parse(timestamp) >= @date
      end
    end
    @total_amount_scraped if test_mode
  end

  def scrape_zcoin(test_mode = false, node = nil, operator = nil)
    update_node_balance(node, browser.find_element(tag_name: 'tbody').find_elements(:class, 'ellipsis')[2].text.split(' ')[0].to_f) unless test_mode

    zcoin_rows.reverse!.each do |row|
      timestamp = row.find_elements(:class, 'ng-binding')[2].text
      txhash    = row.find_elements(:class, 'ellipsis')[0].find_elements(tag_name: 'a')[1].text
      amount    = row.find_elements(:class, 'txvalues-primary')[0].text.split(' ')[0].to_f

      if !test_mode && has_new_rewards?(node, timestamp) && !stake_amount?(node, amount)
        operator.reward(timestamp, amount, txhash)
      else
        @total_amount_scraped += amount if !!@date && Time.parse(timestamp) >= @date
      end
    end
    @total_amount_scraped if test_mode
  end

  def scrape_pivx(test_mode = false, node = nil, operator = nil)
    update_node_balance(node, browser.find_elements(tag_name: 'tbody')[1].find_elements(tag_name: 'tr')[1].find_elements(tag_name: 'td')[1].text.split(" ")[0].to_f) unless test_mode

    pivx_rows.reverse!.each do |row|
      data = row.find_elements(tag_name: 'td')
      next if data.blank?

      timestamp = data[2].text
      txhash    = data[0].text
      amount    = data[3].text.gsub(/[A-Z ]/, '').to_f

      if !test_mode && has_new_rewards?(node, timestamp) && amount > 0.0 && !stake_amount?(node, amount)
        operator.reward(timestamp, amount, txhash)
      else
        @total_amount_scraped += amount if !!@date && Time.parse(timestamp) >= @date
      end
    end
    @total_amount_scraped if test_mode
  end

  def scrape_phore(test_mode = false, node = nil, operator = nil)
    update_node_balance(node, browser.find_elements(tag_name: 'tbody')[1].find_elements(tag_name: 'tr')[1].find_elements(tag_name: 'td')[1].text.split(" ")[0].to_f) unless test_mode

    phore_rows.reverse.each do |row|
      data = row.find_elements(tag_name: 'td')
      next if data.blank?

      timestamp = data[2].text
      txhash    = data[0].text.gsub('.', '')
      amount    = data[3].text.gsub(/[+A-Z, ]/, '').to_f

      if !test_mode && has_new_rewards?(node, timestamp) && amount > 0.0 && !stake_amount?(node, amount)
        operator.reward(timestamp, amount, txhash)
      else
        @total_amount_scraped += amount if !!@date && Time.parse(timestamp) >= @date
      end
    end
    @total_amount_scraped if test_mode
  end

  def scrape_blocknet(test_mode = false, node = nil, operator = nil)
    update_node_balance(node, browser.find_elements(tag_name: 'tbody')[1].find_elements(tag_name: 'tr')[1].find_elements(tag_name: 'td')[1].text.split(" ")[0].to_f) unless test_mode

    blocknet_rows.reverse!.each do |row|
      data = row.find_elements(tag_name: 'td')
      next if data.blank?

      timestamp = data[2].text
      txhash    = data[0].text
      amount    = data[3].text.gsub(/[A-Z ]/, '').to_f

      if !test_mode && has_new_rewards?(node, timestamp) && amount > 0.0 && !stake_amount?(node, amount)
        operator.reward(timestamp, amount, txhash)
      else
        @total_amount_scraped += amount if !!@date && Time.parse(timestamp) >= @date
      end
    end
    @total_amount_scraped if test_mode
  end

  def scrape_stipend(test_mode = false, node = nil, operator = nil)
    update_node_balance(node, browser.find_element(class_name: 'summary-table').find_elements(tag_name: 'td')[2].text.to_f) unless test_mode

    stipend_rows.reverse!.each do |row|
      data = row.find_elements(tag_name: 'td')
      next if data.blank?

      timestamp = data[0].text
      txhash    = data[1].find_element(tag_name: 'a').text
      amount    = data[2].text&.split(/\s/)[1]&.to_f

      if !test_mode && has_new_rewards?(node, timestamp) && !stake_amount?(node, amount)
        operator.reward(timestamp, amount, txhash)
      else
        @total_amount_scraped += amount if !!@date && Time.parse(timestamp) >= @date
      end
    end
    @total_amount_scraped if test_mode
  end

  def scrape_gobyte(test_mode = false, node = nil, operator = nil)
    update_node_balance(node, browser.find_element(class_name: 'summary-table').find_elements(tag_name: 'td')[2].text.to_f) unless test_mode

    gobyte_rows.reverse!.each do |row|
      data = row.find_elements(tag_name: 'td')
      next if data.blank?

      timestamp = data[0].text
      txhash    = data[1].find_element(tag_name: 'a').text
      amount    = data[2].text&.split(/\s/)[1]&.to_f

      if !test_mode && has_new_rewards?(node, timestamp) && !stake_amount?(node, amount)
        operator.reward(timestamp, amount, txhash)
      else
        @total_amount_scraped += amount if !!@date && Time.parse(timestamp) >= @date
      end
    end
    @total_amount_scraped if test_mode
  end

  def scrape_gincoin(test_mode = false, node = nil, operator = nil)
    update_node_balance(node, browser.find_element(class_name: 'summary-table').find_elements(tag_name: 'td')[2].text.to_f) unless test_mode

    gincoin_rows.reverse!.each do |row|
      data = row.find_elements(tag_name: 'td')
      next if data.blank?

      timestamp = data[0].text
      txhash    = data[1].find_element(tag_name: 'a').text
      amount    = data[2].text&.split(/\s/)[1]&.to_f

      if !test_mode && has_new_rewards?(node, timestamp) && !stake_amount?(node, amount)
        operator.reward(timestamp, amount, txhash)
      else
        @total_amount_scraped += amount if !!@date && Time.parse(timestamp) >= @date
      end
    end
    @total_amount_scraped if test_mode
  end

  def polis_rows
    if Rails.env.development?
      browser.find_element(id: 'DataTables_Table_0').find_element(tag_name: 'tbody').find_elements(tag_name: 'tr')
    else
      browser.find_elements(tag_name: 'table')[2].find_element(tag_name: 'tbody').find_elements(tag_name: 'tr')
    end
  end

  def dash_rows
    browser.find_element(tag_name: 'tbody').find_elements(:class, 'direct')
  end

  def zcoin_rows
    browser.find_elements(:class, 'block-tx')
  end

  def pivx_rows
    browser.find_elements(tag_name: 'tbody')[2].find_elements(tag_name: 'tr')
  end

  def phore_rows
    browser.find_elements(tag_name: 'tbody')[2].find_elements(tag_name: 'tr')
  end

  def blocknet_rows
    browser.find_elements(tag_name: 'tbody')[2].find_elements(tag_name: 'tr')
  end

  def stipend_rows
    browser.find_elements(tag_name: 'table')[2].find_element(tag_name: 'tbody').find_elements(tag_name: 'tr')
  end

  def gobyte_rows
    if Rails.env.development?
      browser.find_element(id: 'DataTables_Table_0').find_element(tag_name: 'tbody').find_elements(tag_name: 'tr')
    else
      browser.find_elements(tag_name: 'table')[2].find_element(tag_name: 'tbody').find_elements(tag_name: 'tr')
    end
  end

  def gincoin_rows
    if Rails.env.development?
      browser.find_element(id: 'DataTables_Table_0').find_element(tag_name: 'tbody').find_elements(tag_name: 'tr')
    else
      browser.find_elements(tag_name: 'table')[2].find_element(tag_name: 'tbody').find_elements(tag_name: 'tr')
    end
  end


  def self.wallet_invalid?(browser)
    browser.find_elements(class_name: 'alert-danger').length > 0
  end

  private

  def update_node_balance(node, balance)
    node.update_attribute(:balance, balance)
  end

  def has_new_rewards?(node, timestamp)
    return false if node.online_at.blank?

    last_reward_timestamp = node.rewards.order(timestamp: :desc).first&.timestamp
    last_reward_timestamp ||= node.online_at
    last_reward_timestamp < DateTime.parse(timestamp)
  end

  def stake_amount?(node, amount)
    amount == node.stake
  end
end
