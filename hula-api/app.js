// environment setup
var express = require('express')
var multer  = require('multer')
var upload = multer({ dest: 'uploads/' })
var im = require('imagemagick');

var bodyParser = require('body-parser');
var mongoose = require('mongoose');
var methodOverride = require("method-override");
var jwt    = require('jsonwebtoken');
var sha256    = require('sha256');
var fs    = require('fs');
var https = require('https')
var http = require('http')
  

// app constants
var port = 80;
var ssl_port = 443;
var api_version = 'v1';
var secret = 'SECRET-KEY';
var static_server_ssh = 'USER:PASSWORD@IP_ADDRESS';
var static_server_path = '/var/www/html/files/';
//var privateKey = fs.readFileSync( '/opt/hula-api/app/ssl/hula.key', 'utf8' );
//var certificate = fs.readFileSync( '/opt/hula-api/app/ssl/certificate-api.crt', 'utf8' );
var privateKey = fs.readFileSync( 'PATH_TO_YOUR_SERVER_DOMAIN_CERTS/privkey.pem', 'utf8' );
var certificate = fs.readFileSync( 'PATH_TO_YOUR_SERVER_DOMAIN_CERTS/fullchain.pem', 'utf8' );
var ssl_options = {
    key: privateKey,
    cert: certificate
}; 


// app initialization
var app = express();
var trades_closed = "";

require('events').EventEmitter.prototype._maxListeners = 20;

// Models
var User     = require('./app/models/user');
var Product     = require('./app/models/product');
var Category     = require('./app/models/category');
var Notification     = require('./app/models/notification');
var Trade     = require('./app/models/trade');
var Bid     = require('./app/models/bid');
var Chat     = require('./app/models/chat');
var Feedback     = require('./app/models/feedback');
var Keyword     = require('./app/models/keyword');


// Middlewares
app.use(bodyParser.urlencoded({ extended: false, limit: '50mb' })); 
app.use(bodyParser.json({limit: '50mb'})); 
app.use(methodOverride());


// mongoose wrapper conection
var mongoose   = require('mongoose');
mongoose.connect('mongodb://MONGO_USER:MONGO_PASSWORD@MONGO_SERVER:MONGO_PORT/MONGO_DB'); // connect to our database



var router = express.Router();

// middleware to use for all requests
router.use(function(req, res, next) {
    // do logging
    console.log(req.method + "  " + req.originalUrl);
    
    res.setHeader('Access-Control-Allow-Origin', 'https://hula.trading');
    next(); // make sure we go to the next routes and don't stop here
});



// Index for testing if the app is up and running
router.get('/', function(req, res) { 
 res.json({ message: 'Welcome to Hula API '+api_version+'!' });
});

//////////////////////////////////////
///
///   UTILS
///
/////////////////////////////////////
function update_category_counter(id, increment){
	Category.findById(id, function(err, category) {
		if (category){
			if (typeof category.num_products == "undefined"){
				category.num_products = 1
			} else {
	        	category.num_products += increment;
	        }
	        category.save(function(err) { });
        }
    });
}
function refresh_category_counters(id){
	Category.findById(id, function(err, category) {
		Product.find({'category_id':id, status:{'$nin':['traded', 'deleted'] } }, function(err, products) {
	        category.num_products = products.length;
	        category.save(function(err) { });
	    });
    });
}

function update_user_feedback(user_id){
	Feedback.find({user_id:user_id}, function(err, feedback) {
        console.log(feedback);
        var feedback_points = 0
        var feedback_count = 0
	    for ( fb in feedback ){
            var item = feedback[fb];
            if (typeof item["val"] != "undefined") {
                feedback_points += item["val"]/5
                feedback_count += 1
            }
        }
        
        User.findById(user_id, function(err, user) {
	        console.log(user)
	        if (user){
		        user.feedback_points = feedback_points;
		        user.feedback_count = feedback_count;
		        user.save(function(err) { });
	        }
	    
	    })
        
    });
}
function update_user_trades(user_id){
	Trade.find({ $or:[ {owner_id: user_id}, {other_id: user_id} ]}, function(err, trades) {
            
        //console.log(trades);
        var trades_started = 0
        var trades_finished = 0
        var trades_closed = 0
	    for ( tr in trades ){
		    trades_started += 1;
            var item = trades[tr];
            if (item["status"] == "ended") {
		    	trades_finished += 1;
            }
            if (item["status"] == "closed") {
		    	trades_closed += 1;
            }
        }
        
        User.findById(user_id, function(err, user) {
	        if (user){
		        user.trades_started = trades_started;
		        user.trades_finished = trades_finished;
		        user.trades_closed = trades_closed;
		        user.save(function(err) { });
	        }
	    
	    })
        
    });
    
}


function updateProductCounters(pid, affected_user) {
    console.log("Updating product counter... " + pid);
    Product.findById(pid, function (err1, product){
	    
	    //console.log(product);
	    if (product) {
		    var previous_counter = product.trading_count;
		    Trade.find({ $or:[ {other_products: pid},  {owner_products: pid} ], status: {$nin:['ended', 'closed', 'review'] }  }, function (err2, trs){
		        if (trs){
		        	product.trading_count = trs.length;
		        } else {
		        	product.trading_count = 0;
		        }
		        console.log("Updating trades counter... " + product.trading_count);
				product.save()
				
				if ( (product.trading_count > 1) && (affected_user != undefined ) ){
					for (var t = 0; t < trs.length; t++){
						var other_user1 = trs[t].owner_id;
						var other_user2 = trs[t].other_id;
						var notif_user = '';
						if (product.owner_id == other_user1){
							notif_user = other_user2;
						}
						if (product.owner_id == other_user2){
							notif_user = other_user1;
						}
						// notify if product is trading with someone else!
						if ( (notif_user != '' ) && (notif_user != affected_user) ) {
							if ( previous_counter < product.trading_count ) {
								// send notification to affected user
								getUserName(product.owner_id, function (uname){
			                		createNotification(notif_user, product.owner_id, 'trade', '@'+uname+' is trading ˝' + product.title +'˝ with someone else.');
			            		});
							}
						}
					}
				}
		    });
	    }
    });
}



function updateAllProductCounters() {
    console.log("Updating all counters... ");
    Product.find( { status: { $nin: ['traded','deleted'] } } , function (err1, products){
	    
	   if (products){
		   for (pr in products){
			   updateProductCounters(products[pr].id);
		   }
	   }
	   console.log("Updated " + pr)
    });
}


function disableProducts(atrade, user_id){
	console.log("---")
	console.log(atrade)
	console.log("---")
	for ( i=0; i<atrade.length; i++){
		if (atrade[i] != ""){
			Product.findById(atrade[i], function (err, doc){
				if (err) return
			  
			  if (doc.category_id != '59124d47a0716d0938e9276c'){
				  // services products do not expire
				  doc.status = 'traded';
				  doc.save();
				  notifyRemovedProduct(atrade[i], user_id);
			  }
			});
			
		}
	}	
}


function enableProducts(atrade, user_id){
	for ( i=0; i<atrade.length; i++){
		if (atrade[i] != ""){
			Product.findById(atrade[i], function (err, doc){
				if (err) return
			  doc.status = 'normal';
			  doc.save();
			});
			
		}
	}	
}





function notifyRemovedProduct(id, owner){
	// notify if other users where trading this product
	Trade.find({ $or:[ {other_products: id},  {owner_products: id} ], status: {$nin:['ended', 'closed', 'review'] }  }, function (err2, trs){
		
		for ( j=0; j<trs.length; j++){
		  	var user_to_notify = trs[j].owner_id;
		  	var user_from_notify = trs[j].other_id;
		  	if ( trs[j].owner_id == owner ){
			  	user_to_notify = trs[j].other_id;
			  	user_from_notify = trs[j].owner_id;
		  	}
		  	
		  	getProductName(id, function (pname){
			  	getUserName(user_from_notify, function (uname){
					createNotification(user_to_notify, user_from_notify, 'trade', 'Sorry, product "'+pname+'" is not available anymore. It has been deleted or traded by user @'+uname+'.');
				});
		  	})
			
		  	
		}
	});
}

function getUserName(id, callback){
	User.findById(id, function(err, user) {
			if (err)
				console.log(err);
			    
            if (user){
				callback(user.nick);
			} else {
				callback('User');
			}
		});
}
function getProductName(id, callback){
	Product.findById(id, function(err, product) {
			if (err)
				console.log(err);
			    
            if (product){
				callback(product.title);
			} else {
				callback('Product');
			}
		});
}


