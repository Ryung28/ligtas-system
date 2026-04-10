// LIGTAS PWA Service Worker
// Basic caching strategy for offline support

const CACHE_NAME = 'ligtas-tactical-v2';
const OFFLINE_URL = '/offline';

// Assets to cache on install - Strategic Pre-loading
const PRECACHE_ASSETS = [
  '/',
  '/m',
  '/m/inventory',
  '/m/approvals',
  '/m/logs',
  '/offline',
  '/oro-cervo.png',
  '/favicon.ico'
];

// Install event - cache essential assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('[SW] Precaching assets');
      return cache.addAll(PRECACHE_ASSETS);
    })
  );
  self.skipWaiting();
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('[SW] Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  self.clients.claim();
});

// Fetch event - Optimized Strategy: Cache-First for UI, Network-First for Data
self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;
  if (!event.request.url.startsWith('http')) return;

  const url = new URL(event.request.url);

  // 🏛️ STRATEGY 1: Static Assets & JS Chunks - CACHE FIRST
  if (url.pathname.startsWith('/_next/static/') || 
      url.pathname.startsWith('/icons/') ||
      url.pathname.endsWith('.png') ||
      url.pathname.endsWith('.webp')) {
    event.respondWith(
      caches.match(event.request).then((cachedResponse) => {
        if (cachedResponse) return cachedResponse;
        return fetch(event.request).then((response) => {
          const responseToCache = response.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseToCache);
          });
          return response;
        });
      })
    );
    return;
  }

  // 🏛️ STRATEGY 2: Navigation & Routes - STALE-WHILE-REVALIDATE
  // This makes "/m/inventory" load instantly from cache while updating in background
  if (event.request.mode === 'navigate' || url.pathname.startsWith('/m')) {
    event.respondWith(
      caches.match(event.request).then((cachedResponse) => {
        const fetchPromise = fetch(event.request).then((networkResponse) => {
          const responseToCache = networkResponse.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseToCache);
          });
          return networkResponse;
        });
        return cachedResponse || fetchPromise;
      }).catch(() => caches.match(OFFLINE_URL))
    );
    return;
  }

  // 🏛️ STRATEGY 3: General Requests - NETWORK FIRST
  event.respondWith(
    fetch(event.request)
      .then((response) => {
        const responseToCache = response.clone();
        caches.open(CACHE_NAME).then((cache) => {
          cache.put(event.request, responseToCache);
        });
        return response;
      })
      .catch(() => caches.match(event.request))
  );
});
