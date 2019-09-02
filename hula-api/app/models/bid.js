var mongoose     = require('mongoose');
var Schema       = mongoose.Schema;

var BidSchema   = new Schema({
    user_id: String,
    date: Date,
    owner_products: Array,
    other_products: Array,
    owner_diff: Array,
    other_diff: Array,
    status: String
});

module.exports = mongoose.model('Bid', BidSchema);