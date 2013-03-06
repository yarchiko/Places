//
//  ItemsList.m
//  Places
//
//  Created by Yaroslav Obodov on 11/28/12.
//  Copyright (c) 2012 Yaroslav Obodov. All rights reserved.
//

#import "ItemsList.h"

@implementation ItemsList

@dynamic name;
@dynamic icon;
@dynamic vicinity;

#pragma mark KVO
- (void)setValue:(id)value forKey:(NSString *)key
{
	key = [key isEqualToString:@"id"] ? @"identifier" : key;
	[super setValue:value forKey:key];
}

@end
