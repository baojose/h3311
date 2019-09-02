var mongoose     = require('mongoose');
var Schema       = mongoose.Schema;

var CategorySchema   = new Schema({
    name: String,
    description: String,
    icon: String,
    slug: String,
    order: Number,
    num_products: Number,
    status: String
});

module.exports = mongoose.model('Category', CategorySchema);