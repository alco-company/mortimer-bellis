#
#
# handles the state of the asset
#
module TimeZoned
  extend ActiveSupport::Concern

  included do

    # validates :time_zone, presence: true, time_zone: true

    def all_time_zones
      TZInfo::Timezone.all_identifiers
      # [time_zone]
    end
    
    def self.search_tz value
      TZInfo::Timezone.all_identifiers.filter { |s| /#{value}/i.match s }
    end

    def lookup_label
      :name
    end
    
    # def self.all 
    #   TZInfo::Timezone.all_identifiers 
    # end

  end

  class_methods do  
    def time_zone_values cls
      TZInfo::Timezone.all_identifiers.collect{ |k| {id: k, cls: cls, name: k} }
    end

  end
end