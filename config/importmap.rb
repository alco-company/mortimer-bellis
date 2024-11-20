# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@rails/request.js", to: "@rails--request.js.js" # @0.0.9
pin "tailwindcss/plugin", to: "tailwindcss--plugin.js" # @3.4.3
pin "a17t" # @0.10.1
pin "el-transition" # @0.0.7
pin "pulltorefreshjs" # @0.1.22
pin "notifications"
pin "custom_stream_actions"
