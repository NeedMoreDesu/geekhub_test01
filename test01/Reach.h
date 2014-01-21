//
//  Reach.h
//  test01
//
//  Created by dev on 1/21/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface Reach : NSObject

@property Reachability *reach;

- (Reach*)init;
+ (Reach*)sharedInstance;
- (BOOL)networkIsReachable;

@end
