var mongoose     = require('mongoose');
var Schema       = mongoose.Schema;

var ChatSchema   = new Schema({
    user_id: String,
    date: Date,
    message: String,
    type: String,
    status: String
});

module.exports = mongoose.model('Chat', ChatSchema);