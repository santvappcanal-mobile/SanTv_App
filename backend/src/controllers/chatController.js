const asyncHandler = require('express-async-handler');
const Groq = require('groq-sdk');
const Content = require('../models/Content');
const Ad = require('../models/Ad');

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

// @desc    Conversar con el asistente virtual de SAN TV
// @route   POST /api/chat
// @access  Public
const chatearConAsistente = asyncHandler(async (req, res) => {
  const { mensaje } = req.body;

  if (!mensaje || !mensaje.trim()) {
    res.status(400);
    throw new Error('Debes enviar un mensaje válido.');
  }

  // 1. Catálogo de contenido publicado (para ayudar a encontrar noticias, deportes, videos)
  const contenidos = await Content.find({ isPublished: true }, 'title type category description views')
    .sort({ createdAt: -1 })
    .limit(30)
    .lean();

  const catalogoTexto = contenidos.length
    ? contenidos
        .map(
          (c) =>
            `- [${c.type}${c.category ? ' / ' + c.category : ''}] ${c.title}${
              c.description ? ': ' + c.description : ''
            }`
        )
        .join('\n')
    : 'No hay contenido publicado por el momento.';

  // 2. Video/contenido más visto de la semana
  //    (aproximación: lo más visto entre lo publicado en los últimos 7 días;
  //    si no hay nada nuevo esa semana, se usa el más visto en general)
  const haceUnaSemana = new Date();
  haceUnaSemana.setDate(haceUnaSemana.getDate() - 7);

  let masVistoSemana = await Content.findOne({
    isPublished: true,
    createdAt: { $gte: haceUnaSemana },
  })
    .sort({ views: -1 })
    .select('title type category views')
    .lean();

  if (!masVistoSemana) {
    masVistoSemana = await Content.findOne({ isPublished: true })
      .sort({ views: -1 })
      .select('title type category views')
      .lean();
  }

  const masVistoTexto = masVistoSemana
    ? `"${masVistoSemana.title}" (${masVistoSemana.type}) con ${masVistoSemana.views || 0} vistas`
    : 'Aún no hay datos de vistas disponibles.';

  // 3. Publicidad: espacios (placements) activos en este momento
  const ahora = new Date();
  const anunciosActivos = await Ad.find({
    isActive: true,
    startDate: { $lte: ahora },
    endDate: { $gte: ahora },
  })
    .select('placement')
    .lean();

  const placementsDisponibles = [...new Set(anunciosActivos.map((a) => a.placement))];
  const publicidadTexto = placementsDisponibles.length
    ? `Espacios publicitarios actualmente en uso: ${placementsDisponibles.join(', ')}.`
    : 'Actualmente no hay anuncios activos; los espacios publicitarios están disponibles.';

  // 4. Prompt de comportamiento del asistente
  const systemPrompt = `
Eres el asistente virtual oficial de SAN TV, un canal de televisión con app de streaming (noticias, deportes, videos y contenido en vivo). Eres cordial, claro y profesional, con un tono cercano.

CONTENIDO PUBLICADO EN LA APP (últimos agregados):
${catalogoTexto}

VIDEO/CONTENIDO MÁS VISTO DE LA SEMANA:
${masVistoTexto}

INFORMACIÓN DE PUBLICIDAD:
${publicidadTexto}
Nota: SAN TV maneja espacios publicitarios en distintos lugares de la app (pre-video, banners, en vivo, etc). NUNCA inventes precios ni cifras exactas de costos: para cotizaciones, indica amablemente que un asesor comercial del canal debe confirmar la tarifa vigente.

SERVICIOS DEL CANAL:
SAN TV ofrece: transmisión de noticias, cobertura deportiva, transmisiones en vivo de eventos, contenido de video bajo demanda, y espacios publicitarios para marcas y anunciantes.

PAUTAS DE ATENCIÓN:
1. SALUDOS INICIALES: si el usuario solo saluda, responde con calidez y pregunta en qué puedes ayudar, sin soltar toda la información de golpe.
2. BÚSQUEDA DE CONTENIDO: si preguntan por noticias, deportes o videos, ayúdales a encontrar algo del catálogo de arriba según su interés.
3. VIDEO MÁS VISTO: si preguntan cuál es el contenido más visto de la semana, responde con el dato de arriba.
4. PUBLICIDAD Y COSTOS: si preguntan sobre publicidad o cuánto cuesta anunciarse, explica en términos generales los espacios disponibles, pero deja claro que el valor exacto lo confirma el equipo comercial (no inventes precios).
5. SERVICIOS DEL CANAL: si preguntan qué servicios ofrece SAN TV, resume la lista de servicios de arriba.
6. Si preguntan algo fuera de estos temas, responde con amabilidad indicando que por ahora solo puedes ayudar con contenido, publicidad y servicios del canal.
7. Sé conciso y no inventes datos que no tengas (precios exactos, cifras que no te di).
`;

  const completion = await groq.chat.completions.create({
    model: 'openai/gpt-oss-20b',
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: mensaje },
    ],
    temperature: 0.3,
    max_tokens: 500,
  });

  const respuestaTexto = completion.choices[0]?.message?.content || 'No pude generar una respuesta.';

  res.status(200).json({ success: true, respuesta: respuestaTexto });
});

module.exports = { chatearConAsistente };