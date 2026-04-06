const admin = require("firebase-admin");

// 🔐 Safe loading for Render (prevents crash if ENV missing)
let serviceAccount;

try {
  serviceAccount = JSON.parse(process.env.FIREBASE_KEY);
} catch (e) {
  console.error("❌ FIREBASE_KEY missing or invalid");
  process.exit(1);
}

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

  if (!userSchedules) return; // ✅ safety (no crash)

  for (const scheduleId in userSchedules) {

    const schedule = userSchedules[scheduleId];

    if (!schedule) continue; // ✅ safety

    console.log("Checking:", scheduleId, schedule.status);

    // ✅ TRIGGER ONLY ONCE (YOUR LOGIC UNCHANGED)
    if (schedule.status === "done" && schedule.notified !== true) {

      console.log("🚀 Trigger:", scheduleId);

      try {
        const tokenSnap = await db.ref(`users/${uid}/fcmToken`).once("value");
        const token = tokenSnap.val();

        if (!token) {
          console.log("❌ No token found");
          continue;
        }

        // 🔔 SEND NOTIFICATION
        await admin.messaging().send({
          token: token,
          notification: {
            title: "Feeding Complete 🐶",
            body: `Fed at ${schedule.time || "scheduled time"}`
          }
        });

        console.log("✅ Notification sent:", scheduleId);

        // 🔥 MARK AS NOTIFIED (YOUR LOGIC)
        await db.ref(`feedingSchedules/${uid}/${scheduleId}`).update({
          notified: true
        });

      } catch (error) {
        console.error("❌ FCM Error:", error);
      }
    }
  }
});

// ❗ Keep process alive (important for Render free tier)
setInterval(() => {}, 1000);
// 🔥 DUMMY SERVER FOR RENDER (IMPORTANT)
const express = require("express");
const app = express();

const PORT = process.env.PORT || 3000;

app.get("/", (req, res) => {
  res.send("PetFeeder Backend Running 🚀");
});

app.listen(PORT, () => {
  console.log(`🌐 Server running on port ${PORT}`);
});