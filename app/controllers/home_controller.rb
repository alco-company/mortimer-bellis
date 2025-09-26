class HomeController < ApplicationController
  def show
    @entries = parse_worklog(Rails.root.join("WORKLOG.md"))
    # @entries.sort_by! { |e| e[:date] }.reverse!
  end

  private

    require "date"

    def parse_worklog(path)
      entries = []
      current_date = nil
      buffer = []

      File.foreach(path, chomp: true) do |raw|
        line = raw.rstrip

        if line.start_with?("### ")
          heading = line.sub(/^###\s*/, "").strip

          if heading.match?(/^\d{1,2}\/\d{2}\/\d{4}$/)
            # Flush previous date section
            if current_date
              entries << {
                date: Date.strptime(current_date, "%d/%m/%Y"),
                bullets: buffer.dup
              }
            end
            current_date = heading
            buffer = []
          else
            # Non-date heading (e.g. CHANGELOG) – ignore, do not flush
          end

          next
        end

        next unless current_date

        # Collect bullet ( - ) lines until next heading
        if line.strip.start_with?("- ")
          buffer << line.strip.sub(/^-+\s*/, "")
        elsif line.strip.empty?
          # keep blank separation if you want:
          # buffer << ""
        else
          # Optional: capture any non-bullet descriptive lines
          buffer << line.strip
        end
      end

      # Flush last
      if current_date
        entries << {
          date: Date.strptime(current_date, "%d/%m/%Y"),
          bullets: buffer
        }
      end

      entries
    end
end
