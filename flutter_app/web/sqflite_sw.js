// sqflite service worker
// This file is required for sqflite_common_ffi_web to work properly

importScripts('sqlite3.wasm.js');

const CACHE_NAME = 'sqflite-cache-v1';

self.addEventListener('install', (event) => {
  console.log('sqflite service worker installing');
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  console.log('sqflite service worker activating');
  event.waitUntil(self.clients.claim());
});

self.addEventListener('message', (event) => {
  console.log('sqflite service worker received message:', event.data);
});