// Script de UNA SOLA VEZ: recalcula el contador "views" de cada video a partir
// del historial por usuario (WatchHistory), para quitar las vistas repetidas.
//
// Uso (desde la carpeta backend):
//   node scripts/recalcularVistas.js
//
// Regla: views = cantidad de usuarios distintos que han visto el video.
// Los videos sin historial quedan en 0.

require('dotenv').config();
const mongoose = require('mongoose');
const connectDB = require('../src/config/db');
const Content = require('../src/models/Content');
const WatchHistory = require('../src/models/WatchHistory');

const run = async () => {
  await connectDB();

  // Usuarios distintos por video (WatchHistory tiene un registro por usuario+video)
  const conteos = await WatchHistory.aggregate([
    { $group: { _id: '$content', total: { $sum: 1 } } },
  ]);

  // 1) Todos a 0 (sin tocar updatedAt)
  const reset = await Content.updateMany({}, { $set: { views: 0 } }, { timestamps: false });

  // 2) Asignar el conteo real a los que tienen historial
  if (conteos.length) {
    await Content.bulkWrite(
      conteos.map((c) => ({
        updateOne: {
          filter: { _id: c._id },
          update: { $set: { views: c.total } },
        },
      })),
      { timestamps: false }
    );
  }

  console.log(`✅ Videos reiniciados a 0: ${reset.modifiedCount}`);
  console.log(`✅ Videos con vistas recalculadas: ${conteos.length}`);
  conteos.forEach((c) => console.log(`   ${c._id} -> ${c.total}`));

  await mongoose.disconnect();
  process.exit(0);
};

run().catch(async (err) => {
  console.error('❌ Error recalculando vistas:', err);
  await mongoose.disconnect();
  process.exit(1);
});