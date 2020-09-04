const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

const db = admin.firestore();
const fcm = admin.messaging();

exports.sendReservationNotification = functions.firestore
    .document('users/{user}/managed_locals/{managed_local}/reservations/{reservation}')
    .onCreate(async (docSnapshot,context) => {
        const data = docSnapshot.data()
        //const reservationTime = data['date_start']

        const querySnapshot = await db.collection('users').doc(data['guest_id'])
        .collection('tokens').get();
          
        const registrationTokens = querySnapshot.docs.map(ss => ss.id);

        const payload = {
              notification: {
                title: 'O noua rezervare a fost facuta',
                body: data['guest_name'],
                clickAction: 'FLUTTER_NOTIFICATION_CLICK'
              }
            }
        return fcm.sendToDevice(registrationTokens,payload);
        //return admin.messaging().sendToDevice(registrationTokens,payload)

        // return admin.firestore().doc('users/'+ context.auth.uid).get().then(userDoc => {
        //   const querySnapshot = await db.collection('users').doc(data.guest_id)
        //   .collection('tokens').get();
          
        //   const registrationTokens = querySnapshot.docs.map(ss => ss.id);

        //   const notificationBody = (message['type'] === 'TEXT') ? message['text'] : "You received a new reservation."

        //   const payload = {
        //     notification: {
        //       title: 'O noua rezervare a fost facuta',
        //       body: notificationBody,
        //       clickAction: 'FLUTTER_NOTIFICATION_CLICK'
        //     },
        //     data:{
        //       doc_id: userDoc.uid

        //     }
        //   }

        //   return admin.messaging().sendToDevice(registrationTokens,payload)
        // })
    })

// exports.setScoreToZero = functions.https.onRequest(async (req, res) => {
//     // Grab the text parameter.
//     const original = req.query.text;
//     // Push the new message into Cloud Firestore using the Firebase Admin SDK.
//     const writeResult = await admin.firestore().collection('messages').add({original: original});
//     // Send back a message that we've succesfully written the message
//     res.json({result: `Message with ID: ${writeResult.id} added.`});
//   });
