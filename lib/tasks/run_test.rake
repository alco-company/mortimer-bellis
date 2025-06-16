require "listen"
namespace :run_test do
  listener = Listen.to("app/", "bin/", "config/", "lib/", "test/") do |modified, added, removed|
    modified.each do |file|
      case file
      when /app\//
        if File.exist?(Rails.root.join("test", "#{file.split('/bellis/app/')[1].gsub(/\.rb$/, "")}_test.rb"))
         system "rails test test/#{file.split('/bellis/app/')[1].gsub(/\.rb$/, "")}_test.rb"
        end
      end
    end
  end
  listener.start
  sleep
end
