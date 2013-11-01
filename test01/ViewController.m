//
//  ViewController.m
//  test01
//
//  Created by dev on 10/21/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "Reachability.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _podcast = [[Podcast alloc] init];
    Reachability* reach = [Reachability reachabilityForInternetConnection];
    [reach startNotifier];
    reach.unreachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc]
              initWithTitle:@"No connection"
              message:@""
              delegate:nil
              cancelButtonTitle:@"Ok"
              otherButtonTitles:nil]
             show];
        });
    };
    reach.reachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc]
              initWithTitle:@"Internet connection established"
              message:@""
              delegate:nil
              cancelButtonTitle:@"Ok"
              otherButtonTitles:nil]
             show];
        });
    };

    NetworkStatus remoteHostStatus = [reach currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable)
        [reach unreachableBlock](reach);
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// text field
- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
    NSURL *url = [NSURL
                  URLWithString: [textField text]];
    [_podcast
     downloadPodcastWithURL:url
     errorHandler:
     ^(NSString *title, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [[[UIAlertView alloc]
                             initWithTitle:title
                             message:[error description]
                             delegate:nil
                             cancelButtonTitle:@"Ok"
                             otherButtonTitles:nil]
                            show];
                       });
     }
     successHandler:^{
         dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [[self tableView] reloadData];
                        });
     }];
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

/// table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_podcast getLength];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    NSInteger row = [indexPath row];
    return [_podcast changeCell:cell at:row];
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"Imma here!");
//    UITouch *touch = [[event allTouches] anyObject];
//    if ([self.textField isFirstResponder] && [touch view] != self.textField) {
//        [self.textField resignFirstResponder];
//    }
//    [super touchesBegan:touches withEvent:event];
//}

@end
