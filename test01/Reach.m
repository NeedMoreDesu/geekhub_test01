//
//  Reach.m
//  test01
//
//  Created by dev on 1/21/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "Reach.h"

@implementation Reach

- (BOOL)networkIsReachable
{
    NetworkStatus remoteHostStatus = [_reach currentReachabilityStatus];
    return remoteHostStatus != NotReachable;
}

-(Reach*)init
{
    if([super init])
    {
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
    }
    return self;
}

+(Reach*)sharedInstance
{
    static id shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

@end
