//
//  PFFileS3UploaderController.m
//  Klikaklu
//
//  Created by Ken Cooper on 2/21/17.
//  Copyright © 2017 Ken Cooper. All rights reserved.
//

#import "PFFileS3UploaderController.h"
#import <AWSS3/AWSS3.h>
#import <Bolts/Bolts.h>
#import "ParseSTSCredentialsAndS3InfoProvider.h"
#import "NSString+MimeType.h"

@implementation PFFileS3UploaderController

-(BFTask<PFFileUploadResult *> *)uploadSourceFilePath:(NSString *)sourceFilePath
                                             fileName:(NSString *)fileName
                                             mimeType:(NSString *)mimeType
                                        sessionToken:(NSString * _Nonnull)sessionToken
                                    cancellationToken:(BFCancellationToken * _Nonnull)cancellationToken
                                        progressBlock:(PFProgressBlock)progressBlock
{
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    
    [[[ParseSTSCredentialsAndS3InfoProvider sharedInstance] credentialsAndS3Info]
        continueWithBlock:^id _Nullable(BFTask<STSCredentialsAndS3Info *> * _Nonnull credentialsTask) {
            if (!credentialsTask.error) {
                AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
                uploadRequest.bucket = credentialsTask.result.bucket;
                NSString *baseURL = credentialsTask.result.baseURL;
                NSString *key = [NSString stringWithFormat:@"%@_%@.%@",
                                      [[NSUUID UUID] UUIDString],
                                      fileName ? fileName : @"file",
                                      mimeType ? [mimeType fileSuffixFromMimeType] : @"bin"];
                uploadRequest.key = key;
                uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
                uploadRequest.contentType = mimeType;
                uploadRequest.body = [NSURL fileURLWithPath:sourceFilePath];
                uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (progressBlock) {
                            progressBlock((int)(100 * totalBytesSent/totalBytesExpectedToSend));
                        }
                    });
                };
                
                AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
                
                [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
                    if (!task.error) {
                        PFFileUploadResult *uploadResult = [[PFFileUploadResult alloc]init];
                        uploadResult.url = [NSString stringWithFormat:@"%@/%@", baseURL, key];
                        uploadResult.name = key;
                        [tcs setResult:uploadResult];
                    } else {
                        NSLog(@"Error uploading %@: %@", uploadRequest.key, task.error);
                        [tcs setError:task.error];
                    }
                    return nil;
                }];
            } else {
                [tcs setError:credentialsTask.error];
            }
            return nil;
        }];

    return tcs.task;
}
@end
