//
//  LoaderRequest.m
//  Habrahabr
//
//  Created by Yaroslav Obodov on 11/25/12.
//  Copyright (c) 2012 Yaroslav Obodov. All rights reserved.
//

#import "LoaderRequest.h"

@implementation LoaderRequest

@synthesize resultDelegate;

- (LoaderRequest *)init
{
	self = [super init];
	if (self)
	{
		resultDelegate = nil;
	}
	return self;
}

- (void)dealloc
{
	[resultDelegate release];
	
	[super dealloc];
}

+ (LoaderRequest *)requestWithURLString:(NSString *)urlString
{
	LoaderRequest *request = [LoaderRequest requestWithURL:[NSURL URLWithString:urlString]];
	
	request.timeOutSeconds = 90.0f;
	[request addRequestHeader:@"User-Agent" value:@"Places Application 0.1"];
	
	return [request autorelease];
}

- (void)setPostValues:(NSDictionary *)postValues
{
	NSArray *keys = [postValues allKeys];
	for (NSString *key in keys)
	{
		[self addPostValue:[postValues objectForKey:key] forKey:key];
	}
}

- (NSArray *)postData
{
	return postData;
}

- (BOOL)cancelled
{
	return cancelled;
}

@end