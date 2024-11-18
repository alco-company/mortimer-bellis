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
        showPromptForNotifications(registration);
      },
      (err) => {
        console.error("Service Worker registration failed: ", err);
      }
    );
  });
} else {
  console.log("Service Worker is not supported by browser.");
}

// 
// Show a prompt to the user to subscribe to notifications
function showPromptForNotifications(registration) {
  const notificationsButton = document.getElementById("enable_notifications");
  if (!notificationsButton) return;

  Notification.requestPermission().then((callback) => {
    if (callback === "granted") {
      setupSubscription(registration);
    } else {
      notificationsButton.classList.remove("hidden");
      notificationsButton.addEventListener("click", (event) => {
        event.preventDefault();
        Notification.requestPermission()
          .then((permission) => {
            if (permission === "granted") {
              setupSubscription(registration);
            } else {
              alert("Notifications declined");
            }
          })
          .catch((error) => console.log("Notifications error", error))
          .finally(() => notificationsButton.classList.add("hidden"));
      });
    }
  });
}

//
// Setup the subscription with the push server - provided the user has granted permission
async function setupSubscription(registration) {
  if (Notification.permission !== "granted") return;
  if (!navigator.serviceWorker) return;
  if (!registration) return;

  let vapid = new Uint8Array(
    JSON.parse(document.querySelector("meta[name=web_push_public]")?.content)
  );

  // await navigator.serviceWorker.register("/service_worker.js");
  // const registration = await navigator.serviceWorker.ready;
  const subscription = await registration.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: vapid,
  });

  await fetch("/web_push_subscriptions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(subscription),
  });
}