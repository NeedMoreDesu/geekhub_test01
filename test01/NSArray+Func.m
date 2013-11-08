//
//  NSArray+Func.m
//  test01
//
//  Created by dev on 11/8/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "NSArray+Func.h"

@implementation NSArray (Func)

- (NSArray *) mapWithBlockIndexed:(id (^) (NSUInteger idx, id item))block
{
    NSUInteger count = [self count];
    NSMutableArray *newArr = [[NSMutableArray alloc] initWithCapacity:count];
    NSUInteger idx;
    for (idx = 0; idx < count; idx++)
    {
        id item = [self objectAtIndex:idx];
        id newItem = block(idx, item);
        [newArr insertObject:newItem atIndex:idx];
    }
    return newArr;
}

- (NSArray *) map:(id (^) (id item))block
{
    return [self
            mapWithBlockIndexed: ^id(NSUInteger idx, id item)
            {
                return block(item);
            }];
}

- (NSArray *) mapWithSelector: (SEL)selector
{
    return [self map:^id(id item) {
        if([item respondsToSelector:selector])
            return [item performSelector:selector];
        else
            return item;
    }];
}
- (id) reduce:(id (^) (id accumulator, id item))block withAccumulator:(id)accumulator
{
    id acc = accumulator;
    for(id item in self)
    {
        acc = block(acc, item);
    }
    return acc;
}
- (id) reduce:(id (^) (id accumulator, id item))block
{
    id acc = [self firstObject];
    NSUInteger count = [self count];
    NSUInteger idx;
    for(idx = 1; idx < count; idx++)
    {
        id item = [self objectAtIndex:idx];
        acc = block(acc, item);
    }
    return acc;
}
- (NSArray *) filter:(BOOL (^) (NSUInteger idx, id item))block
{
    NSMutableArray * newArr = [[NSMutableArray alloc] init];
    NSUInteger count = [self count];
    NSUInteger idx;
    for(idx = 0; idx < count; idx++)
    {
        id item = [self objectAtIndex:idx];
        if(block(idx, item))
            [newArr addObject:item];
    }
    return newArr;
}

@end
