host "www.nodebucks.com"

sitemap :site do
  url 'https://nodebucks.com', last_mod: Time.zone.now, change_freq: "daily"
  url 'https://nodebucks.com/login', last_mod: Time.zone.now, change_freq: "yearly"
  url 'https://nodebucks.com/sign-up', last_mod: Time.zone.now, change_freq: "yearly"
  url 'https://nodebucks.com/dashboard', last_mod: Time.zone.now, change_freq: "daily"
  url 'https://nodebucks.com/masternodes', last_mod: Time.zone.now, change_freq: "daily"
  url 'https://nodebucks.com/faq', last_mod: Time.zone.now, change_freq: "monthly"
  url 'https://nodebucks.com/terms', last_mod: Time.zone.now, change_freq: "yearly"
  url 'https://nodebucks.com/contact', last_mod: Time.zone.now, change_freq: "yearly"
  url 'https://nodebucks.com/privacy', last_mod: Time.zone.now, change_freq: "yearly"
  url 'https://nodebucks.com/disclaimer', last_mod: Time.zone.now, change_freq: "yearly"
  url 'https://nodebucks.com/contact', last_mod: Time.zone.now, change_freq: "yearly"
  url 'https://nodebucks.com/orders', last_mod: Time.zone.now, change_freq: "monthly"
  url 'https://nodebucks.com/withdrawals', last_mod: Time.zone.now, change_freq: "monthly"
  url 'https://nodebucks.com/settings', last_mod: Time.zone.now, change_freq: "monthly"
  url 'https://nodebucks.com/nodes/withdraw', last_mod: Time.zone.now, change_freq: "monthly"

  Crypto.all.each do |crypto|
    url "https://nodebucks.com/nodes/#{crypto.slug}/new", last_mod: Time.zone.now, change_freq: "daily"
    url "https://nodebucks.com/masternodes/#{crypto.slug}", last_mod: Time.zone.now, change_freq: "daily"
  end
end

# Ping search engines after sitemap generation
ping_with "http://#{host}/sitemap.xml"
