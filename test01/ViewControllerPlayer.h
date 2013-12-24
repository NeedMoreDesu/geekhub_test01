//
//  ViewControllerPlayer.h
//  test01
//
//  Created by dev on 11/19/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PodcastItem+Custom.h"
#import "Podcast+Custom.h"
#import "Media+Custom.h"

@interface ViewControllerPlayer : UIViewController

@property PodcastItem *podcastItem;
@property Podcast *podcast;

@end
