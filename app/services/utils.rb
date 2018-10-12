class Utils
  def self.usd_to_btc(amount)
    amount / btc_price
  end

  def self.btc_price
    parsed_response(Typhoeus::Request.get("https://www.bitstamp.net/api/ticker/").body)['last'].to_f
  end

  def self.parsed_response(response)
    begin
      JSON.parse(response)
    rescue JSON::ParserError => e
      { error: e.to_s }
    end
  end

  def self.average(array)
    array.reduce(:+) / array.size
  end
end
