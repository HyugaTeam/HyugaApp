require('dotenv').config();
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

const sgMail = require("@sendgrid/mail");
const SG_API_KEY = process.env.SG_API_KEY;
const SG_TEMPLATE_ADMIN_NEW_RESERVATION = process.env.SG_TEMPLATE_ADMIN_NEW_RESERVATION;
const SG_TEMPLATE_USER_NEW_RESERVATION = process.env.SG_TEMPLATE_USER_NEW_RESERVATION;
sgMail.setApiKey(SG_API_KEY);

const accountSid = process.env.TW_ACCOUNT_SID; 
const authToken = process.env.TW_AUTH_TOKEN; 
const twilio = require('twilio')(accountSid, authToken); 

// admin.auth()
// .listUsers()
// .then((result) => {
//   // return console.log(result.users);
//   return result.users.forEach(element => {
//     if(element.providerData.length === 0){
//       console.log(element.uid);
//       return admin.auth().deleteUser(element.uid)
//       .then(() =>{
//           return console.log("STERS");
//       })
//       .catch((error) => {
//         return console.log("EROARE LA STERGERE");
//       });
//     }
//   });
// })
// .catch((error) => {
//   return console.log('Error fetching user data:', error);
// });

/// Issued whenever a new RESERVATION is made by an user
/// Sends a push-notification to the restaurant-owner, and a confirmation email to the user
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
        const utc_offset = time.getTimezoneOffset()
        const hourOffset = 3
        var hoursAndMinutes = ""
        if(time.getHours()+hourOffset<10)
          hoursAndMinutes += "0" + (time.getHours()+hourOffset).toString()
        else
          hoursAndMinutes += (time.getHours()+hourOffset).toString()
        if(time.getMinutes().toString() === "0")
          hoursAndMinutes += ":" + "00"
        else
          hoursAndMinutes += ":" + time.getMinutes().toString()
        const months = {
          0 : "Ianuarie", 1: "Februarie", 2: "Martie", 3: "Aprilie", 4:"Mai", 5:"Iunie", 6:"Iulie", 7:"August", 8:"Septembrie", 9:"Octombrie", 10:"Noiembrie", 11:"Decembrie"
        }

        const userDoc = await db.collection('users').doc(data['guest_id']).get();
        userEmail = [userDoc.data()['email']]
        const placeDoc = await docSnapshot.ref.parent.parent.get();
        const placeName = placeDoc.data()['name'];
        const date = time.getDate() + ' ' + months[time.getMonth()]
        const numberOfGuests = data['number_of_guests']

        const msg = {
            to: userEmail,
            from: 'support@winestreet.ro',
            templateId: SG_TEMPLATE_USER_NEW_RESERVATION,
            dynamic_template_data: {
              placeName: placeName,
              date: date,
              time: hoursAndMinutes,
              numberOfPeople: numberOfGuests
            }
        };

        //const options = {hours: "long",minutes:"long"};
        //const hour = Intl.DateTimeFormat('ro',options)
        const payload = {
              notification: {
                title: 'Rezervare nouă!',
                //body: "O noua rezervare a fost facuta la data " + time.getDate() +' '+ months[time.getMonth()]+ ' '+(time.getYear()+1900)+', ora '+(time.getHours()+hourOffset)+':'+time.getMinutes(),
                body: "O nouă rezervare a fost facută la data " + time.getDate() +' '+ months[time.getMonth()]+ ' '+(time.getYear()+1900)+', ora '+ hoursAndMinutes,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK'
              }
            }
        return Promise.all([fcm.sendToDevice(registrationTokens,payload), sgMail.send(msg)]);
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
      const utc_offset = time.getTimezoneOffset()
      const hourOffset = 3
      var hoursAndMinutes = ""
      if(time.getHours()+hourOffset<10)
        hoursAndMinutes += "0" + (time.getHours()+hourOffset).toString()
      else
        hoursAndMinutes += (time.getHours()+hourOffset).toString()
      if(time.getMinutes().toString() === "0")
        hoursAndMinutes += ":" + "00"
      else
        hoursAndMinutes += ":" + time.getMinutes().toString()

      const months = {
        0 : "Ianuarie", 1: "Februarie", 2: "Martie", 3: "Aprilie", 4:"Mai", 5:"Iunie", 6:"Iulie", 7:"August", 8:"Septembrie", 9:"Octombrie", 10:"Noiembrie", 11:"Decembrie"
      }
      if(dataBefore['accepted'] === null && dataAfter['accepted'] === true){
        const payload = {
              notification: {
                title: 'Rezervare acceptată',
                //body: 'Rezervarea dumneavoastra la ' + placeName +' pentru data '+ time.getDate() +' '+ months[time.getMonth()]+ ' '+(time.getYear()+1900)+', ora '+time.getHours()+':'+time.getMinutes() +' a fost acceptata!',
                body: 'Rezervarea dumneavoastră la ' + placeName +' pentru data '+ time.getDate() +' '+ months[time.getMonth()]+ ' '+(time.getYear()+1900)+', ora '+hoursAndMinutes + " a fost acceptată!",
                clickAction: 'FLUTTER_NOTIFICATION_CLICK'
              }
            }
        return fcm.sendToDevice(registrationTokens,payload);
      }
      else if(dataBefore['accepted'] === null && dataAfter['accepted'] === false){
        const payload = {
          notification: {
            title: 'Rezervare refuzată',
            //body: 'Rezervarea dumneavoastra la ' + placeName +' pentru data '+ time.getDate() +' '+ months[time.getMonth()]+ ' '+(time.getYear()+1900)+', ora '+time.getHours()+':'+time.getMinutes() +' a fost refuzata!',
            body: 'Rezervarea dumneavoastră la ' + placeName +' pentru data '+ time.getDate() +' '+ months[time.getMonth()]+ ' '+(time.getYear()+1900)+', ora '+hoursAndMinutes +' a fost refuzată!',
            clickAction: 'FLUTTER_NOTIFICATION_CLICK'
          }
        }
        return fcm.sendToDevice(registrationTokens,payload);
      }
  }
)

