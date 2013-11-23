//
//  ViewControllerPlayer.h
//  test01
//
//  Created by dev on 11/19/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Podcast.h"
#import "PodcastItem.h"

@interface ViewControllerPlayer : UIViewController

@property PodcastItem *podcastItem;
@property Podcast *podcast;

@end
