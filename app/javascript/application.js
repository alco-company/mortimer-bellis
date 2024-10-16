// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

Turbo.StreamActions.show_remote_modal = function () {
  const container = document.querySelector("remote-modal-container");
  container.replaceChildren(this.templateContent);
  container.querySelector("dialog").showModal();
};

Turbo.StreamActions.close_remote_modal = function () {
  const container = document.querySelector("remote-modal-container");
  container.replaceChildren(this.templateContent);
  container.querySelector("dialog").close();
};

Turbo.StreamActions.show_filter = function () {
  const container = document.querySelector("filter-container");
  container.replaceChildren(this.templateContent);
  container.querySelector("li").classList.remove("hidden");
};

Turbo.StreamActions.full_page_redirect = function () {
  document.location = this.getAttribute("target");
};

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/service-worker.js").then(
      (registration) => {
        console.log("Service Worker registered", registration);
      },
      (err) => {
        console.error("Service Worker registration failed: ", err);
      }
    );
  });
} else {
  console.log("Service Worker is not supported by browser.");
}