// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
// import PullToRefresh from "pulltorefreshjs"
import "custom_stream_actions"
import "custom/companion"

const standalone = true //window.matchMedia("(display-mode: standalone)").matches

// if (standalone) {
//     PullToRefresh.init({
//         mainElement: "#main-element",
//         triggerElement: "#record_list",
//         onRefresh() {
//             window.location.reload()
//         },
//     })
// }

addEventListener("turbo:before-stream-render", (event) => {
  const fallbackToDefaultActions = event.detail.render;

  event.detail.render = function (streamElement) {
    if (streamElement.action == "redirect") {
      window.location.href = streamElement.getAttribute("location");
    } else {
      fallbackToDefaultActions(streamElement);
    }
  };
});