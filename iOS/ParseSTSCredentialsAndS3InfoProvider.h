//
//  ParseSTSS3CredentialsProvider.h
//  Klikaklu
//
//  Created by Ken Cooper on 2/21/17.
//  Copyright © 2017 Ken Cooper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>
#import <Bolts/Bolts.h>
#import "STSCredentialsAndS3Info.h"

@interface ParseSTSCredentialsAndS3InfoProvider : NSObject <AWSCredentialsProvider>

+(ParseSTSCredentialsAndS3InfoProvider *)sharedInstance;

-(BFTask<STSCredentialsAndS3Info *> *)credentialsAndS3Info;

- (AWSTask<AWSCredentials *> *)credentials;
- (void)invalidateCachedTemporaryCredentials;
@end
