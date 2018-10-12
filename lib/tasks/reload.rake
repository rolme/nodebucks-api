namespace :db do
  desc 'Completely drop and reload the database; drop, create, migrate, and seed.'
  task reload: :environment do
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:seed"].invoke
  end
end
