module.exports = function(request, response) {
    var AWS = require('aws-sdk');

    var sts = new AWS.STS({
        accessKeyId: process.env.S3_ACCESS_KEY,
        secretAccessKey: process.env.S3_SECRET_KEY,
        sslEnabled: true
    });

    var params = {
        RoleArn: 'arn:aws:iam::' + process.env.S3_ACCOUNT_ID + ':role/' + process.env.S3_PUT_ROLE,
        RoleSessionName: "User-" + request.user.id,
        DurationSeconds: 30*60
    };

    var credentials = {};

    sts.assumeRole(params, function (err, data) {
        if (err) {
            console.log(err, err.stack);
            response.error(err);
        } else {
            var credentials = data.Credentials;

            response.success({
                "bucket": process.env.S3_BUCKET,
                "baseURL" : process.env.S3_BASE_URL,
                "accessKeyId": credentials.AccessKeyId,
                "secretAccessKey" : credentials.SecretAccessKey,
                "sessionToken" : credentials.SessionToken
            });
        }
    });
};
