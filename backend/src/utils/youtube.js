const asyncHandler = require('express-async-handler');

/**
 * Extrae el ID de un video de YouTube a partir de distintos formatos de link:
 * - https://www.youtube.com/watch?v=VIDEO_ID
 * - https://youtu.be/VIDEO_ID
 * - https://www.youtube.com/embed/VIDEO_ID
 * - https://www.youtube.com/shorts/VIDEO_ID
 */
function extractYoutubeId(url) {
  if (!url) return null;
  const regex = /(?:youtube\.com\/(?:[^/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?/\s]{11})/;
  const match = url.match(regex);
  return match ? match[1] : null;
}

/**
 * Devuelve la URL del thumbnail de un video de YouTube.
 * quality: default | mqdefault | hqdefault | sddefault | maxresdefault
 */
function getYoutubeThumbnail(videoId, quality = 'hqdefault') {
  if (!videoId) return null;
  return `https://img.youtube.com/vi/${videoId}/${quality}.jpg`;
}

// @desc    Obtener título, autor y thumbnail de un video de YouTube a partir del link
// @route   GET /api/content/youtube-preview?url=...
// @access  Private/Editor+
const getYoutubePreview = asyncHandler(async (req, res) => {
  const { url } = req.query;

  if (!url) {
    res.status(400);
    throw new Error('Debes enviar el parámetro "url" con el link de YouTube');
  }

  const videoId = extractYoutubeId(url);
  if (!videoId) {
    res.status(400);
    throw new Error('No se pudo reconocer un link válido de YouTube');
  }

  const oembedUrl = `https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=${videoId}&format=json`;

  let response;
  try {
    response = await fetch(oembedUrl);
  } catch (error) {
    res.status(502);
    throw new Error('No se pudo conectar con YouTube. Verifica la conexión del servidor.');
  }

  if (!response.ok) {
    res.status(404);
    throw new Error('No se encontró información para ese video (¿el link es correcto y es público?)');
  }

  const oembedData = await response.json();

  res.json({
    success: true,
    data: {
      videoId,
      title: oembedData.title,
      channelName: oembedData.author_name,
      thumbnailUrl: getYoutubeThumbnail(videoId, 'maxresdefault'),
      embedUrl: `https://www.youtube.com/embed/${videoId}`,
      originalUrl: url,
    },
  });
});

module.exports = { extractYoutubeId, getYoutubeThumbnail, getYoutubePreview };