// if ("serviceWorker" in navigator) {
//   window.addEventListener("load", () => {
//     navigator.serviceWorker.register("/service-worker.js").then(
//       (registration) => {
//         console.log("Service Worker registered", registration);
//         showPromptForNotifications(registration);
//       },
//       (err) => {
//         console.error("Service Worker registration failed: ", err);
//       }
//     );
//   });
// } else {
//   console.log("Service Worker is not supported by browser.");
// }

//
// Show a prompt to the user to subscribe to notifications
export function showPromptForNotifications(registration) {
  const notificationsButton = document.getElementById("enable_notifications");

  if (!notificationsButton) return;

  registration.pushManager.getSubscription().then(
    (subscription) => {
      if (subscription) {
        console.log("User is subscribed to notifications");
        setupSubscription(registration, subscription);
      } else {
        // notificationsButton.disabled = true;
        notificationsButton.classList.remove("hidden");
        // notificationsButton.addEventListener("click", (event) => {
        //   event.preventDefault();
        //   subscribe(registration);
        // });
      }
    },
    (err) => {
      console.log("Error getting subscription: ", err);
    }
  );
}

export function subscribe(registration) {
  Notification.requestPermission()
    .then((permission) => {
      if (permission === "granted") {
        setupSubscription(registration);
      } else {
        alert("Notifications declined");
      }
    })
    .catch((error) => console.log("Notifications error", error));
}

export function unsubscribe() {
  // notificationsDisableButton.disabled = true;

  navigator.serviceWorker.ready.then(function (serviceWorkerRegistration) {
    // To unsubscribe from push messaging, you need get the
    // subcription object, which you can call unsubscribe() on.
    serviceWorkerRegistration.pushManager.getSubscription().then(
      async function (subscription) {
        // Check we have a subscription to unsubscribe
        if (!subscription) {
          // No subscription object, so set the state
          // to allow the user to subscribe to push
          // notificationsDisableButton.disabled = false;
          return;
        }

        // Make a request to your server to remove
        // the users data from your data store so you
        // don't attempt to send them push messages anymore
        await fetch("/web_push_subscriptions?unsubscribe=true", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(subscription),
        }).then(
          (response) => {
            if (response.ok) {
              console.log("Unsubscription setup successful");
              // We have a subcription on the client too, so call unsubscribe on it
              subscription
                .unsubscribe()
                })
                .catch(function (e) {
                  // We failed to unsubscribe, this can lead to
                  // an unusual state, so may be best to remove
                  // the subscription id from your data store and
                  // inform the user that you disabled push
                  // notificationsDisableButton.disabled = false;
                });
          } else {
            console.log("Unsubscription setup failed");
          }
        });
      },
      (err) => {
        console.log("Error getting subscription: ", err);
      }
    );
  });
}

//
// Setup the subscription with the push server - provided the user has granted permission
async function setupSubscription(registration, subscription = null) {
  const notificationsDisableButton = document.getElementById( "disable_notifications");

  if (!navigator.serviceWorker) return;
  if (!registration) return;
  if (Notification.permission !== "granted" && !subscription) return;

  if (!subscription) {
    let vapid = new Uint8Array(
      JSON.parse(document.querySelector("meta[name=web_push_public]")?.content)
    );

    subscription = await registration.pushManager.subscribe({
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
      console.log("Subscription setup successful");
    } else {
      console.log("Subscription setup failed");
    }
  });
}
