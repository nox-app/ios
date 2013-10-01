//
//  ImagePost.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "ImagePost.h"

#import "ASIHTTPRequest.h"
#import "Constants.h"
#import "NSDictionary+Util.h"

NSString * const kImagePostDownloadDidSucceedNotification = @"ImagePostDownloadDidSucceedNotification";
NSString * const kImagePostDownloadDidFailNotification = @"ImagePostDownloadDidFailNotification";

@implementation ImagePost

@synthesize image = m_image;
@synthesize imageIsDownloading = m_imageIsDownloading;

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
    }
    return self;
}

- (void)imageDownloadDidSucceed
{
    m_imageIsDownloading = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kImagePostDownloadDidSucceedNotification object:self];
}

- (void)imageDownloadDidFail
{
    m_imageIsDownloading = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kImagePostDownloadDidFailNotification object:self];
}

- (void)downloadImage
{
    m_imageIsDownloading = YES;
    if(m_imageURL)
    {
        //@todo(jdiprete): do something with the timeout interval
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:m_imageURL] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0];
        NSURLConnection * connection = [NSURLConnection connectionWithRequest:request delegate:self];
        [connection start];
    }
}

#pragma mark - NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)a_connection didReceiveResponse:(NSURLResponse *)a_response
{
    m_imageDownloadBuffer = nil;
    if([a_response expectedContentLength] == NSURLResponseUnknownLength)
    {
        m_imageDownloadBuffer = [[NSMutableData alloc] init];
    }
    else
    {
        m_imageDownloadBuffer = [[NSMutableData alloc] initWithCapacity:[a_response expectedContentLength]];
    }
}

- (void)connection:(NSURLConnection *)a_connection didReceiveData:(NSData *)a_data
{
    [m_imageDownloadBuffer appendData:a_data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)a_connection
{
    m_image = [UIImage imageWithData:m_imageDownloadBuffer];
    [self imageDownloadDidSucceed];
    m_imageDownloadBuffer = nil;
}

- (void)connection:(NSURLConnection *)a_connection didFailWithError:(NSError *)a_error
{
    m_imageDownloadBuffer = nil;
    [self imageDownloadDidFail];
    NSLog(@"Request Failed with Error: %@", a_error);
}

@end
