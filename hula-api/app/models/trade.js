var mongoose     = require('mongoose');
var Bid     	 = require('./bid');
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

var ChatSchema   = new Schema({
    user_id: String,
    date: Date,
    message: String,
    type: String,
    status: String
});


var TradeSchema   = new Schema({
    product_id: String,
    owner_id: String,
    other_id: String,
    other_agree: Boolean,
    other_ready: Boolean,
    owner_ready: Boolean,
    date: Date,
    last_update: Date,
    owner_products: Array,
    other_products: Array,
    owner_money: Number,
    other_money: Number,
    owner_accepted: Boolean,
    other_accepted: Boolean,
    last_bid_id: String,
    status: String,
    num_bids: Number,
    turn_user_id: String,
    owner_unread:Number,
    other_unread:Number,
    bids: [BidSchema],
    chat: [ChatSchema]
});

module.exports = mongoose.model('Trade', TradeSchema);