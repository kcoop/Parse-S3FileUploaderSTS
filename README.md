# Parse-S3FileUploaderSTS
Client and server code for uploading files directly to S3.

Running a Parse Server that uploads files to S3, and don't need them preprocessed? 
Wouldn't it be great if you could send them directly to S3, bypassing your server
and dropping its load considerably? 

Now you can! (Well, at least on iOS so far.) 

This project provides code for your server to offer up short term S3 write credentials to your client,
and a pluggable client controller for PFFile uploading that requests those credentials, then submits directly to S3 with them.

To use it, you'll need to perform a few steps:

1. Configure your S3 account for Secure Token Service (STS).
2. Create a cloud function on your Parse server that responds with an STS token and bucket information, 
using supplied code and a few environment settings.
3. Add a custom PFFileUploaderController to your Parse configuration at startup on your iOS client.

*Note: The code in this project uses STS as a simple solution similar to what Parse Server offers. 
Amazon also offers Cognito-based credentials, which could be implemented in a similar fashion if you
need user-level access control and more flexibility. Be aware Amazon charges for Cognito.*

## Configure STS

TODO - describe the role, group, user, and policies for this. There are guides on the web. Search for STS configuration.

## Create cloud function

1. Add the file server/aws-sts.js to your server, and register it as a cloud function 
like so:

    ```javascript
    Parse.Cloud.define("uploadsts", require('./aws-sts.js'));
    ```

2. Define the following environment variables, many of which will already
be defined if you've been using the parse-server S3 adapter. 

- S3_ACCESS_KEY - AWS access key.
- S3_SECRET_KEY - AWS secret key. 
- S3_PUT_ROLE - the name of the role you defined for STS.
- S3_ACCOUNT_ID - the account id that owns the S3_PUT_ROLE. 
- S3_BUCKET - the bucket you're writing to.
- S3_BASE_URL - the base URL of your files (Your URLs will be S3_BASE_URL/S3_BUCKET/filename).

## Add and register PFFileS3UploadController

1. Add the files from the iOS directory to your project.
2. Add the AWS SDK as a dependency, in whatever form suits you.
3. Add the following line to your Parse initialization:

**Objective C**

    ```objective-c
    
        [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
            ...
            configuration.fileUploadController = [[PFFileS3UploaderController alloc]init];
        }]];
     ```
 
**or Swift:**
 
     ```swift
    let configuration = ParseClientConfiguration {
        ...
        $0.fileUploadController = PFFileS3UploadController()
    }
    ```