function arr_diff(old_arr, new_arr) {
	if (old_arr == undefined){
		old_arr = [];
	}
	if (new_arr == undefined){
		new_arr = [];
	}
    var a = [], diff = [];
    for (var i = 0; i < old_arr.length; i++) {
        a[old_arr[i]] = true;
    }
    for (var i = 0; i < new_arr.length; i++) {
        if (a[new_arr[i]]) {
            delete a[new_arr[i]];
        } else {
            a[new_arr[i]] = true;
        }
    }
    for (var k in a) {
	    if (new_arr.indexOf(k) == -1){
		    k = "-"+k;
		}
        diff.push(k);
    }
    
    
    return diff;
};



function isInArray(ar,it){
	for (a in ar){
		console.log("comparing " + ar[a] + " con " + it);
		if ( ar[a] === it){
			console.log("same!");
			return true;
		}
	}
			console.log("not found");
	return false
}


//////////////////////////////////////
///
///   TRADE MANAGEMENT
///
/////////////////////////////////////
router.route('/trades')
    .post(isAuthenticated, function(req, res) {
	    
	    // first, check if the user has another trade
	    Trade.find({ $or:[ {owner_id: req.decoded._doc._id, other_id:req.body.other_id}, {other_id: req.decoded._doc._id, owner_id:req.body.other_id} ], status: {$nin:['ended', 'closed', 'review'] }}, function(err, trades) {
            if (err)
                res.send(err);
                
            if ((trades.length>0)){
	            console.log('Open trade already exists!');
	            var trade = trades[0];
		        trade.other_agree = true;
		        trade.status = 'offer_sent';
		        trade.save();
				res.json({ message: 'Open trade already exists!', trade_id: trades[0]._id });
            } else {
	            // no trades yet. We create it
	            console.log('No trades. Creating');
	            
	            var trade = new Trade();
		        trade.product_id = req.body.product_id;
		        trade.other_agree = false;
		        trade.other_ready = false;
		        trade.owner_ready = false;
		        trade.owner_id = req.decoded._doc._id;
		        trade.other_id = req.body.other_id;
		        trade.date = new Date();
		        trade.last_update = new Date();
		        trade.owner_products = [];
		        if ((req.body.product_id != undefined) && (req.body.product_id.length > 0)){
		        	trade.other_products = [req.body.product_id];
		        } else {
		        	trade.other_products = [];
			    }
		        trade.owner_money = 0;
		        trade.other_money = 0;
		        trade.owner_accepted = false;
		        trade.other_accepted = false;
		        trade.owner_unread = 0;
		        trade.other_unread = 0;
		        trade.last_bid_id = '';
		        trade.status = 'pending';
		        trade.num_bids = 0;
		        trade.turn_user_id = req.decoded._doc._id;
		        
		        
		        trade.chat = [];
		        var bid = new Bid();
				bid.user_id = req.decoded._doc._id;
			    bid.date = new Date();
			    bid.owner_products = [];
			    bid.other_products = [req.body.product_id];
			    
			    bid.owner_diff = bid.owner_products;
			    bid.other_diff = bid.other_products;
			    
			    //bid.next_bid = '';
			    bid.status = 'new';
		        
		        
		        trade.bids = [bid];
		        trade.save(function(err) {
		            if (err)
		                res.send(err);
		
		            res.json({ message: 'Trade created!', trade_id: trade._id });
					update_user_trades(trade.owner_id);
					update_user_trades(trade.other_id);
					createNotification(trade.other_id, trade.owner_id, 'start', 'Other HULA user is interested on trading with you.');
		        });
            }
        });
        
        
    })
    .get(isAuthenticated, function(req, res) {
	    
	    var user_id = req.decoded._doc._id;
	    
        Trade.find({ $or:[ {owner_id: req.decoded._doc._id}, {other_id: req.decoded._doc._id} ]}).sort({last_update: -1}).limit(100).exec(function(err, trades) {
            if (err)
                res.send(err);
            res.json(trades);
        });
    });
    
    
    
router.route('/trades/:trade_id')
    .get(function(req, res) {
        Trade.findById(req.params.trade_id, function(err, trade) {
            if (err)
                res.send(err);
            
            res.json(trade);
            
        });
    })
    .put(isAuthenticated, function(req, res) {
	    //console.log(req.body)
        Trade.findById(req.params.trade_id, function(err, trade) {
            if (err)
                res.send(err);
			//console.log(trade.owner_id + " - " )
			//console.log(trade);
			if ((trade.owner_id != req.decoded._doc._id) && (trade.other_id != req.decoded._doc._id)){
				// this is not your trade!!!
                res.json({ message: 'This is not your trade!' });
			} else {
				/*
				if ((trade.turn_user_id != req.decoded._doc._id) && (req.body.status != "ended") && (req.body.status != "closed") && (req.body.status != "review")){
                	res.json({ message: 'Not your turn!' });
                	
				} else {
				*/
				console.log(req.body)
		        trade.last_update = new Date();
			    if (req.body.owner_products != undefined){
				    
				    
					var bid = new Bid();
					
				    bid.owner_products = req.body.owner_products.split(",");
				    bid.other_products = req.body.other_products.split(",");
				    
				    var owner_diff = arr_diff(trade.owner_products, bid.owner_products);
				    var other_diff = arr_diff(trade.other_products, bid.other_products);
				    
					//bid.trade_id = req.params.trade_id;
					bid.user_id = req.decoded._doc._id;
				    bid.date = new Date();
				    //bid.count = num_bids;
				    bid.owner_diff = owner_diff;
				    bid.other_diff = other_diff;
				    
				    //bid.next_bid = '';
				    bid.status = 'new';
			        trade.owner_products = req.body.owner_products.split(",");
			        trade.other_products = req.body.other_products.split(",");
			        
					trade.bids.push(bid);
					trade.num_bids = trade.bids.length;
			    }
		        if (req.body.owner_money != undefined){
					trade.owner_money = parseFloat(req.body.owner_money);
				}
		        if (req.body.other_money != undefined){
					trade.other_money = parseFloat(req.body.other_money);
				}
		        if (req.body.accepted == "true"){
			        if (trade.owner_id == req.decoded._doc._id){
				        trade.owner_accepted = true;
					} else {
				        trade.other_accepted = true;
					}
				}
				if (trade.owner_accepted && trade.other_accepted){
					// both users accepted. Override received status
					trade.status = "ended"
				} else {
		        	trade.status = req.body.status;
				}
		        trade.turn_user_id = (trade.owner_id == req.decoded._doc._id)? trade.other_id : trade.owner_id;
		        //console.log(trade);
	            trade.save(function(err) {
	                if (err)
	                    res.send(err);
	                    
	                switch (trade.status){
	                	case "closed":
	                		// deal removed.
	                		createNotification(trade.turn_user_id, req.decoded._doc._id, 'trade', 'Your trade has been canceled.');
	                		enableProducts(trade.owner_products, trade.owner_id);
	                		enableProducts(trade.other_products, trade.other_id);
	                		break;
	                	case "ended":
	                		// deal confirmed and products exchanged. All ok
	                		createNotification(trade.owner_id, trade.other_id, 'trade', 'Congrats! Your trade is finished. Thanks for using HULA.');
	                		createNotification(trade.other_id, trade.owner_id, 'trade', 'Congrats! Your trade is finished. Thanks for using HULA.');
	                		// disable all products from this trade
	                		//disableProducts(trade);
	                		break;
	                	case "review":
	                		// deal closed but waiting for confirmation.
	                		createNotification(trade.turn_user_id, req.decoded._doc._id, 'trade', 'Your trade offer has been accepted!');
	                		disableProducts(trade.owner_products, trade.owner_id);
	                		disableProducts(trade.other_products, trade.other_id);
	                		break;
	                	default:
	                		// deal modified
	                		getUserName(req.decoded._doc._id, function (uname){
		                		if(trade.bids.length==2){
		                			createNotification(trade.other_id, trade.owner_id, 'start', '@'+uname+' is interested on trading with you.');
		                		} else {
	                				createNotification(trade.turn_user_id, req.decoded._doc._id, 'trade', 'Check your new offer from @'+uname+'!');
	                			}
	                		});
	                		
	                		break;
	                }	
	                
	                res.json({ message: 'Trade details updated!' });
					update_user_trades(trade.owner_id);
					update_user_trades(trade.other_id);
					for (i = 0; i < trade.owner_products.length; i++) {
			            var prodid = trade.owner_products[i];
			            if (prodid!=""){
			            	updateProductCounters(prodid, trade.turn_user_id);
			            }
		            }
		            for (i = 0; i < trade.other_products.length; i++) {
			            var prodid = trade.other_products[i];
			            if (prodid!=""){
			            	updateProductCounters(prodid, trade.turn_user_id);
			            }
		            }
	            });
		          /*  
				}
				*/
				
			}
        });
    });
    
