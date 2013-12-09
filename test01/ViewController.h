//
//  ViewController.h
//  test01
//
//  Created by dev on 10/21/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PodcastItem.h"
#import "Podcast.h"

@interface ViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate,
UITextFieldDelegate>

@property (nonatomic, strong) Podcast *podcast;

@end
