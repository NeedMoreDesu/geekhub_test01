//
//  PodcastListViewController.h
//  test01
//
//  Created by dev on 1/21/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "ViewController.h"

@interface PodcastListViewController : ViewController
<UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate>

@property NSArray *podcasts;

@end
