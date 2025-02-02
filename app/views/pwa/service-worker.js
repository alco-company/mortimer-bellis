// Add a service worker for processing Web Push notifications:
//
// self.addEventListener("push", async (event) => {
//   const { title, options } = await event.data.json()
//   event.waitUntil(self.registration.showNotification(title, options))
// })

self.addEventListener("push", (event) => {
  if (!(self.Notification && self.Notification.permission === "granted")) {
    return;
  }

  const data = event.data?.json() ?? {};
  const title = data.title || "Did not provide a title";
  const body = data.body || "The body was not provided";
  const icon = data.icon || "/favicon.ico";
  const url = data.url || "/";

  // const notification = new self.Notification(title,
  //   { body: body, 
  //     tag: "Mortimer Time/Material Delegation Notification",
  //     icon
  //   }
  // )
  event.waitUntil(self.registration.showNotification(title, {
    body: body,
    icon: icon,
    url: url
  }));
  

  // event.waitUntil(
  //   self.registration.showNotification(data.title, {
  //     body: data.body,
  //     data: data,
  //   })
  // );
});
// 
// self.addEventListener("notificationclick", function(event) {
//   event.notification.close()
//   event.waitUntil(
//     clients.matchAll({ type: "window" }).then((clientList) => {
//       for (let i = 0; i < clientList.length; i++) {
//         let client = clientList[i]
//         let clientPath = (new URL(client.url)).pathname
// 
//         if (clientPath == event.notification.data.path && "focus" in client) {
//           return client.focus()
//         }
//       }
// 
//       if (clients.openWindow) {
//         return clients.openWindow(event.notification.data.path)
//       }
//     })
//   )
// })