router.route('/trades/:trade_id/agree')
	.get(isAuthenticated, function(req, res) {
	    Trade.findById(req.params.trade_id, function(err, trade) {
	        if (err)
	            res.send(err);
	        
	        trade.other_agree = true
		    trade.status = 'offer_sent';
	        users_list = [trade.owner_id, trade.other_id];
	        trade.save();
	        res.json({ message: 'Trade set as agreed!' });
	        
			console.log("updating notifications: " , users_list);
	        Notification.find({to_id: {$in: users_list}, from_id:{$in: users_list}, type: "start"}, function (err2, notifs){
		        console.log(notifs);
		        
		        for (notif in notifs){
			        console.log("updating notification: ", notif);
					notifs[notif].type = "trade";
					notifs[notif].save();
				}
	        })
	        
	    });
	});

router.route('/trades/:trade_id/ready')
	.get(isAuthenticated, function(req, res) {
	    Trade.findById(req.params.trade_id, function(err, trade) {
	        if (err)
	            res.send(err);
	           
	        var other_user = (req.decoded._doc._id == trade.owner_id)? trade.other_id : trade.owner_id;
	            
	            
	        if (trade.owner_id == req.decoded._doc._id){
		        // owner
				trade.owner_ready = true;
	        }
	        if (trade.other_id == req.decoded._doc._id){
		        // other
				trade.other_ready = true;
	        }
	        
	        if ((trade.owner_ready) && (trade.other_ready)){
		        // both users agree
		        
		        trade.status = "review";
		        trade.last_update = new Date();
        		
        		
        		createNotification(other_user, req.decoded._doc._id, 'trade', 'Your trade offer has been accepted!');
        		disableProducts(trade.owner_products, trade.owner_id);
        		disableProducts(trade.other_products, trade.other_id);
		        
		        
	        } else {
		        // one of the users still does not agree
		        
		        trade.turn_user_id = other_user;
	        }
	        
	        trade.save();
	        res.json({ message: 'Trade set as ready by ' + req.decoded._doc._id });
	        
	    });
	});




router.route('/product_counters')
    .get(function(req, res) {
	    updateAllProductCounters()
		res.json({ message: 'Trade details updated!' });
	});


router.route('/trades/:trade_id/chat')
	.get(isAuthenticated, function(req, res) {
	    
	    // first, check if the user has another trade
	    Trade.find({ $or:[ {owner_id: req.decoded._doc._id, _id:req.params.trade_id}, {other_id: req.decoded._doc._id, _id:req.params.trade_id} ]}, function(err, trades) {
            if (err)
                res.send(err);
                
                
            if (trades.length==0){
				res.json({ message: 'Trade does not exists or is not yours!' });
            } else {
	            var trade = trades[0];
				if (trade.owner_id == req.decoded._doc._id){
					// i am the owner
					trade.owner_unread = 0;
				} else {
					trade.other_unread = 0;
				}
				trade.save();
		        res.json(trade.chat);
            }
        });
        
        
    })
	.post(isAuthenticated, function(req, res) {
	    
	    // first, check if the user has another trade
	    Trade.find({ $or:[ {owner_id: req.decoded._doc._id, _id:req.params.trade_id}, {other_id: req.decoded._doc._id, _id:req.params.trade_id} ]}, function(err, trades) {
            if (err)
                res.send(err);
            if (trades.length==0){
				res.json({ message: 'Trade does not exists or is not yours!' });
            } else {
	            var trade = trades[0];
	            var chat = new Chat();
	            //console.log(req.body)
		        chat.user_id = req.decoded._doc._id;
		        chat.date = new Date();
		        chat.message = req.body.message;
		        chat.type = (trade.owner_id == req.decoded._doc._id)?'owner':'other';
		        chat.status = 'sent';
		        
		        //console.log(chat)
		        trade.chat.push(chat);
		        
				if (trade.owner_id == req.decoded._doc._id){
					//i am the owner, so i update unread messages for the other
					if (typeof trade.other_unread == "number"){
						trade.other_unread += 1;
					} else {
						trade.other_unread = 1;
					}
				} else {
					//i am the other, so i update unread messages for the owner
					if (typeof trade.owner_unread == "number"){
						trade.owner_unread += 1;
					} else {
						trade.owner_unread = 1;
					}
				}
		        
		        trade.save(function(err) {
		            if (err)
		                res.send(err);
					
					var to_user = (trade.owner_id == req.decoded._doc._id)? trade.other_id:trade.owner_id
					createNotification(to_user, req.decoded._doc._id, 'chat', 'You have received a new message: ' + req.body.message)
					
		            res.json({ message: 'Chat updated!', trade_id: trade._id });
		        });
            }
        });
        
        
    });
    
router.route('/abandoned')
	.get(function(req, res) {
	});

function lookForAbandonedTrades(user_id){
    var last72h = new Date();
    last72h.setTime(last72h.getTime() - 72*60*60*1000);
    console.log("Looking for old unattended trades");
	Trade.find({ $or:[ {owner_id: user_id}, {other_id: user_id} ], last_update: {$lt: last72h}, status: {$nin:['ended', 'closed', 'review'] } }, function(err, trades) {
		
		if (trades.length > 0){
			console.log("Found: " + trades.length);
		}
		for (trade in trades){
			if (trades_closed.indexOf(trades[trade]._id) == -1){
				trades_closed += trades[trade]._id;
				console.log(trades_closed);
				console.log("Closing trade " + trades[trade]._id);
				trades[trade].status = "closed";
			    if (trades[trade].owner_id == trades[trade].turn_user_id){
			    	createNotification(trades[trade].owner_id, trades[trade].owner_id, 'trade', 'Too late! The trade has expired, the offers have to be responded to in 72 hours.');
					getUserName(trades[trade].owner_id, function (uname){
					    createNotification(trades[trade].other_id, trades[trade].other_id, 'trade', 'Your trade has expired. User @'+uname+' has not responded in the last 72 hours. Keep trading!');
		            });
			    } else {
				    createNotification(trades[trade].other_id, trades[trade].other_id, 'trade', 'Too late! The trade has expired, the offers have to be responded to in 72 hours.');
				    getUserName(trades[trade].other_id, function (uname){
					    createNotification(trades[trade].owner_id, trades[trade].owner_id, 'trade', 'Your trade has expired. User @'+uname+' has not responded in the last 72 hours. Keep trading!');
		            });
					
			    }
				trades[trade].save(function(err) { });
				
			}
		}
    });
}



router.route('/live_barter/:trade_id')
    .post(isAuthenticated, function(req, res) {
	    
	    // first, check this trade belongs to the user
	    Trade.find({ _id:req.params.trade_id, $or:[ {owner_id: req.decoded._doc._id}, {other_id: req.decoded._doc._id} ]}, function(err, trades) {
            if (err)
                res.send(err);
                
            if (trades.length > 0){
	            var trade = trades[0];
	            var bid = new Bid();
		        if (req.body.owner_products != undefined){
				    bid.owner_products = req.body.owner_products.split(",");
				    bid.other_products = req.body.other_products.split(",");
			    } else {
				    bid.owner_products = [""];
				    bid.other_products = [""];
			    }
			    
			    var owner_diff = arr_diff(trade.owner_products, bid.owner_products);
			    var other_diff = arr_diff(trade.other_products, bid.other_products);
			    
			    bid.owner_diff = owner_diff;
			    bid.other_diff = other_diff;
			    
			    var ow_mo = 0;
			    var ot_mo = 0;
		        if (req.body.owner_products != undefined){
				    ow_mo = parseFloat(req.body.owner_money);
				    ot_mo = parseFloat(req.body.other_money);
		        }
		    
		        if ((bid.owner_diff.length + bid.other_diff.length > 0) || (trade.owner_money - trade.other_money != ow_mo - ot_mo ) ){
			        
			    	bid.status = 'new';
					bid.user_id = req.decoded._doc._id;
				    bid.date = new Date();
			        trade.owner_products = bid.owner_products;
			        trade.other_products = bid.other_products;
			        
			        trade.owner_money = ow_mo;
			        trade.other_money = ot_mo;
			        
			        // reset readyness
					trade.owner_ready = false;
					trade.other_ready = false;

					trade.bids.push(bid);
					trade.num_bids = trade.bids.length;
			        if (req.body.owner_money != undefined){
						trade.owner_money = parseFloat(req.body.owner_money);
					}
			        if (req.body.other_money != undefined){
						trade.other_money = parseFloat(req.body.other_money);
					}
					
		            trade.save(function(err) {
			            if (err){
			                res.send(err);
						} else {
			            	res.json(trade);
			            }
			        });
			        
		        } else {
					//res.json({ message: 'Same bid!' + bid.owner_diff.length + " - " + bid.other_diff.length });
			        res.json(trade);
		        }
            } else {
	            // no trades found
				res.json({ message: 'No trade found!' });
            }
        });
        
        
    })
    .get(isAuthenticated, function(req, res) {
	    
	    var user_id = req.decoded._doc._id;
	    
        Trade.find({ _id:req.params.trade_id, $or:[ {owner_id: req.decoded._doc._id}, {other_id: req.decoded._doc._id} ]}).exec(function(err, trades) {
            if (err)
                res.send(err);
            res.json(trades[0]);
        });
    });




