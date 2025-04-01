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
  observer = null

  disconnect() {
    if (this.observer)
      this.observer.disconnect();
  }

  connect() {
    navigator.serviceWorker.register("/service-worker.js").then(
      (reg) => {
        this.observer = new MutationObserver((mutationRecords) => {
          console.log(mutationRecords); // console.log(the changes)
          // execute your code here.
          console.log('BØH')
        });
        this.registration = reg;
        if (!this.registration) return;
        this.showPromptForNotifications();
      },
      (err) => {
        console.error("Service Worker registration failed: ", err);
      }
    );
  }

  enableNotificationsTargetConnected(element) {
    // console.log('fisk 2')
    this.buttonFormTarget.ariaBusy = false;
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
    if (!this.registration) return;

    const csrfToken = document.querySelector("[name='csrf-token']").content;
    let r = this.registration
    let en = this.enableNotificationsTarget
    let dn = this.disableNotificationsTarget
    let elem = document.getElementById("enable_notifications");

    // observe everything except attributes
    this.observer.observe(elem, {
      childList: true, // observe direct children
      subtree: true, // and lower descendants too
      characterDataOldValue: true, // pass old data to callback
    });

    this.registration.pushManager.getSubscription()
    .then(
      async function (subscription) {
        if (!subscription) return;

        await fetch("/web_push_subscriptions?unsubscribe=true", {
          method: "POST",
          headers: {
            "X-CSRF-Token": csrfToken,
            "Accept": "text/vnd.turbo-stream.html",
            "Content-Type": "application/json",
          },
          body: JSON.stringify(subscription),
        })
        .then((r) => r.text())
        .then((html) => {
          Turbo.renderStreamMessage(html);
        })
          
        // .then((response) => {
        //   if (response.ok) {
        //     subscription.unsubscribe();
        //     r = null;
        //     leave(dn).then(() => {
        //       enter(en);
        //     });
        //   }
        // })
        // .catch(function (e) {
        //   console.log("Server unsubscription setup failed", e);
        // });
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
    const csrfToken = document.querySelector("[name='csrf-token']").content;

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
        "X-CSRF-Token": csrfToken,
        "Accept": "text/vnd.turbo-stream.html",
        "Content-Type": "application/json",
      },
      body: JSON.stringify(subscription),
    })
    .then(r => r.text())
    .then((html) => {
      Turbo.renderStreamMessage(html);
      // if (response.ok) {
      //   leave(this.enableNotificationsTarget).then(() => {
      //     enter(this.disableNotificationsTarget);
      //     this.buttonFormTarget.ariaBusy = false;
      //   });
      // } else {
      //   console.log("Subscription setup failed");
      // }
    });
  }
}
