var mongoose     = require('mongoose');
var Schema       = mongoose.Schema;

var NotificationSchema   = new Schema({
    from_id: String,
    to_id: String,
    date: Date,
    type: String,
    text: String,
    status: String,
    is_read: Boolean,
    push_sent: Date,
    hash: String
});

module.exports = mongoose.model('Notification', NotificationSchema);