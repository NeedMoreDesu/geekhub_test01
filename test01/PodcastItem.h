//
//  Podcast.h
//  test01
//
//  Created by dev on 11/1/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "GDataXMLNode.h"
#import <Foundation/Foundation.h>

@interface PodcastItem : NSObject
{
}

@property NSString *title;
@property NSURL *imageURL;
@property NSString *author;
@property NSArray *media;

+ (void)downloadItemsWithURL:(NSURL *)url
               errorHandler:(void (^) (NSString* title, NSString* message))errorHandler
             successHandler:(void (^) (NSArray* podcastItems))successHandler;

@end
