//
//  STSCredentialsAndS3Info.h
//  Klikaklu
//
//  Created by Ken Cooper on 2/21/17.
//  Copyright © 2017 Ken Cooper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>

@interface STSCredentialsAndS3Info : NSObject
@property (strong,nonatomic) NSString *baseURL;
@property (strong,nonatomic) NSString *bucket;
@property (strong,nonatomic) AWSCredentials *credentials;
@end
