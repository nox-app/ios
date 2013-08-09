//
//  ImagePost.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "ImagePost.h"

#import "Constants.h"
#import "NSDictionary+Util.h"

NSString * const kImagePostDidDownloadNotification = @"ImagePostDidDownloadNotification";

@implementation ImagePost

@synthesize image = m_image;

- (id)init
{
    if(self = [super init])
    {
        m_type = kImageType;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)a_dictionary
{
    if(self = [super initWithDictionary:a_dictionary])
    {
        m_type = kImageType;
        m_imageURL = [a_dictionary objectForKeyNotNull:@"image"];
        [self performSelectorInBackground:@selector(downloadImage) withObject:nil];
    }
    return self;
}

- (void)imageDownloadDidFinish
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kImagePostDidDownloadNotification object:self];
}

- (void)downloadImage
{
    m_image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[kNoxBase stringByAppendingString:m_imageURL]]]];
    [self performSelectorOnMainThread:@selector(imageDownloadDidFinish) withObject:self waitUntilDone:NO];
}

@end
