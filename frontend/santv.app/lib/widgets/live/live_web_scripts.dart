/// Scripts JS que se inyectan en el reproductor web del canal en vivo.
/// Los comparten LiveChannelPlayer, LiveStreamPlayer y LiveFullscreenScreen.
class LiveWebScripts {
  LiveWebScripts._();

  /// Cuando el reproductor web intenta pasar a pantalla completa (su
  /// botón de ampliar), en vez de abrir el nativo (estirado) avisa a
  /// Flutter por el canal `SanTvBridge`.
  static const String fullscreenBridge = '''
    (function () {
      if (window.__santvFs) return;
      window.__santvFs = true;
      function open() {
        try { SanTvBridge.postMessage('fullscreen'); } catch (e) {}
        return Promise.resolve();
      }
      Element.prototype.requestFullscreen = open;
      Element.prototype.webkitRequestFullscreen = open;
      Element.prototype.webkitRequestFullScreen = open;
      HTMLVideoElement.prototype.webkitEnterFullscreen = open;
      HTMLVideoElement.prototype.webkitEnterFullScreen = open;
    })();
  ''';

  /// Oculta el botón de pantalla completa del reproductor web (se usa
  /// el botón propio de la app). Es idempotente.
  static const String hideFullscreenButton = '''
    (function () {
      if (document.getElementById('santv-hide-fs')) return;
      var st = document.createElement('style');
      st.id = 'santv-hide-fs';
      st.textContent =
        'button[class*="fullscreen" i], [role="button"][class*="fullscreen" i],' +
        'button[aria-label*="ullscreen" i], button[title*="ullscreen" i],' +
        'button[aria-label*="antalla completa" i], button[title*="antalla completa" i],' +
        'button[aria-label*="mpliar" i], button[title*="mpliar" i],' +
        '.vjs-fullscreen-control, .jw-icon-fullscreen, .ytp-fullscreen-button,' +
        '.mejs__fullscreen-button, [data-plyr="fullscreen"]' +
        '{ display: none !important; }';
      (document.head || document.documentElement).appendChild(st);
    })();
  ''';

  /// Evita que el reproductor web abra su propio pantalla completa
  /// nativo (el que se veía estirado) y ajusta el video sin recortar.
  static const String fitVideo = '''
    (function () {
      function noop() { return Promise.resolve(); }
      Element.prototype.requestFullscreen = noop;
      Element.prototype.webkitRequestFullscreen = noop;
      Element.prototype.webkitRequestFullScreen = noop;
      HTMLVideoElement.prototype.webkitEnterFullscreen = noop;
      HTMLVideoElement.prototype.webkitEnterFullScreen = noop;

      document.documentElement.style.background = '#000';
      document.body.style.background = '#000';
      document.body.style.margin = '0';
      document.body.style.overflow = 'hidden';

      document.querySelectorAll('video').forEach(function (v) {
        v.style.objectFit = 'contain';
        v.style.background = '#000';
        v.setAttribute('playsinline', '');
        if (v.paused) {
          v.muted = false;
          var p = v.play();
          if (p && p.catch) { p.catch(function () { v.muted = true; v.play(); }); }
        }
      });
    })();
  ''';

  /// Da play al video (con sonido; si el navegador lo bloquea, en mute)
  /// y, si sigue sin sonar, toca los botones de play más comunes.
  static const String play = '''
    (function () {
      var videos = document.querySelectorAll('video');
      videos.forEach(function (v) {
        v.setAttribute('playsinline', '');
        if (v.paused) {
          v.muted = false;
          var p = v.play();
          if (p && p.catch) {
            p.catch(function () { v.muted = true; v.play(); });
          }
        }
      });

      var playing = Array.prototype.some.call(videos, function (v) {
        return !v.paused;
      });
      if (!playing) {
        [
          '.vjs-big-play-button',
          '.jw-icon-display',
          '.plyr__control--overlaid',
          '.ytp-large-play-button',
          '.mejs__overlay-button',
          '[aria-label="Play"]',
          '[aria-label="Reproducir"]',
          '.play-button',
          '.btn-play',
          '#play'
        ].forEach(function (s) {
          var el = document.querySelector(s);
          if (el) el.click();
        });
      }
    })();
  ''';

  static const String pause =
      "document.querySelectorAll('video').forEach(function(v){ v.pause(); });";
}