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

  /// Oculta TODOS los controles del reproductor web (pausa, volumen,
  /// barra de controles, controles nativos del <video>). La app usa sus
  /// propios botones de Flutter, que comparten estado entre el Home y la
  /// pestaña En vivo. Nunca oculta un elemento que contenga el <video>.
  /// Los elementos ocultos siguen aceptando `.click()` por código, así que
  /// el arranque automático no se ve afectado. Es idempotente y se vuelve
  /// a aplicar en los reintentos por si la página los crea tarde.
  static const String hideWebControls = '''
    (function () {
      var sel = 'button, [role="button"], [class*="control" i],' +
        '[class*="volume" i], [class*="mute" i], [class*="btn" i]';
      try {
        document.querySelectorAll(sel).forEach(function (el) {
          if (el.tagName === 'VIDEO' || el.querySelector('video')) return;
          el.style.setProperty('display', 'none', 'important');
        });
      } catch (e) {}
      if (!document.getElementById('santv-hide-controls')) {
        var st = document.createElement('style');
        st.id = 'santv-hide-controls';
        st.textContent =
          'video::-webkit-media-controls,' +
          'video::-webkit-media-controls-enclosure,' +
          'video::-webkit-media-controls-panel' +
          '{ display: none !important; -webkit-appearance: none; }';
        (document.head || document.documentElement).appendChild(st);
      }
      document.querySelectorAll('video').forEach(function (v) {
        v.controls = false;
        v.removeAttribute('controls');
      });
    })();
  ''';

  /// Evita que el reproductor web abra su propio pantalla completa
  /// nativo (el que se veía estirado) y ajusta el video sin recortar.
  ///
  /// Solo da play mientras el video NO haya arrancado todavía
  /// (`window.__santvPlayed`); así, si el usuario lo pausa con el botón
  /// del reproductor, los reintentos no lo vuelven a reproducir.
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

        if (!v.__santvListener) {
          v.__santvListener = true;
          v.addEventListener('playing', function () {
            window.__santvPlayed = true;
          });
        }
        if (!v.paused) { window.__santvPlayed = true; }

        if (v.paused && !window.__santvPlayed) {
          v.muted = false;
          var p = v.play();
          if (p && p.catch) { p.catch(function () { v.muted = true; v.play(); }); }
        }
      });
    })();
  ''';

  /// Cuerpo común de [play] y [autoplay].
  ///
  /// - Si el video ya está sonando, solo marca `window.__santvPlayed`.
  /// - Si `force` es false y el video ya arrancó una vez, no hace nada:
  ///   así el botón de pausa del reproductor web funciona y los
  ///   reintentos no lo vuelven a reproducir.
  /// - Si `force` es true, reinicia esa marca y da play igual.
  static const String _playBody = '''
    if (force) { window.__santvPlayed = false; }

    var videos = document.querySelectorAll('video');

    videos.forEach(function (v) {
      if (v.__santvListener) return;
      v.__santvListener = true;
      v.addEventListener('playing', function () {
        window.__santvPlayed = true;
      });
    });

    var already = Array.prototype.some.call(videos, function (v) {
      return !v.paused;
    });
    if (already) { window.__santvPlayed = true; return; }
    if (window.__santvPlayed) { return; }

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
        '[class*="big-play" i]',
        '[class*="play-button" i]',
        '[class*="playbutton" i]',
        '.play-button',
        '.btn-play',
        '#play'
      ].forEach(function (s) {
        var el = document.querySelector(s);
        if (el) el.click();
      });
    }
  ''';

  /// Da play de forma FORZADA (con sonido; si el navegador lo bloquea,
  /// en mute). Se usa al volver a una pestaña o pantalla.
  static const String play = '(function (force) {$_playBody})(true);';

  /// Da play solo si el video todavía no arrancó. Es el que se usa en
  /// los reintentos tras cargar la página.
  static const String autoplay = '(function (force) {$_playBody})(false);';

  static const String pause =
      "document.querySelectorAll('video').forEach(function(v){ v.pause(); });";
}