const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendPaymentNotification = functions.firestore
  .document('penyewaan/{bookingId}')
  .onUpdate((change, context) => {
    const newValue = change.after.data();
    const previousValue = change.before.data();

    // Hanya kirim notifikasi jika status berubah menjadi 'Pembayaran sedang Divalidasi'
    if (newValue.status === 'Pembayaran sedang Divalidasi' && previousValue.status !== 'Pembayaran sedang Divalidasi') {
      const payload = {
        notification: {
          title: 'Pembayaran Diproses',
          body: 'Pembayaran Anda sedang divalidasi. Mohon untuk menunggu.',
        },
      };

      // Ganti 'user_id' dengan field ID pengguna yang sebenarnya
      const userId = newValue.user_id;

      // Dapatkan token perangkat pengguna
      return admin.firestore().collection('users').doc(userId).get().then(userDoc => {
        const token = userDoc.data().token;
        return admin.messaging().sendToDevice(token, payload);
      }).catch(error => {
        console.error("Error sending notification: ", error);
      });
    }
    return null;
  });
