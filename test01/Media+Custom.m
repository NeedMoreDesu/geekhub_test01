//
//  Media+Custom.m
//  test01
//
//  Created by dev on 12/24/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "Media+Custom.h"

@implementation Media (Custom)

- (NSURL*)url
{
    return [NSURL URLWithString:self.urlString];
}
- (void)setUrl:(NSURL*)url
{
    self.urlString = [url absoluteString];
}

@end
