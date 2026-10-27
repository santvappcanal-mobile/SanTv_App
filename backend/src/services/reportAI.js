const Groq = require('groq-sdk');

const MODEL = 'openai/gpt-oss-20b'; // el mismo que usa tu chatController
const CATEGORIES = ['Noticias', 'Deportes', 'Educación', 'Comunidad'];

let client = null;
function getClient() {
  if (!client && process.env.GROQ_API_KEY) {
    client = new Groq({ apiKey: process.env.GROQ_API_KEY });
  }
  return client;
}

function extractJson(text) {
  if (!text) return null;
  const clean = text.replace(/```json|```/g, '').trim();
  const start = clean.indexOf('{');
  const end = clean.lastIndexOf('}');
  if (start === -1 || end === -1) return null;
  try {
    return JSON.parse(clean.slice(start, end + 1));
  } catch (_) {
    return null;
  }
}

/**
 * Analiza el TEXTO del reporte (título, descripción, ubicación).
 * No interpreta la imagen. Si falla, devuelve { analyzed: false } y el
 * reporte sigue su camino normal hacia la cola del admin.
 */
async function analyzeReport({ title, description, category, address, nearbyReports }) {
  const groq = getClient();
  if (!groq) return { analyzed: false };

  const system =
    'Eres el editor asistente de un canal de televisión local colombiano (SAN TV). ' +
    'Recibes un reporte enviado por un ciudadano y ayudas al editor a revisarlo. ' +
    'Responde SOLO con un objeto JSON válido, sin texto adicional ni markdown, con estas claves: ' +
    '"suggestedTitle" (título periodístico claro, máx. 90 caracteres), ' +
    '"summary" (resumen neutral de 1 a 2 frases), ' +
    `"suggestedCategory" (una de: ${CATEGORIES.join(', ')}), ` +
    '"suspicionScore" (entero 0-100: qué tan probable es que sea un bulo, spam, ' +
    'broma o contenido sin sustento; 0 = creíble), ' +
    '"suspicionReason" (una frase breve que justifique el puntaje). ' +
    'No inventes hechos que no estén en el reporte.';

  const user = JSON.stringify({
    titulo: title,
    descripcion: description,
    categoriaElegida: category,
    ubicacion: address || 'sin dirección',
    reportesCercanosUltimas24h: nearbyReports || 0,
  });

  try {
    const completion = await groq.chat.completions.create({
      model: MODEL,
      temperature: 0.2,
      max_tokens: 500,
      messages: [
        { role: 'system', content: system },
        { role: 'user', content: user },
      ],
    });

    const data = extractJson(completion.choices?.[0]?.message?.content);
    if (!data) return { analyzed: false };

    const score = Math.max(0, Math.min(100, parseInt(data.suspicionScore, 10) || 0));
    return {
      analyzed: true,
      suggestedTitle: String(data.suggestedTitle || '').slice(0, 120),
      summary: String(data.summary || '').slice(0, 500),
      suggestedCategory: CATEGORIES.includes(data.suggestedCategory)
        ? data.suggestedCategory
        : category,
      suspicionScore: score,
      suspicionReason: String(data.suspicionReason || '').slice(0, 300),
    };
  } catch (err) {
    console.error('reportAI error:', err.message);
    return { analyzed: false };
  }
}

module.exports = { analyzeReport };
