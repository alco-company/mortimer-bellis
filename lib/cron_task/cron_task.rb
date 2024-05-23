require 'cron_task/mapping_generator'
require 'cron_task/presenter'
require 'cron_task/time_lapse_interpreter'

module CronTask
  class CronTask
    def self.explain(crontask)
      if crontask =~ cron_job_regexp
        mapping = MappingGenerator.new(crontask).call
        puts Presenter.new(mapping)
      else
        print error_message
      end
    end

    def self.stamp2string ts 
      DateTime.strptime(ts.to_s,'%s')
    end

    #
    # is this crontask now?
    # allow a minute on both sides!
    # m h dom mon dow cmd
    #
    def self.now? **args 
      crontask = args[:schedule] || nil
      dt = args[:when_at] || DateTime.current

      return false unless self.args_valid?(crontask, dt, false)
      return false unless mapping = self.get_runs(crontask, dt)
      return false unless dt.wday.in? mapping[4]
      return false unless dt.month.in? mapping[3]
      return false unless dt.day.in? mapping[2]
      return false unless dt.hour.in? mapping[1]
      return false unless dt.min.in? mapping[0].collect{|m| [m-1,m,m+1]}.flatten.collect{|m| [m-1,m,m+1]}.flatten.collect{ | m | m < 0 ? (60+m) : (m>59 ? 60-m : m)}
      true
    rescue
      false
    end

    #
    # any due times today for this crontask?
    #
    def self.runs_today **args 
      args[:when_at] = DateTime.current
      args[:scope] = 'today'
      args[:index] = -1
      args[:later] = false
      self.runs_at( **args )
    end
    
    #
    # when is this crontask due next time? 
    # consider today, return first timestamp
    # scope allows for returning next_run even if in 10 years
    #
    def self.next_run **args 
      args[:later] = true
      args[:scope] ||= 'today'
      args[:index] ||= 0
      self.runs_at( **args )
    end

    #
    # if some cmd did run at somewhen -  
    #
    # schedule = "*/15 0 4,15 * 1-5 /usr/bin/find"
    # when_at = DateTime.parse "2040-12-04 0:15:01"
    # later = this instance forward or all day
    # scope = 'today','24h','week','month','year','any' - meaning
    # index = -1 (all), 0 (first), 1 (second), etc 
    #
    def self.runs_at schedule: nil, when_at: DateTime.current, later: true, scope: 'any', index: -1
      return nil unless self.args_valid?( schedule, when_at, later )

      runs = self.sorted_datetime_by_day( schedule, when_at, later, scope )
      return runs if index == -1
      runs[index]
    end

    private

      #
      # do we provide the correct arguments?
      # crontask: * * * * * /some/task
      # dt: nil or DateTime something - but never in the past!
      # 'cause cron only deals in the future of events
      #
      def self.args_valid? crontask=nil, dt=nil, only_later=true
        the_past = dt - 1.second
        return false if crontask.strip.blank?
        return false unless crontask.split(' ').count > 3
        return false if dt < the_past and only_later
        true
      end

      #
      # return the mapping of some day 
      # [[minutes],[hrs],[days],[months],[week days]]
      #
      def self.get_runs crontask, dt=nil
        mapping = MappingGenerator.new(crontask).call
        # return false unless ( mapping[4].include?(dt.wday) && mapping[3].include?(dt.month) && mapping[2].include?(dt.day) )
        mapping
      rescue
        false
      end

      #
      # scope 'hour','today','24h','week','month','year','any' - meaning 
      # if scope is today only mappings today are considered, etc
      #
      # return sort min to max timestamps for the mapping 
      # pertaining to some DateTime
      # [ts,ts,ts,ts]
      #
      def self.sorted_datetime_by_day crontask, dt, only_later=false, scope='today'
        return [] unless mapping = self.get_runs(crontask, dt)
        if only_later
          mapping = self.anything_later(mapping,dt,scope) 
        else 
          t1 = dt.at_beginning_of_week
          t2 = dt.at_end_of_week
          mapping[3] = mapping[3].filter{|m| m if m.in? ((t1..t2).map( &:month).uniq) }  
          mapping[2] = mapping[2].filter{|m| m if m.in? ((t1..t2).map( &:day).uniq) }  
        end

        now = only_later ? dt : dt.at_beginning_of_day
        r = []
        case scope 
        when 'hour'
          template = "%s-%s-%s %s:" % [dt.year,dt.month,dt.day, dt.hour]
          template += "%s:00"
          mapping[0].each do |min|
            t= DateTime.parse(template % [min])
            r.push t.to_f unless t < now
          end
        when 'today'
          template = "%s-%s-%s" % [dt.year,dt.month,dt.day]
          template += " %s:%s:00"
          mapping[1].each do |hr|
            mapping[0].each do |min|
              t= DateTime.parse(template % [hr,min])
              r.push t.to_f unless (t < now and only_later)
            end
          end
        when 'month'
          template = "%s-%s-" % [dt.year,dt.month]
          template += "%s %s:%s:00"
          mapping[2].each do |d|
            mapping[1].each do |hr|
              mapping[0].each do |min|
                t= DateTime.parse(template % [d,hr,min])
                r.push t.to_f unless (t < now and only_later)
              end
            end
          end
        when 'week'
          template = "%s-" % [dt.year]
          template += "%s-%s %s:%s:00"
          mapping[3].each do |m|
            mapping[2].each do |d|
              mapping[1].each do |hr|
                mapping[0].each do |min|
                  t= DateTime.parse(template % [m,d,hr,min]) rescue nil
                  r.push t.to_f unless (t.nil? or (t < now and only_later))
                end
              end
            end
          end          
        when '24h'
          t1 = now
          t2 = dt + 24.hours
          template = "%s-" % [dt.year]
          template += "%s-%s %s:%s:00"
          mapping[3].each do |m|
            mapping[2].each do |d|
              mapping[1].each do |hr|
                mapping[0].each do |min|
                  t= DateTime.parse(template % [m,d,hr,min]) rescue nil
                  r.push t.to_f unless (t.nil? or ((t < t1 or t2 < t ) and only_later))
                end
              end
            end
          end          
        when 'year','any'
          template = "%s-" % [dt.year]
          template += "%s-%s %s:%s:00"
          mapping[3].each do |m|
            mapping[2].each do |d|
              mapping[1].each do |hr|
                mapping[0].each do |min|
                  t= DateTime.parse(template % [m,d,hr,min]) rescue nil
                  r.push t.to_f unless (t.nil? or (t < now and only_later))
                end
              end
            end
          end
        end
        r.sort
      # rescue
      #   []
      end

      #
      # get only the hrs/min after now
      # scope 'today','24h','week','month','year','any' - meaning 
      # if scope is today only mappings today are considered, etc
      # 
      def self.anything_later mapping, dt, scope
        case scope
        when 'hour'
          return [[],[],[],[],[]] unless mapping[1].include? dt.hour
          mapping[0] = mapping[0].filter{|m| m if (m >= dt.minute) }
        when 'today'
          mapping[3] = mapping[3].filter{|m| m if m == dt.month }  
          mapping[2] = mapping[2].filter{|m| m if m == dt.day }  
          mapping[1] = mapping[1].filter{|h| h unless h < dt.hour }
        when '24h'
          t1 = dt
          t2 = dt + 24.hours
          mapping[3] = mapping[3].filter{|m| m if m.in? ((t1..t2).map( &:month).uniq) }  
          mapping[2] = mapping[2].filter{|m| m if m.in? ((t1..t2).map( &:day).uniq) }  
        when 'week'
          t1 = dt
          t2 = dt.at_end_of_week
          mapping[3] = mapping[3].filter{|m| m if m.in? ((t1..t2).map( &:month).uniq) }  
          mapping[2] = mapping[2].filter{|m| m if m.in? ((t1..t2).map( &:day).uniq) }  
        when 'month'
          mapping[3] = mapping[3].filter{|m| m if m == dt.month }  
          mapping[2] = mapping[2].filter{|m| m unless m < dt.day }  
        when 'year'
          mapping[3] = mapping[3].filter{|m| m unless m < dt.month } 
        when 'any'
          # mapping
        else return [[],[],[],[],[]]
        end
        mapping
      end

      def self.cron_job_regexp
        /([^\s]+)\s([^\s]+)\s([^\s]+)\s([^\s]+)\s([^\s]+)\s([^#\n$]*)(\s#\s([^\n$]*)|$)/
      end


    def self.error_message
<<-HEREDOC
Invalid cron task
Please provide a valid cron task in a string
Usage:
bin/cronparse "* * * * * bin/do_something"
HEREDOC
    end

  end
end