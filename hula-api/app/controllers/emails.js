


exports.sendMail = function(to, subject, body) {
	var helper = require('xxx').mail;
	var fromEmail = new helper.Email('xxx', 'xxx');
	var toEmail = new helper.Email(to);
	var content = new helper.Content('text/html', body);
	var mail = new helper.Mail(fromEmail, subject, toEmail, content);
	
	var sg = require('xxx')('xxxx');
	var request = sg.emptyRequest({
	  method: 'POST',
	  path: '/v3/mail/send',
	  body: mail.toJSON()
	});
	
	sg.API(request, function (error, response) {
	  if (error) {
	    console.log('Error response received');
	    //console.log(error);
		console.log(response.body.errors);
	  }
	  console.log('Mail sent: ' + response.statusCode);
	});
}


exports.sendTemplate = function(data, template) {
	var toEmail = data['to'];
	var content = template;
	//console.log(data);
	for (item in data){
		var k = "[" + item.toUpperCase() + "]";
		content = content.split(k).join(data[item]);
	}
	
	var subject = data['subject'];
	this.sendMail(toEmail, subject, content);
}

exports.getTemplate = function(name, do_callback){
	var https = require('https');
	//console.log(template_url);
	var options = {
	    host: 'hula.trading',
	    path: '/mail_templates/'+name+'.html',
	    agent: false
	}
	var request = https.request(options, function (res) {
	    var data = '';
	    res.on('data', function (chunk) {
	        data += chunk;
	    });
	    res.on('end', function () {
	        //console.log(data.toString());
			do_callback(data.toString());
	    });
	});
	request.on('error', function (e) {
	    console.log(e.message);
	});
	request.end();
}