//////////////////////////////////////
///
///   PRODUCT MANAGEMENT
///
/////////////////////////////////////

router.route('/products')
    .post(isAuthenticated, function(req, res) {
	    
	    
        var product = new Product();
        product.title = req.body.title;
        product.description = req.body.description;
        product.owner_id = req.decoded._doc._id;
        product.condition = req.body.condition;
        product.category_id = req.body.category_id;
        product.date_created = new Date();
        product.status = "normal";
        product.location = [ req.body.lat, req.body.lng ];
        product.video_requested = {}
        product.video_url = {}
        product.trading_count = 0
        product.priority = 0
        
        // update category product counter
        update_category_counter(req.body.category_id, 1);
        
        //update category name
        Category.findById(req.body.category_id, function(err, category) {
			if (category){
				product.category_name = category.name;
	        } else {
		        product.category_name = '-'
	        }
	        
	        product.save(function(err) {
	            if (err)
	                res.send(err);
	
	            res.json({ message: 'Product created!', product_id: product._id });
	            
	            notifyOtherUsers(product.owner_id);
	            
	        });
    	});
        
    })
    .get(function(req, res) {
        Product.find({},null, { sort: { priority : -1, created_at: -1 } }).exec(function(err, products) {
            if (err)
                res.send(err);

            res.json(products);
        });
    });
router.route('/products/:product_id')
    .get(function(req, res) {
        Product.findById(req.params.product_id, function(err, product) {
            if (err)
                res.send(err);
            
            if (product){
				res.json(product);
            } else {
				res.json({});
            }
            
            updateProductCounters(product.id)
        });
    })
    .put(isAuthenticated, function(req, res) {
	    //console.log(req.body)
        Product.findById(req.params.product_id, function(err, product) {
            if (err)
                res.send(err);
			if (product.owner_id == req.decoded._doc._id){
				// modified by the owner
	            product.title = req.body.title;
				product.description = req.body.description;
				product.condition = req.body.condition;
				if (product.category_id != req.body.category_id){
					update_category_counter(product.category_id, -1);
					update_category_counter(req.body.category_id, 1);
				}
				product.category_id = req.body.category_id
		        //update category name
		        Category.findById(req.body.category_id, function(err, category) {
					if (category){
						product.category_name = category.name;
			        } else {
				        product.category_name = req.body.category_name
			        }
			        if (req.body.images){
						var arr_images = req.body.images.split(",")
						product.images = arr_images
						product.image_url = arr_images[0]
					}
		            product.save(function(err) {
		                if (err)
		                    res.send(err);
		
		                res.json({ message: 'Product details updated!' });
		            });
			    });
		    } else {
            	res.json({ message: 'Not allowed!' });
		    }
	    });
    });
    
    
router.route('/products/:product_id/delete')
    .get(isAuthenticated, function(req, res) {
	    Product.find({_id: req.params.product_id, owner_id:req.decoded._doc._id},  function(err, products) {
            if (err)
                res.send(err);
            
            if (products) {
	            for (product in products) {
		            products[product].status = 'deleted';
		            products[product].save();
	            }
            }
            
            res.json({ message: 'Product removed!' });
            
            notifyRemovedProduct(req.params.product_id, req.decoded._doc._id);
        });
    });
    
    
router.route('/products/:product_id/requestvideo/:trade_id')
    .get(isAuthenticated, function(req, res) {
        Product.findById(req.params.product_id, function(err, product) {
            if (err)
                res.send(err);
            
            if (typeof product.video_requested != "object"){
	            console.log("resetting videorequested...")
	            product.video_requested = {}
            }
            product.video_requested[req.params.trade_id] = true;
            product.markModified('video_requested');
            //console.log(product.video_requested[req.params.trade_id]);
            //console.log(product);
            Trade.findById(req.params.trade_id, function (er, trade){
	            var nopush = false;
	    		if (trade.other_agree != true ){
	            	nopush = true;
	    		}
	    		getUserName(req.decoded._doc._id, function (uname){
					createNotification(product.owner_id, req.decoded._doc._id, 'trade', '@'+uname+' is waiting for videoproof of your product.', nopush);
	    		});
            });
            
            product.save();
            res.json(product);
        });
    })


router.route('/products/near/:lat/:lng')
    .get(function(req, res) {
	    if  ( parseFloat(req.params.lng) == 0 ) {
		    // no location
		    
		    Product.find ( { status: { '$nin': ['traded', 'deleted'] } }, null, { sort: { priority : -1, created_at: -1 } }).limit(50).exec(function(err, products) {
		            if (err)
		                res.send(err);
		                
		            var users_list = [];
		            for ( product in products ){
			            if (users_list.indexOf(products[product].owner_id) == -1){
			            	users_list.push( products[product].owner_id) ;
			            }
		            }
		            User.find({_id: {$in: users_list} }, function(err, users) {
			            var users_assoc = {};
			            for (user in users){
				            users_assoc[users[user]._id] = users[user]
			            }
			            //console.log({'products':products, 'users':users_assoc});
			            res.json({'products':products, 'users':users_assoc});
			        });
		    });
		    
	    } else {
	    
	        Product.find({
				  }, null, { sort: { priority : -1 } }).limit(50).exec(function(err, products) {
		            if (err)
		                res.send(err);
		            //console.log(products);
		            var users_list = [];
		            for ( product in products ){
			            if (users_list.indexOf(products[product].owner_id) == -1){
			            	users_list.push( products[product].owner_id) ;
			            }
		            }
		            User.find({_id: {$in: users_list} }, function(err, users) {
			            var users_assoc = {};
			            for (user in users){
				            users_assoc[users[user]._id] = users[user]
			            }
			            //console.log({'products':products, 'users':users_assoc});
			            res.json({'products':products, 'users':users_assoc});
			        });
		    });
	    }
    });
    
router.route('/products/user/:user_id')
    .get(isAuthenticated, function(req, res) {
        Product.find({owner_id: req.params.user_id, status: {'$nin':['traded', 'deleted'] }}, null, { sort: { priority : -1, created_at: 1 } },  function(err, products) {
            if (err)
                res.send(err);
            res.json(products);
        });
    });
    
router.route('/products/category/:category_id')
    .get(function(req, res) {
	    //console.log(req.params.category_id)
	    refresh_category_counters(req.params.category_id)
        Product.find({category_id:req.params.category_id, status:{'$nin':['traded', 'deleted'] }}, null, { sort: { priority : -1, created_at: -1 } }, function(err, products) {
	            if (err)
	                res.send(err);
	             //console.log(products)
	            var users_list = [];
	            for ( product in products ){
		            if (users_list.indexOf(products[product].owner_id) == -1){
		            	users_list.push( products[product].owner_id) ;
		            }
	            }
	            User.find({_id: {$in: users_list} }, function(err, users) {
		            var users_assoc = {};
		            for (user in users){
			            users_assoc[users[user]._id] = users[user]
		            }
		            //console.log({'products':products, 'users':users_assoc});
		            res.json({'products':products, 'users':users_assoc});
		        });
	    });
    });
    
    

 


