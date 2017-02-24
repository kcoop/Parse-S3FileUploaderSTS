//
//  ParseSTSS3CredentialsProvider.m
//  Klikaklu
//
//  Created by Ken Cooper on 2/21/17.
//  Copyright © 2017 Ken Cooper. All rights reserved.
//

#import "ParseSTSCredentialsAndS3InfoProvider.h"

@interface ParseSTSCredentialsAndS3InfoProvider()
@property (strong,nonatomic) STSCredentialsAndS3Info *cachedCredentialsAndS3Info;
@end

@implementation ParseSTSCredentialsAndS3InfoProvider

+(ParseSTSCredentialsAndS3InfoProvider *)sharedInstance
{
    //  Static local predicate must be initialized to 0
    static ParseSTSCredentialsAndS3InfoProvider *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ParseSTSCredentialsAndS3InfoProvider alloc] initWithRegion:AWSRegionUSEast1];
    });
    return sharedInstance;
}

-(id)initWithRegion:(AWSRegionType)regionType
{
    if (self = [super init]) {
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:regionType
                                                                             credentialsProvider:self];
        AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    }
    return self;
}

/*
 When we fetch the credentials, we also fetch the S3Info. So this is redundant with self.credentials, but
 returns a different result in task.result.
 */
-(BFTask<STSCredentialsAndS3Info *> *)credentialsAndS3Info
{
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    [[self credentials] continueWithBlock:^id _Nullable(AWSTask<AWSCredentials *> * _Nonnull t) {
        if (!t.error) {
            [tcs setResult:_cachedCredentialsAndS3Info];
        } else {
            [tcs setError:t.error];
        }
        return nil;
    }];
    return tcs.task;
}

#pragma mark AWSCredentialsProvider
- (AWSTask<AWSCredentials *> *)credentials
{
    if (self.cachedCredentialsAndS3Info == nil) {
        AWSTaskCompletionSource *tcs = [AWSTaskCompletionSource taskCompletionSource];
        [[PFCloud callFunctionInBackground:@"uploadsts" withParameters:@{}]
         continueWithBlock:^id _Nullable(BFTask * _Nonnull bfTask) {
             if (!bfTask.error) {
                 self.cachedCredentialsAndS3Info = [[STSCredentialsAndS3Info alloc]init];
                 self.cachedCredentialsAndS3Info.bucket = [bfTask.result objectForKey:@"bucket"];
                 self.cachedCredentialsAndS3Info.baseURL = [bfTask.result objectForKey:@"baseURL"];
                 self.cachedCredentialsAndS3Info.credentials = [[AWSCredentials alloc]
                     initWithAccessKey:[bfTask.result objectForKey:@"accessKeyId"]
                     secretKey:[bfTask.result objectForKey:@"secretAccessKey"]
                     sessionKey:[bfTask.result objectForKey:@"sessionToken"]
                     expiration:[NSDate dateWithTimeInterval:30*60 sinceDate:[NSDate date]]];
                 [tcs setResult:self.cachedCredentialsAndS3Info.credentials];
             } else {
                 [tcs setError:bfTask.error];
             }
             return nil;
         }];
        return tcs.task;
    } else {
        return [AWSTask taskWithResult:self.cachedCredentialsAndS3Info.credentials];
    }
}

- (void)invalidateCachedTemporaryCredentials
{
    self.cachedCredentialsAndS3Info = nil;
}
@end
