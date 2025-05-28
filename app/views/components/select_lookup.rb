class SelectLookup < ApplicationComponent
  attr_accessor :collection, :div_id, :field_value

  # collection is an array of hashes
  # div_id is the id of the div that will contain the lookup options
  # field_value is the value of the field
  #
  def initialize(collection:, div_id:, field_value: nil)
    @collection = collection
    @div_id = div_id
    @field_value = field_value
    @controller_name = collection.first.id==0 ? "notice" : "" rescue ""
    # debug-ger
  end

  def view_template(&block)
    div(
      id: "%s_lookup_options" % div_id,
      data: {
        lookup_target: "lookupOptions",
        controller: @controller_name
      }
    ) do
      if !collection.nil? and collection.any?
        #
        # options
        #
        ul(class: "absolute z-10 mt-1 max-h-60 w-full overflow-auto rounded-md bg-white py-1 text-base shadow-lg focus:outline-hidden sm:text-sm",
          id: "%s_lookup_container" % div_id,
          data: { lookup_target: "optionsList" },
          role: "listbox"
        ) do
          collection.each do |post|
            render SelectOption.new(field_value: field_value, post: post)
          end
        end
      end
    end
  end
end
