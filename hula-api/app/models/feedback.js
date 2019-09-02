var mongoose     = require('mongoose');
var Schema       = mongoose.Schema;

var FeedbackSchema   = new Schema({
    trade_id: String,
    user_id: String,
    giver_id: String,
    date: Date,
    comments: String,
    val: Number,
    status: String
});

module.exports = mongoose.model('Feedback', FeedbackSchema);