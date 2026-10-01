// V1 has moved to https://tennisbom.com/. This worker replaces the old V1 worker,
// clears only V1 caches (V2 caches use the "tennis-homepage-v2-" prefix) and unregisters itself.
self.addEventListener("install", () => self.skipWaiting());

self.addEventListener("activate", event => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys
      .filter(key => key.startsWith("tennis-homepage-") && !key.startsWith("tennis-homepage-v2-"))
      .map(key => caches.delete(key)));
    await self.registration.unregister();
    const windows = await self.clients.matchAll({ type: "window" });
    windows.forEach(client => client.navigate(client.url));
  })());
});
