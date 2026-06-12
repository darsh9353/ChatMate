const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendMessageNotification = functions.firestore
    .document("chats/{chatId}/messages/{messageId}")
    .onCreate(async (snapshot, context) => {
      try {
        const messageData = snapshot.data();

        const receiverId = messageData.receiverId;
        const senderName = messageData.senderName;
        const text = messageData.text;

        // Get receiver FCM token
        const userDoc = await admin
            .firestore()
            .collection("users")
            .doc(receiverId)
            .get();

        if (!userDoc.exists) {
          console.log("User not found");
          return;
        }

        const fcmToken = userDoc.data().fcmToken;

        if (!fcmToken) {
          console.log("No FCM token");
          return;
        }

        const payload = {
          token: fcmToken,
          notification: {
            title: senderName,
            body: text,
          },
          data: {
            chatId: context.params.chatId,
            senderId: messageData.senderId,
          },
        };

        await admin.messaging().send(payload);

        console.log("Notification sent successfully");
      } catch (error) {
        console.error("Error sending notification:", error);
      }
    });
