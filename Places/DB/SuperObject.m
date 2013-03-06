//
//  SuperObject.m
//  Places
//
//  Created by Yaroslav Obodov on 11/28/12.
//  Copyright (c) 2012 Yaroslav Obodov. All rights reserved.
//

#import "SuperObject.h"

@implementation SuperObject

@dynamic identifier;

#pragma mark KVO methods
- (id)valueForUndefinedKey:(NSString *)key
{
	return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	
}

- (BOOL)validateIdentifier:(id *)value error:(NSError **)error
{
	BOOL isValid = YES;
	if (*value && ![*value isKindOfClass:[NSString class]])
	{
		if ([*value isKindOfClass:[NSNumber class]])
		{
			*value = [(NSNumber *)*value stringValue];
		}
		else
		{
			*value = nil;
			isValid = NO;
		}
	}
	return isValid;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"identifier"])
	{
		[self validateValue:&value forKey:key error:nil];
	}
	[super setValue:value forKey:key];
}

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues
{
	[keyedValues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
	 {
		 [self setValue:obj forKey:key];
	 }];
}

@end