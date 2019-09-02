var mongoose     = require('mongoose');
var Schema       = mongoose.Schema;

var ProductSchema   = new Schema({
    title: String,
    description: String,
    owner_id: String,
    condition: String,
    category_id: String,
    category_name: String,
    images:[String],
    location: {
			    type: [Number],
			    index: '2d'
			  },
    date_created: Date,
    image_url: String,
    trading_count: Number,
    status: String,
    video_requested: { type : mongoose.Schema.Types.Mixed, default : {} },
    video_url: { type : mongoose.Schema.Types.Mixed, default : {} },
    priority: Number
});
module.exports = mongoose.model('Product', ProductSchema);