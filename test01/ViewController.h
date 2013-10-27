//
//  ViewController.h
//  test01
//
//  Created by dev on 10/21/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "GDataXMLNode.h"
#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate,
UITextFieldDelegate,
NSURLConnectionDataDelegate>
{
    NSMutableData *_responseData;
    GDataXMLDocument *_doc;
    NSArray *_items;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
