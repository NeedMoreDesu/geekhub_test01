//
//  Podcast+Custom.h
//  test01
//
//  Created by dev on 12/24/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "Podcast.h"
#import "NSManagedObject+Helpers.h"
#import "GDataXMLNode.h"

@interface Podcast (Custom)

+ (Podcast*)podcastWithXML:(GDataXMLDocument *)doc
                       url:(NSURL*)url
                     error:(NSError*)error;
+ (void)downloadPodcastWithURL:(NSURL*)url
                  errorHandler:(void (^) (NSString *title, NSString *message))errorHandler
                successHandler:(void (^) (Podcast *podcast))successHandler;

@end
