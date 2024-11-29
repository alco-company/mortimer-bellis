// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import PullToRefresh from "pulltorefreshjs"
import "custom_stream_actions"


const standalone = window.matchMedia("(display-mode: standalone)").matches

if (standalone) {
    PullToRefresh.init({
        onRefresh() {
            if (!document.getElementById("dont-refresh")) {
                window.location.reload()
            }
        },
    })
}
