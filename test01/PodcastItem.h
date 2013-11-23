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

+ (NSArray*)podcastItemsWithXML:(GDataXMLDocument *)doc error:(NSError*)error;

@end
