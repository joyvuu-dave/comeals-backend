/**
 * Welcome to your Workbox-powered service worker!
 *
 * You'll need to register this file in your web app and you should
 * disable HTTP caching for this file too.
 * See https://goo.gl/nhQhGp
 *
 * The rest of the code is auto-generated. Please don't update this file
 * directly; instead, make changes to your Workbox build configuration
 * and re-run your build process.
 * See https://goo.gl/2aRDsh
 */

importScripts("https://storage.googleapis.com/workbox-cdn/releases/3.2.0/workbox-sw.js");

/**
 * The workboxSW.precacheAndRoute() method efficiently caches and responds to
 * requests for URLs in the manifest.
 * See https://goo.gl/S9QRab
 */
self.__precacheManifest = [
  {
    "url": "401.html",
    "revision": "33d91c26b8c1f7d976245620028d932f"
  },
  {
    "url": "403.html",
    "revision": "febd300ecb88565686ab06e98aec9d53"
  },
  {
    "url": "404.html",
    "revision": "4ead20c186eaf2f7c09d6627ab7c0102"
  },
  {
    "url": "422.html",
    "revision": "0a33257c7b90fd1901a68c81fa88fdb7"
  },
  {
    "url": "500.html",
    "revision": "c7b77c4ffc436813480fd621a6b18c7f"
  },
  {
    "url": "apple-touch-icon-precomposed.png",
    "revision": "d41d8cd98f00b204e9800998ecf8427e"
  },
  {
    "url": "apple-touch-icon.png",
    "revision": "d41d8cd98f00b204e9800998ecf8427e"
  },
  {
    "url": "favicon.ico",
    "revision": "7873b63dc25ddae965ad4c20c065060b"
  },
  {
    "url": "index.html",
    "revision": "1f100bae27f6b14ac0225e7b6e670d75"
  },
  {
    "url": "packs/application-09fdc8b0.css",
    "revision": "ffea6ab674a12ee9698c37a752ad2057"
  },
  {
    "url": "packs/application-fb1091648383a2f077ed.js",
    "revision": "c4fb0bc5af1c8306683fcb8333ee8639"
  },
  {
    "url": "packs/images/carrot-fd708ec91aff06cb40f3ce976402b1c4.png",
    "revision": "fd708ec91aff06cb40f3ce976402b1c4"
  },
  {
    "url": "packs/images/cow-0947b83521236bb60d90aadb5be9cbfc.png",
    "revision": "0947b83521236bb60d90aadb5be9cbfc"
  },
  {
    "url": "packs/manifest.json",
    "revision": "310805b8b89a0068e50adef6f0a1ce8b"
  },
  {
    "url": "robots.txt",
    "revision": "bb355737b4d2d924bc2ac5dea1530a33"
  }
].concat(self.__precacheManifest || []);
workbox.precaching.suppressWarnings();
workbox.precaching.precacheAndRoute(self.__precacheManifest, {});
