# frozen_string_literal: true

class PosPunchClockLayout < ApplicationView
  include Phlex::Rails::Layout

  def view_template(&block)
    doctype

    html(class: "h-full bg-white") do
      head do
        title { "M O R T I M E R #{ 'DEV' if Rails.env.local?}" }
        meta name: "viewport", content: "width=device-width,initial-scale=1"
        csp_meta_tag
        csrf_meta_tags
        link rel: "preconnect", href: "https://rsms.me/"
        link rel: "stylesheet", href: "https://rsms.me/inter/inter.css"
        stylesheet_link_tag "tailwind", "inter-font", data_turbo_track: "reload"
        stylesheet_link_tag "application", data_turbo_track: "reload"
        javascript_importmap_tags
        yield :head
      end

      body(class: "h-full") do
        yield :nav
        main(class: "") do
          yield
        end
        yield :flash
        yield :footer
        # yield :motd
      end
    end
  end
end
