//
//  Podcast.h
//  test01
//
//  Created by dev on 11/23/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "GDataXMLNode.h"
#import <Foundation/Foundation.h>

@interface Podcast : NSObject

@property NSString *title;
@property NSArray *items;

+ (Podcast*)podcastWithXML:(GDataXMLDocument *)doc error:(NSError*)error;
+ (void)downloadPodcastWithURL:(NSURL*)url
                  errorHandler:(void (^) (NSString *title, NSString *message))errorHandler
                successHandler:(void (^) (Podcast *podcast))successHandler;

@end
