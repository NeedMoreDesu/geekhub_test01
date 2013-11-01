//
//  ViewController.h
//  test01
//
//  Created by dev on 10/21/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Podcast.h"

@interface ViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate,
UITextFieldDelegate>
{
    Podcast *_podcast;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
