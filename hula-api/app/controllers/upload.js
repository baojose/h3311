var uuid = require('uuid'),
multiparty = require('multiparty'),
fs = require('fs');

exports.postImage = function(req, res) {
    var form = new multiparty.Form();
    form.parse(req, function(err, fields, files) {
	    //console.log(fields);
	    //console.log(files);
        var file = files.file[0];
        var contentType = file.headers['content-type'];
        var tmpPath = file.path;
        var extIndex = tmpPath.lastIndexOf('.');
        var extension = (extIndex < 0) ? '' : tmpPath.substr(extIndex);
        // uuid is for generating unique filenames. 
        var fileName = uuid.uuidV1() + extension;
        var destPath = '/opt/hula/api/uploads/' + fileName;

        // Server side file type checker.
        if (contentType !== 'image/png' && contentType !== 'image/jpeg') {
            fs.unlink(tmpPath);
            return res.status(400).send('Unsupported file type.');
        }

        fs.rename(tmpPath, destPath, function(err) {
            if (err) {
                return res.status(400).send('Image is not saved:');
            }
            return res.json(destPath);
        });
    });
};