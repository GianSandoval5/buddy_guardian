const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.resetDailyScore = functions.pubsub.schedule("0 0 * * *")
    .timeZone("America/Lima") // Ajusta la zona horaria según Perú
    .onRun(async (context) => {
      const snapshot = await admin.firestore().collection("ranking").get();

      const currentTime = admin.firestore.Timestamp.now();

      const promises = [];

      snapshot.forEach(async (doc) => {
        const data = doc.data();
        const createdAtString = data.createdAt;
        const createdAt = new Date(createdAtString);
        const differenceInDays =
        Math.floor((currentTime.toDate() - createdAt) / (24 * 60 * 60 * 1000));

        const updateData = {};

        // Reiniciar puntaje diario
        if (differenceInDays >= 1) {
          updateData.puntajeDiario = 0;
        }

        if (Object.keys(updateData).length > 0) {
          promises.push(doc.ref.update(updateData));
        }
      });

      await Promise.all(promises);

      return null;
    });

exports.resetWeeklyScore = functions.pubsub.schedule("0 0 * * 0")
    .timeZone("America/Lima") // Ajusta la zona horaria según Perú
    .onRun(async (context) => {
      const snapshot = await admin.firestore().collection("ranking").get();

      const currentTime = admin.firestore.Timestamp.now();

      const promises = [];

      snapshot.forEach(async (doc) => {
        const data = doc.data();
        const createdAtString = data.createdAt;
        const createdAt = new Date(createdAtString);
        const differenceInDays =
        Math.floor((currentTime.toDate() - createdAt) / (24 * 60 * 60 * 1000));

        const updateData = {};

        // Reiniciar puntaje semanal (los domingos)
        if (currentTime.toDate().getDay() === 0 && differenceInDays >= 0) {
          updateData.puntajeSemanal = 0;
        }

        if (Object.keys(updateData).length > 0) {
          promises.push(doc.ref.update(updateData));
        }
      });

      await Promise.all(promises);

      return null;
    });

exports.resetMonthlyScore = functions.pubsub.schedule("0 0 1 * *")
    .timeZone("America/Lima") // Ajusta la zona horaria según Perú
    .onRun(async (context) => {
      const snapshot = await admin.firestore().collection("ranking").get();

      const currentTime = admin.firestore.Timestamp.now();

      const promises = [];

      snapshot.forEach(async (doc) => {
        const data = doc.data();
        const createdAtString = data.createdAt;
        const createdAt = new Date(createdAtString);
        const differenceInDays =
        Math.floor((currentTime.toDate() - createdAt) / (24 * 60 * 60 * 1000));

        const updateData = {};

        // Reiniciar puntaje mensual (el primer día del mes)
        if (currentTime.toDate().getDate() === 1 && differenceInDays >= 0) {
          updateData.puntajeMensual = 0;
        }

        if (Object.keys(updateData).length > 0) {
          promises.push(doc.ref.update(updateData));
        }
      });

      await Promise.all(promises);

      return null;
    });
