// Add a service worker for processing Web Push notifications:
//
// self.addEventListener("push", async (event) => {
//   const { title, options } = await event.data.json()
//   event.waitUntil(self.registration.showNotification(title, options))
// })

//
// test service-worker functioning ok
// function onInstall(event) {
//   console.log("[Serviceworker]", "Installing!", event);
// }

// function onActivate(event) {
//   console.log("[Serviceworker]", "Activating!", event);
// }

// function onFetch(event) {
//   console.log("[Serviceworker]", "Fetching!", event);
// }
// self.addEventListener("install", onInstall);
// self.addEventListener("activate", onActivate);
// self.addEventListener("fetch", onFetch);
//

let   client;
let   d0 = null;
let   timer = 25 * 60 * 1000;
let pomodoroInterval = null;

self.addEventListener("message", (event) => {
  if (event.data && event.data.type === "INIT_POMODORO_TIMER") {
    client = event.source;
  }

  if (event.data && event.data.type === "START_POMODORO_TIMER") {
    d0 = new Date().valueOf();
    pomodoroInterval = setInterval(pomodoroTimer, 200);
  }

  if (event.data && event.data.type === "STOP_POMODORO_TIMER") {
    clearInterval(pomodoroInterval);
  }

  if (event.data && event.data.type === "RESTART_POMODORO_TIMER") {
    client.postMessage({ payload: "25:00" });
    clearInterval(pomodoroInterval);
    d0 = new Date().valueOf();
    timer = 25 * 60 * 1000;
    pomodoroInterval = setInterval(pomodoroTimer, 200);
  }
});

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


function pomodoroTimer() {
  // get current time
  var d = new Date().valueOf();
  // calculate time difference between now and initial time
  var diff = d - d0;
  if (diff > 1000) {
    console.log(`diff ${diff}`);
    d0 = d;
    timer = timer - 1000;
    if (timer < 0) {
      clearInterval(pomodoroInterval);
      client.postMessage({ type: "PLAY", payload: "25:00" });
      return;
    }
  }
  // calculate number of minutes
  var minutes = Math.floor(timer / 1000 / 60);
  // calculate number of seconds
  var seconds = Math.floor(timer / 1000) - minutes * 60;
  var myVar = null;
  // if number of minutes less than 10, add a leading "0"
  minutes = minutes.toString();
  if (minutes.length == 1) {
    minutes = "0" + minutes;
  }
  // if number of seconds less than 10, add a leading "0"
  seconds = seconds.toString();
  if (seconds.length == 1) {
    seconds = "0" + seconds;
  }

  // return output to Web Worker
  var payload = minutes + ":" + seconds;
  client.postMessage({ type: "TIMER", payload: payload });
}