//////////////////////////////////////
///
///   IMAGE MANAGEMENT
///
/////////////////////////////////////

router.route('/products/:product_id/image').get(product_image_redirect);
router.route('/products/:product_id/tm_image').get(product_thumb_redirect);
    
function product_image_redirect(req, res) {
    Product.findById(req.params.product_id, function(err, product) {
        if ((err) || (product == undefined)){
		    res.redirect("https://hula.trading/files/product/nope_hula.jpg");
		} else {
			if (product.image_url == undefined){
		    	res.redirect("https://hula.trading/files/product/nope_hula.jpg");
            } else {
            	res.redirect(product.image_url);
            }
        }
    });
}
function product_thumb_redirect(req, res) {
    Product.findById(req.params.product_id, function(err, product) {
        if ((err) || (product == undefined)){
		    res.redirect("https://hula.trading/files/product/nope_hula.jpg");
		} else {
			if (product.image_url == undefined){
		    	res.redirect("https://hula.trading/files/product/nope_hula.jpg");
            } else {
            	res.redirect(get_thumb_for_image(product.image_url));
            }
        }
    });
}
function get_thumb_for_image(url){
    var parts = url.split("/");
    var img_name = "tm_" + parts[parts.length - 1];
    parts[parts.length - 1] = img_name;
    return parts.join("/");
}
    
    
    
    
    
    
//////////////////////////////////////
///
///   SEARCH AND AUTOCOMPLETE
///
/////////////////////////////////////
router.route('/products/search/:keyword')
    .get(function(req, res) {
        Keyword.find({'keyword':req.params.keyword.toLowerCase()}, function(err, keywords) {
	            if (err)
	                res.send(err);
	             //console.log(products)
		        console.log(keywords)
	            if (keywords.length>0){
		            keyword = keywords[0]
		            keyword.relevance += 1
	            } else {
		            keyword = new Keyword();
					keyword.keyword = req.params.keyword.toLowerCase();
					keyword.date = new Date();
					keyword.relevance = 1;
					keyword.user_id = 1;
	            }
				keyword.save(function(err) { });
	            
	    });
	    User.find({$or:[{"name": { "$regex": req.params.keyword.toLowerCase(), "$options": "i" } }, {"nickname": { "$regex": req.params.keyword.toLowerCase(), "$options": "i" } } ] }, function(err, found_users) {
		    Product.find({"title": { "$regex": req.params.keyword.toLowerCase(), "$options": "i" }, 'status':{'$nin':['traded', 'deleted'] } }, null, { sort: { priority : -1, created_at: -1 } }, function(err, products) {
		            if (err)
		                res.send(err);
		            var users_list = [];
		            for ( product in products ){
			            if (users_list.indexOf(products[product].owner_id) == -1){
			            	users_list.push( products[product].owner_id) ;
			            }
		            }
		            User.find({_id: {$in: users_list} }, function(err, users) {
			            var users_assoc = {};
			            for (user in users){
				            users_assoc[users[user]._id] = users[user]
			            }
			            //console.log({'products':products, 'users':users_assoc});
			            res.json({'products':products, 'users':users_assoc, 'found_users': found_users } );
			        });
		            
		    });
    	});
    });
    
    
router.route('/search/auto/:auto')
    .get(function(req, res) {
        Keyword.find({'keyword':{ "$regex": req.params.auto.toLowerCase(), "$options": "i" }}).sort('-relevance').limit(20).exec( function(err, keywords) {
	            if (err)
	                res.send(err);
	             //console.log(products)
		        res.json({'keywords':keywords});
	            
	    });
    });
    
    
//////////////////////////////////////
///
///   PRODUCT IMAGE UPLOADS
///
/////////////////////////////////////
router.route('/upload/image')
    .post(isAuthenticated, upload.single('image'), function (req, res, next) {
	    
	    
	var uuid = require('uuid')
	var fs = require('fs')
	var client = require('scp2')
	// req.file is the `avatar` file
	// req.body will hold the text fields, if there were any
	var file = req.file;
	//console.log(req.body.position)
	//console.log(file);
	var contentType = file.mimetype;
	var tmpPath = file.path;
	var extIndex = file.originalname.lastIndexOf('.');
	var extension = (extIndex < 0) ? '' : file.originalname.substr(extIndex);
	// uuid is for generating unique filenames. 
	var fileName = uuid.v1() + extension;
	var destPath = 'uploads/' + fileName;
	var destPathThumb = 'uploads/tm_' + fileName;
	
	// Server side file type checker.
	if (contentType !== 'image/png' && contentType !== 'image/jpeg') {
	    fs.unlink(tmpPath);
	    return res.status(400).json({error:true, msg:'Unsupported file type.'});
	}
	if (file.size>10*1000*1000) {
	    fs.unlink(tmpPath);
	    return res.status(400).json({error:true, msg:'File too large'});
	}
	fs.rename(tmpPath, destPath, function(err) {
	    if (err) {
	        return res.status(400).json({error:true, msg:'Image is not saved'});
	    }
	    //console.log(destPath)
	    //console.log(destPathThumb)
	    im.convert([destPath, '-auto-orient', '-resize', '200x200^', '-gravity', 'Center', '-extent', '200x200', destPathThumb], 
		function(err, stdout){
		  if (err) throw err;
		  //console.log('stdout:', stdout);
		  if (err){
		  	console.log(err);
		  }
		  //console.log('Image resized');
		    var endpoint = 'user/';
		    //console.log("uploading original")
		    client.scp(destPath, static_server_ssh+':'+static_server_path+'/'+endpoint, function(err) {
			    // file sent!
				//console.log("uploaded original")
			    fs.unlink(destPath);
			    
			})
		    
		    //console.log("uploading thumb")
		    client.scp(destPathThumb, static_server_ssh+':'+static_server_path+'/'+endpoint, function(err) {
			    // file sent!
				//console.log("uploaded thumb")
			    fs.unlink(destPathThumb);
			})
		    return res.json({error:false, path:'/files/'+endpoint + fileName, position: req.body.position});
		});
	});
});
    
    
router.route('/upload/video')
    .post(isAuthenticated, upload.single('image'), function (req, res, next) {
	    
	    
	var uuid = require('uuid')
	var fs = require('fs')
	var client = require('scp2')
	// req.file is the `avatar` file
	// req.body will hold the text fields, if there were any
	var file = req.file;
	//console.log(req.body.position)
	//console.log(file);
	var contentType = file.mimetype;
	var tmpPath = file.path;
	var extIndex = file.originalname.lastIndexOf('.');
	var extension = (extIndex < 0) ? '' : file.originalname.substr(extIndex);
	// uuid is for generating unique filenames. 
	var fileName = uuid.v1() + extension;
	var destPath = 'uploads/' + fileName;
	
	// Server side file type checker.
	if (contentType !== 'video/mp4' ) {
	    fs.unlink(tmpPath);
	    return res.status(400).json({error:true, msg:'Unsupported file type.'});
	}
	if (file.size>20*1000*1000) {
	    fs.unlink(tmpPath);
	    return res.status(400).json({error:true, msg:'File too large'});
	}
	fs.rename(tmpPath, destPath, function(err) {
	    if (err) {
	        return res.status(400).json({error:true, msg:'Video is not saved'});
	    }
	    console.log(destPath)
	    var endpoint = 'user/video/';
	    //console.log("uploading original")
	    client.scp(destPath, static_server_ssh+':'+static_server_path+'/'+endpoint, function(err) {
		    // file sent!
			console.log("uploaded original")
		    fs.unlink(destPath);
		    
		})
		
		
		Product.findById(req.body.product_id, function(err, product) {
            if (err)
                res.send(err);
               
            var trade_id = req.body.trade_id
            if (typeof product.video_url != "object"){
	            product.video_url = {}
            }
            console.log(req.body.trade_id)
            product.video_url[trade_id] = 'https://hula.trading/files/'+endpoint + fileName;
            product.markModified('video_url');
            
			
			
			Trade.findById( trade_id , function(err, trade) {
				if (trade) {
					var uid = (trade.other_id != req.decoded._doc._id)? trade.other_id : trade.owner_id;
		    		getUserName(req.decoded._doc._id, function (uname){
						createNotification(uid, req.decoded._doc._id, 'trade', '@'+uname+' has uploaded a new video proof. Check it out!');
		    		});
		        }
		    });
            
            product.save();
            
            
			return res.json({error:false, path:'/files/'+endpoint + fileName, product_id: req.body.product_id});
        });
	    
	});
});
    
    
//////////////////////////////////////
///
///   NOTIFICATION MANAGEMENT
///
/////////////////////////////////////

    
router.route('/notifications')
    .get(isAuthenticated, function(req, res) {
	    console.log(req.decoded);
        Notification.find({to_id: req.decoded._doc._id}).sort({date: -1}).limit(100).exec(function(err, notifications) {
            if (err)
                res.send(err);
			
			//req.decoded._doc._id;
            res.json(notifications);
        });
    });
    
    
