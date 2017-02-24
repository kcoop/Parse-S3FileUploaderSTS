//
//  NSString+MimeType.m
//  Klikaklu
//
//  Created by Ken Cooper on 2/21/17.
//  Copyright © 2017 Ken Cooper. All rights reserved.
//

#import "NSString+MimeType.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation NSString (MimeType)
-(NSString *)fileSuffixFromMimeType
{
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef _Nonnull)(self), NULL);
    return (__bridge_transfer NSString *)UTI;
}
@end
