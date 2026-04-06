const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendFeedingNotification = functions.database
  .ref("/feedingSchedules/{uid}/{scheduleId}/status")
  .onUpdate(async (change, context) => {

    const before = change.before.val();
    const after = change.after.val();

    // 🔥 Trigger ONLY when status becomes "done"
    if (before === "done" || after !== "done") {
      return null;
    }

    const uid = context.params.uid;

    try {
      // 🔑 Get user FCM token
      const snapshot = await admin.database().ref(`/users/${uid}/fcmToken`).once("value");
      const token = snapshot.val();

      if (!token) {
        console.log("No token found");
        return null;
      }

      // 📩 Notification payload
      const payload = {
        notification: {
          title: "Feeding Done 🐶",
          body: "Your pet has been fed!",
        }
      };

      // 🚀 Send notification
      await admin.messaging().sendToDevice(token, payload);

      console.log("Notification sent!");

    } catch (error) {
      console.error("Error sending notification:", error);
    }

    return null;
  });