router.route('/notifications/:notification_id')
    .get(isAuthenticated, function(req, res) {
        Notification.findById(req.params.notification_id, function(err, notification) {
            if (err)
                res.send(err);
			
			
			notification.is_read = true;
			
			notification.save(function(err) {

            	res.json({ message: 'Notification updated' });
        	});
        });
    });
    
    
router.route('/notifications/delete/:notification_id')
    .get(isAuthenticated, function(req, res) {
        Notification.findById(req.params.notification_id, function(err, notification) {
            if (err)
                res.send(err);
			
			notification.is_read = true;
			notification.status = "deleted";
			notification.save(function(err) {
            	res.json({ message: 'Notification updated' });
        	});
        });
    });

//	    createNotification('58f52d7a5a7937511d1a74c8', '0', 'normal', 'Esta es una notificación normal')
//	    createNotification('58f52d7a5a7937511d1a74c8', '58ec0cd5b585b13ce682721f', 'chat', 'Respuesta al chat')


function createNotification(userId, fromUserId, type, text, nopush){
	var now = new Date();
	var today = now.getDate();
	var hash = "" + userId + fromUserId + type + text + today;
	
    Notification.find({'hash':hash}, function(errn, nots) {
	
		if (nots.length == 0){
			var notification = new Notification();
		    notification.from_id = fromUserId;
		    notification.to_id = userId;
		    notification.type = type;
		    notification.text = text;
		    notification.date = now;
		    notification.status = 'new';
		    notification.is_read = false;
		    notification.hash = hash;
		    
		    notification.save(function(err) {
		        if (err)
		            res.send(err);
		            
		        if ( (nopush != undefined) && (nopush == true ) ) {
			        return
		        }
		        
		        User.findById(userId, function(err, user) {
		            if (err)
		                console.log(err);
						
					if (user){
						if ((user.push_device_id!= undefined) && (user.push_device_id.length>1)){
							sendPushNotification(text, user.push_device_id);
						} else {
							console.log("Notification. Device ID not present " + userId);
						}
					} else {
						console.log("Notification. User not found: " + userId);
					}
		        });
		        //console.log("Notification created! User:" + userId);
		    });
	    }
    });
}

function sendPushNotification(message, deviceToken){
	var apn = require('apn');
	var options = {
	  cert: "/opt/hula-api/app/ssl/hula-push-certs.pem",
	  key: "/opt/hula-api/app/ssl/hula-push-certs.key",
	  production: true
	};
	
	var apnProvider = new apn.Provider(options);
	
	
	var note = new apn.Notification();
	
	
	note.expiry = Math.floor(Date.now() / 1000) + 3600*48; // Expires 48 hours from now.
	note.badge = 1;
	note.sound = "default";
	note.alert = message;
	note.payload = {'messageFrom': 'HULA'};
	note.topic = "trading.hula.hula";
	//console.log(note);
	//console.log(apnProvider);
	apnProvider.send(note, deviceToken).then( (result) => {
		console.log("Sent notificaiton: " + message)
		console.log(result.failed);
		//console.log(result);
	  // see documentation for an explanation of result
	});
	//apn.Provider.shutdown()
}

function notifyOtherUsers(uid){
	Trade.find({status: {$nin:['ended', 'closed', 'review', 'pending'] },  $or:[ {owner_id: uid}, {other_id: uid} ]}, function(err, trades) {
            
		if (trades) {
			getUserName(uid, function (uname){
		        //console.log(trades);
			    for ( tr in trades ){
		            var item = trades[tr];
		            if (item.owner_id == uid){
			            createNotification(item.other_id, uid, 'trade', '@'+uname+' has uploaded new products. Check them out!');
		            } else {
			            createNotification(item.owner_id, uid, 'trade', '@'+uname+' has uploaded new products. Check them out!');
		            }
		        }
	        });
        }
        
    });
}
    
//////////////////////////////////////
///
///   FEEDBACK 
///
/////////////////////////////////////


router.route('/feedback')
    .post(isAuthenticated, function(req, res) {
	    
	    
        var feedback = new Feedback();
        feedback.trade_id = req.body.trade_id;
        feedback.user_id = req.body.user_id;
        feedback.giver_id = req.decoded._doc._id;
        feedback.date = new Date();
        feedback.comments = req.body.comments;
        feedback.val = req.body.val;
        feedback.status = 'new';
        
        feedback.save(function(err) {
            if (err)
                res.send(err);

            res.json({ message: 'Feedback saved!' });
        });
        
    });




    
//////////////////////////////////////
///
///   CATEGORIES MANAGEMENT
///
/////////////////////////////////////


router.route('/categories')
    .post(function(req, res) {
        var category = new Category();
        category.name = req.body.name;
        category.description = req.body.description;
        category.slug = req.body.slug;
        category.icon = req.body.icon;
        category.status = req.body.status;
        category.order = req.body.order;
        category.num_products = 0;
        category.save(function(err) {
            if (err)
                res.send(err);

            res.json({ message: 'Category created!' });
        });
        
    })
    .get(function(req, res) {
        Category.find(function(err, categories) {
            if (err)
                res.send(err);

            res.json(categories);
        });
    });





//////////////////////////////////////
///
///   USER AND SIGNUP MANAGEMENT
///
/////////////////////////////////////


router.route('/signup')
    .post(function(req, res) {
	    
	    
        User.findOne({ email: req.body.email }).exec( function(err, user) {
	    
	    	if (user){
            	res.json({ message: 'User already exists! Please login instead of creating a new user.', token:"", userId:user.id });
	    	} else {
		    	var user = new User();
		        var salt = sha256(secret + Math.random()).substr(0, 20);
		        //console.log(salt);
		        
		        user.nick = req.body.nick;
		        user.lname = req.body.lname;
		        user.name = req.body.name;
		        user.email = req.body.email;
		        user.feedback_count = 0;
		        user.feedback_points = 0;
		        user.trades_started = 0;
		        user.trades_finished = 0;
		        user.trades_closed = 0;
		        user.max_trades = 3;
		        user.last_login = new Date();
		        user.signup_date = new Date();
		        user.type = 'normal';
		        user.image = '';
		        user.status = 'pending';
		        user.salt = salt;
		        user.push_device_id = req.body.push_device_id
		        user.pass = sha256(req.body.pass + salt);
		        
		        var date = new Date();
				var em_token = sha256(secret + req.params.userId + date.getDate()).substr(0, 20);
				user.em_token = em_token;
				
		        user.save(function(err, user) {
		            if (err)
		                res.send(err);
		                
			        var static_user = user.toJSON();
			        static_user._doc = user.toJSON();
			        var token = jwt.sign(static_user, secret, {
		        		expiresIn: "665d" // expires in 1 year
			        });
			        
		            res.json({ message: 'User created!', token:token, userId:user.id });
		            
			        send_welcome_message(user.id, user.email, em_token);
			        
			        
			        
					fixPushDevices(user);
		        });
	    	}
	    });
    });
    
    
router.route('/users')
	.get(isAuthenticated, function(req, res) {
        User.find(function(err, users) {
            if (err)
                res.send(err);

			//console.log(req.decoded._doc._id);
            res.json(users);
        });
    });
    
router.route('/users/:userId/image')
	.get(function(req, res) {
		if (req.params.userId != 0){
			User.findById(req.params.userId, function(err, user) {
				if (err){
				    res.redirect("https://hula.trading/files/user/nope_hula.jpg");
					return 
				}
				    
	            if (user){
	            	res.redirect(user.image);
				} else {
				    res.redirect("https://hula.trading/files/user/nope_hula.jpg");
				}
			});
		} else {
			res.redirect("https://hula.trading/files/user/nope_hula.jpg");
		}
	});
router.route('/users/:userId/nick')
	.get(function(req, res) {
		User.findById(req.params.userId, function(err, user) {
			if (err)
                res.send(err);
			    
            if (user){
            	res.json({ nick:user.nick });
			} else {
				res.json({ message: 'User not found!' });
			}
		});
	});
	