exports.sendReservationNotificationToAdmin = functions.firestore
    .document('users/{user}/managed_locals/{managed_local}/reservations/{reservation}')
    .onCreate(async (docSnapshot,context) => {

        /// ------- Send Push Notification to Admins ------

        const data = docSnapshot.data()
        const guestName = data['guest_name']
        const guestId = data['guest_id']
        const placeDoc = await docSnapshot.ref.parent.parent.get();
        const placeName = placeDoc.data()['name'];
        //const reservationTime = data['date_start']

        const userTokens = await docSnapshot.ref.parent.parent.parent.parent
        .collection('tokens').get();
        
        // const querySnapshot = await db.collection('users').doc(data['guest_id'])
        // .collection('tokens').get();
        const adminUser = await db.collection('users').where("admin", "==", true).limit(2).get()
        const firstAdminTokens = await db.collection('users').doc(adminUser.docs[0].id).collection('tokens').get()
        const secondAdminTokens = await db.collection('users').doc(adminUser.docs[1].id).collection('tokens').get()
        // const registrationTokens = querySnapshot.docs.map(ss => ss.id);
        var registrationTokens = firstAdminTokens.docs.map(ss => ss.id)
        registrationTokens = registrationTokens.concat(secondAdminTokens.docs.map(ss => ss.id))

        const time = data['date_start'].toDate()
        const utc_offset = time.getTimezoneOffset() 
        const hourOffset = 3
        var hoursAndMinutes = ""
        if(time.getHours()+hourOffset<10)
          hoursAndMinutes += "0" + (time.getHours()+hourOffset).toString()
        else
          hoursAndMinutes += (time.getHours()+hourOffset).toString()
        if(time.getMinutes().toString() === "0")
          hoursAndMinutes += ":" + "00"
        else
          hoursAndMinutes += ":" + time.getMinutes().toString()
        const months = {
          0 : "Ianuarie", 1: "Februarie", 2: "Martie", 3: "Aprilie", 4:"Mai", 5:"Iunie", 6:"Iulie", 7:"August", 8:"Septembrie", 9:"Octombrie", 10:"Noiembrie", 11:"Decembrie"
        }
        
        //const options = {hours: "long",minutes:"long"};
        //const hour = Intl.DateTimeFormat('ro',options)
        const payload = {
              notification: {
                title: 'Rezervare nouă!',
                //body: "O noua rezervare a fost facuta la data " + time.getDate() +' '+ months[time.getMonth()]+ ' '+(time.getYear()+1900)+', ora '+(time.getHours()+hourOffset)+':'+time.getMinutes(),
                body: "O nouă rezervare a fost facută la data " + time.getDate() +' '+ months[time.getMonth()]+ ' '+(time.getYear()+1900)+', ora '+ hoursAndMinutes + ' de către '+ guestId + ' la restaurantul '+ placeName,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK'
              }
            }
        /// ------- Send Email to Admins ------
        adminEmailList = ['florian.marcu23@gmail.com','vladcamarasoiu@yahoo.com', 'tudoristea@yahoo.com']
        const msg = {
            to: adminEmailList,
            from: 'support@winestreet.ro',
            templateId: SG_TEMPLATE_ADMIN_NEW_RESERVATION,
            dynamic_template_data: {
              username: guestName,
              userId: guestId,
              placeName: placeName
            }
        };

        // twilio.messages 
        //   .create({   
        //     body: "Utilizatorul " + guestName + " a făcut o nouă rezervare la data " + time.getDate() +' '+ months[time.getMonth()]+ ' '+(time.getYear()+1900)+', ora '+ hoursAndMinutes + '.\n Id-ul utilizatorului este: '+ guestId,
        //     messagingServiceSid: 'MGd5437295ba97ff80dc718005ee1023a9',      
        //     to: '+40742010086' 
        //   }).done();
        twilio.messages 
          .create({   
            body: "Utilizatorul " + guestName + " a făcut o nouă rezervare la data " + time.getDate() +' '+ months[time.getMonth()]+ ' '+(time.getYear()+1900)+', ora '+ hoursAndMinutes + ' la restaurantul '+ placeName + '.\n Id-ul utilizatorului este: '+ guestId,
            messagingServiceSid: 'MGd5437295ba97ff80dc718005ee1023a9',      
            to: '+40749532815' 
          }).done();
        // twilio.messages 
        //   .create({   
        //     body: "Utilizatorul " + guestName + " a făcut o nouă rezervare la data " + time.getDate() +' '+ months[time.getMonth()]+ ' '+(time.getYear()+1900)+', ora '+ hoursAndMinutes+ ' la restaurantul '+ placeName + '.\n Id-ul utilizatorului este: '+ guestId,
        //     messagingServiceSid: 'MGd5437295ba97ff80dc718005ee1023a9',      
        //     to: '+40771362306' 
        //   }).done();
        
        return Promise.all([fcm.sendToDevice(registrationTokens,payload), sgMail.send(msg)]);

    })
