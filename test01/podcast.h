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

+ (void)downloadWithURL:(NSURL *)url
          errorHandler:(void (^) (NSString* title, NSString* message))errorHandler
        successHandler:(void (^) (Podcast* podcast))successHandler;

@end
