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
{
    NSArray *_podcasts;
    __weak IBOutlet UITextField *_textField;
    __weak IBOutlet UITableView *_tableView;
    Reachability* _reach;
}

- (BOOL)networkIsReachable
{
    NetworkStatus remoteHostStatus = [_reach currentReachabilityStatus];
    return remoteHostStatus != NotReachable;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _reach = [Reachability reachabilityForInternetConnection];
    [_reach startNotifier];
    _reach.unreachableBlock = ^(Reachability*reach)
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
    _reach.reachableBlock = ^(Reachability*reach)
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

    if(![self networkIsReachable])
        [_reach unreachableBlock](_reach);
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// text field
- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
    if(![self networkIsReachable])
    {
        [_reach unreachableBlock](_reach);
        return NO;
    }
    NSURL *url = [NSURL
                  URLWithString: [textField text]];
    [Podcast
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
     successHandler:^(NSArray *podcasts) {
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            _podcasts = podcasts;
                            [_tableView reloadData];
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
    return [_podcasts count];
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
    Podcast *podcast = [_podcasts objectAtIndex:row];
    return [podcast
            changeCell:cell
            completeHandler:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [tableView beginUpdates];
                           [tableView
                            reloadRowsAtIndexPaths:@[indexPath]
                            withRowAnimation:UITableViewRowAnimationNone];
                           [tableView endUpdates];
                       });
    }];
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
