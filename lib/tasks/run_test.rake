require "listen"
namespace :run_test do
  listener = Listen.to("app/", "bin/", "config/", "lib/", "test/") do |modified, added, removed|
    modified.each do |file|
      case file
      when /app\//; system "rails test test/#{file.split('/bellis/app/')[1].gsub(/\.rb$/, "")}_test.rb"
      end
    end
    puts(modified: modified, added: added, removed: removed)
  end
  listener.start
  sleep
end
