task :scrape => :environment do
  kget = KGET.new()
  kget.scrape
end
