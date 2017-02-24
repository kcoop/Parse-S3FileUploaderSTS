//
//  PFFileS3UploaderController.h
//  Klikaklu
//
//  Created by Ken Cooper on 2/21/17.
//  Copyright © 2017 Ken Cooper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/PFFileUploadController.h>

@interface PFFileS3UploaderController : NSObject <PFFileUploadController>
-(BFTask<PFFileUploadResult *> * _Nonnull)uploadSourceFilePath:(NSString * _Nonnull)sourceFilePath
                                             fileName:(NSString * _Nullable)fileName
                                             mimeType:(NSString * _Nullable)mimeType
                                         sessionToken:(NSString * _Nonnull)sessionToken
                                    cancellationToken:(BFCancellationToken * _Nonnull)cancellationToken
                                        progressBlock:(PFProgressBlock _Nonnull)progressBlock;
@end
