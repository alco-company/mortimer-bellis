import { Controller } from "@hotwired/stimulus"
import { enter, leave } from "el-transition"

// Connects to data-controller="profile"
export default class extends Controller {

  static targets = [
    "buttonForm",
    "enableNotifications",
    "disableNotifications"
  ]

  registration = null

  connect() {
    navigator.serviceWorker.register("/service-worker.js").then(
      (reg) => {
        this.registration = reg;
        if (!this.registration) return;
        this.showPromptForNotifications();
      },
      (err) => {
        console.error("Service Worker registration failed: ", err);
      }
    );
  }

  enable(event) {
    event.preventDefault()
    if (!this.registration) return;
    this.buttonFormTarget.ariaBusy = true;
    Notification.requestPermission()
      .then((permission) => {
        if (permission === "granted") {
          this.setupSubscription();
        } else {
          console.log("Notifications declined");
        }
      })
      .catch((error) => console.log("Notifications error", error));
  }

  disable(event) {
    event.preventDefault()
    console.log("Disable notifications")
    if (!this.registration) return;

    let r = this.registration
    let en = this.enableNotificationsTarget
    let dn = this.disableNotificationsTarget

    this.registration.pushManager.getSubscription().then(
      async function (subscription) {
        if (!subscription) return;

        await fetch("/web_push_subscriptions?unsubscribe=true", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(subscription),
        }).then((response) => {
          if (response.ok) {
            subscription.unsubscribe()
            r = null
            leave(dn).then(() => {
              enter(en)
            })
          }
        }).catch(function (e) {
          console.log("Server unsubscription setup failed", e);
        })
      })
  }

  // Show a prompt to the user to subscribe to notifications
  showPromptForNotifications() {
    this.registration.pushManager.getSubscription().then(
      (subscription) => {
        if (subscription) {
          this.setupSubscription(subscription);
        } else {
          enter(this.enableNotificationsTarget)
        }
      },
      (err) => {
        console.log("Error getting subscription: ", err);
      }
    );
  }

  //
  // Setup the subscription with the push server - provided the user has granted permission
  async setupSubscription(subscription = null) {
    if (Notification.permission !== "granted" && !subscription) return;

    if (!subscription) {
      let vapid = new Uint8Array(
        JSON.parse(document.querySelector("meta[name=web_push_public]")?.content)
      );

      subscription = await this.registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: vapid,
      });
    }

    await fetch("/web_push_subscriptions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(subscription),
    }).then((response) => {
      if (response.ok) {
        leave(this.enableNotificationsTarget).then(() => {
          enter(this.disableNotificationsTarget);
        });
      } else {
        console.log("Subscription setup failed");
      }
    });
  }
}
