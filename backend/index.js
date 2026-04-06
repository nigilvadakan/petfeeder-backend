const admin = require("firebase-admin");

// 🔐 Load Firebase key from Render ENV
const serviceAccount = JSON.parse(process.env.FIREBASE_KEY);

// ✅ Initialize Firebase
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://petfeeder-506cf-default-rtdb.asia-southeast1.firebasedatabase.app"
});

const db = admin.database();

// 🔥 START LISTENER
console.log("🚀 Backend started... Listening for schedule changes...");

const scheduleRef = db.ref("feedingSchedules");

// 👇 Listen only changes (efficient)
scheduleRef.on("child_changed", async (snapshot) => {

  console.log("🔥 Change detected");

  const uid = snapshot.key;
  const userSchedules = snapshot.val();

  for (const scheduleId in userSchedules) {

    const schedule = userSchedules[scheduleId];

    console.log("Checking:", scheduleId, schedule.status);

    // ✅ TRIGGER ONLY ONCE
    if (schedule.status === "done" && schedule.notified !== true) {

      console.log("🚀 Trigger:", scheduleId);

      const tokenSnap = await db.ref(`users/${uid}/fcmToken`).once("value");
      const token = tokenSnap.val();

      if (!token) {
        console.log("❌ No token found");
        continue;
      }

      try {
        // 🔔 SEND NOTIFICATION
        await admin.messaging().send({
          token: token,
          notification: {
            title: "Feeding Complete 🐶",
            body: `Fed at ${schedule.time || "scheduled time"}`
          }
        });

        console.log("✅ Notification sent:", scheduleId);

        // 🔥 MARK AS NOTIFIED
        await db.ref(`feedingSchedules/${uid}/${scheduleId}`).update({
          notified: true
        });

      } catch (error) {
        console.error("❌ FCM Error:", error);
      }
    }
  }
});