router.route('/users/validatenick/:nick')
	.get(function(req, res) {
		User.find({ nick : req.params.nick }, function(err, user) {
			if (err)
                res.send(err);
			    
            if (user.length>0){
            	res.json({ user: 'found' });
			} else {
				res.json({ user: 'not found' });
			}
		});
	}); 
	
router.route('/.well-known/acme-challenge/:token')
	.get(function(req, res) {
		
		// la segunda parte de la respuesta cambia cada vez que se llama al certbot:
		
		res.send(req.params.token + '.4kMusKsFkHQshIHKUsGcYZbx2idqGTQ99eqEYcc9BMQ');
	});

router.route('/me')
	.get(isAuthenticated, function(req, res) {
        User.findById(req.decoded._doc._id).select('+fb_token +li_token +tw_token +gp_token +em_token').exec( function(err, user) {
            if (err)
                res.send(err);
            var full_response = {user: user}
	            if (err)
	                res.send(err);
				
				if (user){
					Feedback.find({'user_id':user.id}, function(err, feedback) {
		            	full_response.feedback = feedback;
						Product.find({'owner_id':user.id, status: {'$nin':['traded', 'deleted'] } }, function(err, products) {
			            	full_response.products = products;
							res.json(full_response);
		    			});
	    			});
				} else {
					res.json({ message: 'No user '+req.params.userId+' found!' });
				}
        });
        //keep track of user feedback
		update_user_feedback(req.params.userId);
    })
router.route('/users/:userId')
	.get(function(req, res) {
        User.findById(req.params.userId).select('+fb_token +li_token +tw_token +em_token').exec( function(err, user) {
            if (err)
                res.send(err);
            if ((user.fb_token != undefined) && (user.fb_token.length > 5 )) user.fb_token = 'verified_user';
            if ((user.li_token != undefined) && (user.li_token.length > 5 )) user.li_token = 'verified_user';
            if ((user.tw_token != undefined) && (user.tw_token.length > 5 )) user.tw_token = 'verified_user';
            if ((user.em_token != undefined) && (user.em_token.length > 5 )) user.em_token = 'verified_user';
            var full_response = {user: user}
            if (err)
                res.send(err);
			
			if (user){
				Feedback.find({'user_id':user.id}, function(err, feedback) {
	            	full_response.feedback = feedback;
					Product.find({'owner_id':user.id, status: {'$nin':['traded', 'deleted'] } }, function(err, products) {
		            	full_response.products = products;
						res.json(full_response);
	    			});
    			});
			} else {
				res.json({ message: 'No user ' + req.params.userId + ' found!' });
			}
        });
        //keep track of user feedback
		update_user_feedback(req.params.userId);
    }).put(function(req, res) {
        User.findById(req.params.userId, function(err, user) {
            if (err)
                res.send(err);
            if (user){
	            if (req.body.name){
		            user.name = req.body.name;
	            }
	            if (req.body.nick){
		            user.nick = req.body.nick;
	            }
	            if (req.body.email){
		            user.email = req.body.email;
	            }
	            if (req.body.bio){
		            user.bio = req.body.bio;
	            }
	            if (req.body.location_name){
		            user.location_name = req.body.location_name;
	            }
	            if (req.body.pass){
		            //user.pass = req.body.pass;
	            }
	            if (req.body.image){
		            user.image = req.body.image;
	            }
	            if (req.body.zip){
		            user.zip = req.body.zip;
	            }
	            if (req.body.lat && req.body.lng){
		            //console.log("Updating location");
		            //console.log(req.body.lat);
		            user.location = [ req.body.lat, req.body.lng ];
	            }
	            if (req.body.twtoken){
		            user.tw_token = req.body.twtoken;
	            }
	            if (req.body.litoken){
		            user.li_token = req.body.litoken;
	            }
	            if (req.body.fbtoken){
		            user.fb_token = req.body.fbtoken;
	            }
	            if (req.body.push_device_id){
					user.push_device_id = req.body.push_device_id
	            }
	            if (req.body.max_trades){
					user.max_trades = req.body.max_trades
	            }
	            user.save(function(err, user) {
		            if (err)
		                res.send(err);
		                
		            res.json({ message: 'User updated!' });
		            
					fixPushDevices(user);
		        });
            }
        });
        //keep track of user feedback
		update_user_feedback(req.params.userId);
    });
    
router.route('/users/resend/:userId').put(function(req, res) {
    User.findById(req.params.userId, function(err, user) {
        if (err)
            res.send(err);
        if (user){
            var date = new Date();
			var token = sha256(secret + req.params.userId + date.getDate()).substr(0, 20);
			user.em_token = token;
			user.save(function(err, user) {
	            if (err)
	                res.send(err);
	                
	        	send_validation_message(req.params.userId, user.email, token);
		        res.json({ message: 'Message sent!' });
	        });
        }
    })
});

router.route('/users/report/:userId').get(isAuthenticated, function(req, res) {
    User.findById(req.params.userId, function(err, user1) {
        if (err)
            res.send(err);
            
        if (user1){
	        User.findById(req.decoded._doc._id, function(err2, user2) {
		        if (err2)
		            res.send(err2);
		        if (user2){
			        
		        	send_report_message(user1.email, 'hello@hula.trading', user2.email);
			        res.json({ message: 'Message sent!' });
			        
			        var feedback = new Feedback();
			        feedback.trade_id = "0000000000";
			        feedback.user_id = req.params.userId;
			        feedback.giver_id = req.decoded._doc._id;
			        feedback.date = new Date();
			        feedback.comments = "User reported";
			        feedback.val = 0;
			        feedback.status = 'new';
			        
			        feedback.save( function(err) {} );
			        
			        
		        } else {
			        res.json({ message: 'error. Reporter user does not exist' });
		        }
		    });
		    
		    
        } else {
	        res.json({ message: 'error. Reported user does not exist' });
        }
    })
});

router.route('/products/report/:prodId').get(isAuthenticated, function(req, res) {
    Product.findById(req.params.prodId, function(err, prod1) {
        if (err)
            res.send(err);
            
        if (prod1){
	        User.findById(req.decoded._doc._id, function(err2, user2) {
		        if (err2)
		            res.send(err2);
		        if (user2){
			        
		        	send_report_product_message(req.params.prodId, 'hello@hula.trading', user2.email, prod1.title);
			        res.json({ message: 'Message sent!' });
			        
		        } else {
			        res.json({ message: 'error. Reporter user does not exist' });
		        }
		    });
        } else {
	        res.json({ message: 'error. Reported product does not exist' });
        }
    })
});


router.route('/users/resetmail/:email').get(function(req, res) {
    User.find({ email: req.params.email }, function(err, users) {
        if (err)
            res.send(err);
        if (users[0]){
	        user = users[0];
            var date = new Date();
			var token = sha256(secret + user._id + date.getDate()).substr(0, 20);
			user.em_token = token;
			user.save(function(err, user) {
	            if (err)
	                res.send(err);
	        	send_reset_message(user._id, req.params.email, token);
		        res.json({ message: 'Message sent!' });
	        });
        }
    })
});

router.route('/users/activate/:userId/:token').get(function(req, res) {
        User.findById(req.params.userId).select('em_token').exec( function(err, user) {
            if (err)
                res.send(err);
	        if (user){
	            if (user.em_token == req.params.token){
					user.status = "verified";
					user.save(function(err, user) {
			            if (err)
			                res.send(err);
			            res.redirect("https://hula.trading/");    
				        //res.json({ message: 'User verified!' });
			        });
		        } else {
				    res.json({ message: 'Token is not valid!' });
		        }
	        } else {
				res.json({ message: 'User ID invalid' });
	        }
	    })
});

router.route('/users/resetpass/:userId/:token')
	.get(function(req, res) {
        User.findById(req.params.userId).select('em_token').exec( function(err, user) {
            if (err)
                res.send(err);
	        if (user){
	            if (user.em_token == req.params.token){
			        res.redirect("https://hula.trading/password-reset.html#"+req.params.userId+"."+user.em_token);  
		        } else {
				    res.json({ message: 'Token is not valid!' });
		        }
	        } else {
				res.json({ message: 'User ID invalid' });
	        }
	    })
	})
	.post(function(req, res) {
        User.findById(req.params.userId).select('em_token salt').exec( function(err, user) {
            if (err)
                res.send(err);
	        if (user){
	            if (user.em_token == req.params.token){
			        if (req.body.pass.length > 4){
				        user.pass = sha256(req.body.pass + user.salt);
				        user.save(function(err, user) {
				            if (err)
				                res.send(err);
				                
					        res.json({ message: 'ok'});
				        });
			        } else {
				    	res.json({ message: 'Password too short!'});
			        }
		        } else {
				    res.json({ message: 'Token is not valid!'});
		        }
	        } else {
				res.json({ message: 'User ID invalid' });
	        }
	    })
	});


