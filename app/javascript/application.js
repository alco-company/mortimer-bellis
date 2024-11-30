// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import PullToRefresh from "pulltorefreshjs"
import "custom_stream_actions"


const standalone = true // window.matchMedia("(display-mode: standalone)").matches

if (standalone) {
    PullToRefresh.init({
        mainElement: "#main-element",
        triggerElement: "#record_list",
        onRefresh() {
            if (!document.getElementById("dont-refresh")) {
                window.location.reload()
            }
        },
    })
}
