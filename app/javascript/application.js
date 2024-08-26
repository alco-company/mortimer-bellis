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
