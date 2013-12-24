//
//  Media.h
//  test01
//
//  Created by dev on 12/24/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PodcastItem;

@interface Media : NSManagedObject

@property (nonatomic, retain) NSNumber * seconds;
@property (nonatomic, retain) NSString * urlString;
@property (nonatomic, retain) PodcastItem *podcastItem;

@end
