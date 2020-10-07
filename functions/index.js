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

        const querySnapshot = await docSnapshot.ref.parent.parent.parent.parent
        .collection('tokens').get();

        // const querySnapshot = await db.collection('users').doc(data['guest_id'])
        // .collection('tokens').get();
          
        const registrationTokens = querySnapshot.docs.map(ss => ss.id);

        const time = data['date_start'].toDate()
        const months = {
          0 : "Ianuarie", 1: "Februarie", 2: "Martie", 3: "Aprilie", 4:"Mai", 5:"Iunie", 6:"Iulie", 7:"August", 8:"Septembrie", 9:"Octombrie", 10:"Noiembrie", 11:"Decembrie"
        }
        
        //const options = {hours: "long",minutes:"long"};
        //const hour = Intl.DateTimeFormat('ro',options)
        const payload = {
              notification: {
                title: 'Rezervare noua!',
                body: "O noua rezervare a fost facuta la data " + time.getDate() +' '+ months[time.getMonth()]+ ' '+(time.getYear()+1900)+', ora '+time.getHours()+':'+time.getMinutes(),
                clickAction: 'FLUTTER_NOTIFICATION_CLICK'
              }
            }
        return fcm.sendToDevice(registrationTokens,payload);
    })

exports.sendReservationNotificationToUser = functions.firestore
.document('users/{user}/managed_locals/{managed_local}/reservations/{reservation}')
.onUpdate(async (docSnapshot,context) => {
    const dataAfter = docSnapshot.after.data()
    const dataBefore = docSnapshot.before.data()

    const querySnapshot = await db.collection('users').doc(dataBefore['guest_id'])
    .collection('tokens').get();
    
    const placeDoc = await docSnapshot.before.ref.parent.parent.get();
    const placeName = placeDoc.data()['name'];
    
    const registrationTokens = querySnapshot.docs.map(ss => ss.id);

    const time = dataBefore['date_start'].toDate()
    const months = {
      0 : "Ianuarie", 1: "Februarie", 2: "Martie", 3: "Aprilie", 4:"Mai", 5:"Iunie", 6:"Iulie", 7:"August", 8:"Septembrie", 9:"Octombrie", 10:"Noiembrie", 11:"Decembrie"
    }
    if(dataBefore['accepted'] === null && dataAfter['accepted'] === true){
      const payload = {
            notification: {
              title: 'Rezervare acceptata',
              body: 'Rezervarea dumneavoastra la ' + placeName +' pentru data '+ time.getDate() +' '+ months[time.getMonth()]+ ' '+(time.getYear()+1900)+', ora '+time.getHours()+':'+time.getMinutes() +' a fost acceptata!',
              clickAction: 'FLUTTER_NOTIFICATION_CLICK'
            }
          }
      return fcm.sendToDevice(registrationTokens,payload);
    }
    else if(dataBefore['accepted'] === null && dataAfter['accepted'] === false){
      const payload = {
        notification: {
          title: 'Rezervare refuzata',
          body: 'Rezervarea dumneavoastra la ' + placeName +' pentru data '+ time.getDate() +' '+ months[time.getMonth()]+ ' '+(time.getYear()+1900)+', ora '+time.getHours()+':'+time.getMinutes() +' a fost refuzata!',
          clickAction: 'FLUTTER_NOTIFICATION_CLICK'
        }
      }
      return fcm.sendToDevice(registrationTokens,payload);
    }
})