router.route('/users/resetpass/:userId')
	.post(function(req, res) {
        User.findById(req.params.userId).select('pass salt').exec( function(err, user) {
            if (err)
                res.send(err);
	        if (user){
				if (user.pass == sha256(req.body.current_pass + user.salt)) {
			        if (req.body.new_pass.length > 3){
				        user.pass = sha256(req.body.new_pass + user.salt);
				        user.save(function(err, user) {
				            if (err)
				                res.send(err);
					        res.json({ message: 'ok'});
				        });
			        } else {
				    	res.json({ message: 'Password too short!'});
			        }
		        } else {
				    res.json({ message: 'Old password is not valid!'});
		        }
	        } else {
				res.json({ message: 'User ID invalid' });
	        }
	    })
	});


function fixPushDevices(user){
	User.find({ push_device_id: user.push_device_id }, function (err, users){
		if (err)
                return;
		console.log("Looking for duplicate push: " + user.push_device_id);
        //console.log(users)
        if ( users.length > 1 ){
		    for ( us in users ){
				    //console.log("checking dupl: " + users[us]._id + " and " + user.id);
			    if (users[us]._id != user.id){
				    console.log("found duplicate push: " + users[us]._id + " and " + user.id);
				    console.log(us)
				    users[us].push_device_id = "";
				    users[us].save()
			    }
			}
		}
	})
}

function send_validation_message(id, email, token){
	var emails    = require('./app/controllers/emails');
	
	emails.getTemplate("validation-email", function (template){
		data = {
			to: email, 
			user_id: id, 
			subject: "Validate your HULA Account", 
			activation_url: "https://api.hula.trading/v1/users/activate/"+id+"/"+token
		}
		//console.log(data);
		emails.sendTemplate(data, template);
	});	
}

function send_welcome_message(id, email, token){
	var emails    = require('./app/controllers/emails');
	
	emails.getTemplate("welcome-email", function (template){
		data = {
			to: email, 
			user_id: id, 
			subject: "Validate your HULA Account", 
			activation_url: "https://api.hula.trading/v1/users/activate/"+id+"/"+token
		}
		//console.log(data);
		emails.sendTemplate(data, template);
	});	
}

function send_reset_message(id, email, token){
	var emails    = require('./app/controllers/emails');
	
	emails.getTemplate("password-recovery", function (template){
		data = {
			to: email, 
			user_id: id, 
			subject: "You requested a new password for your account, right? Let’s get a new one that will be unforgettable", 
			activation_url: "https://api.hula.trading/v1/users/resetpass/"+id+"/"+token, 
			user_name: email
		}
		//console.log(data);
		emails.sendTemplate(data, template);
	});
}

function send_report_message(m1, email, m2){
	var emails    = require('./app/controllers/emails');
	
	emails.getTemplate("reported-user", function (template){
		data = {
			to: email, 
			subject: m1 + " user has been reported", 
			reported_user: m1, 
			reporter_user: m2
		}
		//console.log(data);
		emails.sendTemplate(data, template);
	});
}
function send_report_product_message(m1, email, m2, tit){
	var emails    = require('./app/controllers/emails');
	
	emails.getTemplate("reported-product", function (template){
		data = {
			to: email, 
			subject: m1 + " product has been reported", 
			reported_product: m1, 
			reporter_user: m2,
			product_title: tit
		}
		//console.log(data);
		emails.sendTemplate(data, template);
	});
}
    
router.post('/authenticate', function(req, res) {
  // find the user
  User.findOne({ email: req.body.email }).select("+pass +salt").exec( function(err, user) {

    if (err) throw err;

    if (!user) {
      res.json({ success: false, message: 'We can’t find your user name. Try again.' });
    } else if (user) {
      if (user.pass != sha256(req.body.pass + user.salt)) {
        res.json({ success: false, message: 'Ops! It looks like it’s a wrong password.' });
      } else {
        // create a token
        var static_user = user.toJSON();
        static_user._doc = user.toJSON();
        var token = jwt.sign(static_user, secret, {
          expiresIn: "665d" // expires in 1 year
        });
        
        // update last login
        user.last_login = new Date();
        user.save(function(err) {});
        
        
        res.json({
          success: true,
          message: 'ok',
          token: token,
          userId: user.id,
          userNick: user.nick,
          userName: user.name,
          userEmail: user.email,
          userBio: user.bio,
          userPhotoURL: user.image,
          userLocationName: user.location_name
        });
      }
    }
  });
});

router.post('/fbauth', function(req, res) {
  // find the user
  
  var graph = require('fbgraph');
  graph.setAccessToken(req.body.fbtoken);
  graph.get("me/?fields=name,email,picture", function(err, response) {
        // returns the post id
        console.log(response); // { id: xxxxx}
        
        if ((response.email == "") || (response.email == null) || (response.email == undefined)){
	        response.email = response.nick + "@hula.trading";
        }
        
        User.findOne({ $or: [ { email: response.email }, { fb_token: req.body.fbtoken } ]}).select("+pass +salt").exec( function(err, user) {
	        
			if (!user) {
				// does not exist. Create new user
				
				var user = new User();
		        var salt = sha256(secret + Math.random()).substr(0, 20);
		        //console.log(salt);
		        
		        user.nick = response.name;
		        user.lname = '';
		        user.name = response.name;
		        user.email = response.email;
		        user.last_login = new Date();
		        user.signup_date = new Date();
		        user.type = 'normal';
		        user.image = response.picture.data.url;
		        user.status = 'pending';
		        user.fb_token = req.body.fbtoken;
		        user.salt = salt;
		        user.pass = sha256(req.body.pass + salt);
		        
		        
		        var static_user = user.toJSON();
		        static_user._doc = user.toJSON();
		        var token = jwt.sign(static_user, secret, {
	        		expiresIn: "665d" // expires in 7 days
		        });
		        
		        user.save(function(err, user) {
		            if (err)
		                res.send(err);
		                
					user.userId = user.id;
		            res.json({ message: 'User created!', 
			            token:token, 
			            userId:user.id,
						userNick: user.nick,
						userName: user.name,
						userEmail: user.email,
						userBio: user.bio,
						userPhotoURL: user.image,
						userLocationName: user.location_name,
						allUser: user
					});
		        });
			} else {
				// user exists. Log him in
			    // create a token
		        var static_user = user.toJSON();
		        static_user._doc = user.toJSON();
		        var token = jwt.sign(static_user, secret, {
		          expiresIn: "665d" // expires in 7 days
		        });
		        
		        // update last login
		        user.last_login = new Date();
		        user.token = token;
		        user.userId = user.id;
		        user.save(function(err, user) {
			        res.json({
			          success: true,
			          message: 'User logged in',
			          token: token,
			          userId: user.id,
			          userNick: user.nick,
			          userName: user.name,
			          userEmail: user.email,
			          userBio: user.bio,
			          userPhotoURL: user.image,
			          userLocationName: user.location_name,
			          allUser: user
			        });
			        
		        });
			}
	    });
    });
    
});


function isAuthenticated(req, res, next) {
    var token = req.body.token || req.query.token || req.headers['x-access-token'];
    //console.log(token);
	if (token) {
		jwt.verify(token, secret, function(err, decoded) {      
			if (err) {
				return res.json({ success: false, message: 'Failed to authenticate token.' });    
			} else {
				req.decoded = decoded;    
				next();
			}
		});
	} else {
    	res.json({ success: false, message: 'Authentication failed. No token.' });
		return false;
	}
}






//////////////////////////////////////
///
///   SETUP AND SERVER STARTUP
///
/////////////////////////////////////

// setup everything
app.use('/'+api_version, router);


// use this only for cert renewal
//app.use('', router);


// Start the server
var httpServer = http.createServer(app).listen(port, function(){
  console.log("Express http server listening on port " + port);
});
var httpsServer = https.createServer(ssl_options, app).listen(ssl_port, function(){
  console.log("Express https server listening on port " + ssl_port);
});









