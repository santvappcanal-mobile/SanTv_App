/**
 * Extrae el ID de un video de YouTube a partir de cualquier formato común de URL:
 *   https://www.youtube.com/watch?v=VIDEO_ID
 *   https://youtu.be/VIDEO_ID
 *   https://www.youtube.com/embed/VIDEO_ID
 *   https://www.youtube.com/shorts/VIDEO_ID
 * Devuelve el ID (string) o null si no lo pudo extraer.
 */
const extractYoutubeId = (url) => {
  if (!url) return null;

  const patterns = [
    /(?:youtube\.com\/watch\?v=)([a-zA-Z0-9_-]{11})/,
    /(?:youtu\.be\/)([a-zA-Z0-9_-]{11})/,
    /(?:youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})/,
    /(?:youtube\.com\/shorts\/)([a-zA-Z0-9_-]{11})/,
  ];

  for (const pattern of patterns) {
    const match = url.match(pattern);
    if (match) return match[1];
  }

  return null;
};

/**
 * Construye la URL de thumbnail de alta calidad para un video de YouTube.
 * No requiere API key, es un recurso estático público.
 */
const getYoutubeThumbnail = (videoId, quality = 'hqdefault') => {
  // Calidades disponibles: default, mqdefault, hqdefault, sddefault, maxresdefault
  return `https://img.youtube.com/vi/${videoId}/${quality}.jpg`;
};

/**
 * Construye la URL de embed, útil para reproducir el video dentro de un iframe/webview.
 */
const getYoutubeEmbedUrl = (videoId) => {
  return `https://www.youtube.com/embed/${videoId}`;
};

module.exports = { extractYoutubeId, getYoutubeThumbnail, getYoutubeEmbedUrl };
