class SiteMapWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  def perform(*args)
    Nodebucks::Application.load_tasks
    Rake::Task['sitemap:generate'].invoke
    FileUtils.cp("#{Rails.root}/public/sitemaps/sitemap.xml", "#{Rails.root}/public/sitemap.xml")
    FileUtils.cp("#{Rails.root}/public/sitemaps/sitemap.xml", "#{Rails.root}/client/public/sitemap.xml")
  end
end
