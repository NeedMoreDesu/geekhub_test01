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
    GDataXMLDocument *_doc;
    NSArray *_items;
}

- (void)downloadPodcastWithURL:(NSURL *)URL
                  errorHandler:(void (^) (NSString *title, NSError *error))errorHandler
                successHandler:(void (^) ())successHandler;

- (NSInteger) getLength;
- (NSString*) getTitleAt:(NSInteger)row;
- (NSURL*) getImageURLAt:(NSInteger)row;
- (UITableViewCell*) changeCell:(UITableViewCell*)cell at:(NSInteger)row;

@end
