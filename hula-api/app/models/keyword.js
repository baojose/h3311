var mongoose     = require('mongoose');
var Schema       = mongoose.Schema;

var KeywordSchema   = new Schema({
    keyword: String,
    date: Date,
    user_id: String,
    relevance: Number,
});

module.exports = mongoose.model('Keyword', KeywordSchema);