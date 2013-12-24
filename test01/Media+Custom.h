//
//  Media+Custom.h
//  test01
//
//  Created by dev on 12/24/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "Media.h"
#import "NSManagedObject+Helpers.h"

@interface Media (Custom)

- (NSURL*)url;
- (void)setUrl:(NSURL*)url;

@end
