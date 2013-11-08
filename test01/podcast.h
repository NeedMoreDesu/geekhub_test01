//
//  Podcast.h
//  test01
//
//  Created by dev on 11/1/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "GDataXMLNode.h"
#import <Foundation/Foundation.h>
#import "UIImageView+WebCache.h"

@interface Podcast : NSObject
{
}

@property NSString *title;
@property NSURL *imageURL;

+ (void)downloadPodcastWithURL:(NSURL *)URL
                  errorHandler:(void (^) (NSString *title, NSError *error))errorHandler
                successHandler:(void (^) (NSArray *podcasts))successHandler;

- initWithTitle:(NSString*)title imageURL:(NSURL *)imageURL;
-(UITableViewCell*) changeCell:(UITableViewCell *)cell completeHandler:(void (^)(UIImage *image, NSError *error, SDImageCacheType cacheType))handler;

@end
