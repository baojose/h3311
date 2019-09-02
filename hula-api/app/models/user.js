var mongoose     = require('mongoose');
var Schema       = mongoose.Schema;

var UserSchema   = new Schema({
    nick: String,
    name: String,
    lname: String,
    email: String,
    bio: String,
    type: String,
    image: String,
    zip: String,
    last_login: Date,
    signup_date: Date,
    feedback_count: Number,
    feedback_points: Number,
    trades_started: Number,
    trades_finished: Number,
    trades_closed: Number,
    max_trades: Number,
    fb_token: { type: String, select: false },
    tw_token: { type: String, select: false },
    gp_token: { type: String, select: false },
    li_token: { type: String, select: false },
    em_token: { type: String, select: false },
    location: {
			    type: [Number],
			    index: '2d'
			  },
    location_name: String,
    push_device_id: { type: String },
    salt: { type: String, select: false },
    pass: { type: String, select: false },
    status: String
});

module.exports = mongoose.model('User', UserSchema);