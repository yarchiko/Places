//
//  PlacesLoader.m
//  Places
//
//  Created by Yaroslav Obodov on 11/25/12.
//  Copyright (c) 2012 Yaroslav Obodov. All rights reserved.
//

#import "PlacesLoader.h"

#import "ASINetworkQueue.h"
#import "LoaderRequest.h"

static PlacesLoader *kSharedLoader = nil;

@implementation PlacesLoader

@synthesize networkQueue, reachability;

+ (PlacesLoader *)shared
{
	if (kSharedLoader == nil)
	{
		kSharedLoader = [[PlacesLoader alloc] init];
	}
	return kSharedLoader;
}

+ (BOOL)reachable
{
	NetworkStatus netStatus = [[PlacesLoader shared].reachability currentReachabilityStatus];
	switch (netStatus)
	{
		case ReachableViaWWAN:
		case ReachableViaWiFi:
		{
			return YES;
		}
		default:
		{
			break;
		}
	}
	return NO;
}

+ (BOOL)reachableWiFi
{
	NetworkStatus netStatus = [[PlacesLoader shared].reachability currentReachabilityStatus];
	return (netStatus == ReachableViaWiFi);
}

#pragma mark - Init

- (PlacesLoader *)init
{
	self = [super init];
	if (self)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self
																						 selector:@selector(reachabilityChanged:)
																								 name:kReachabilityChangedNotification
																							 object:nil];
		
		reachability = [[Reachability reachabilityWithHostName:REACHABILITY_HOST] retain];
		[reachability startNotifier];
		
		self.networkQueue = [ASINetworkQueue queue];
		[self.networkQueue setDelegate:self];
		[self.networkQueue setRequestDidFinishSelector:@selector(requestFinished:)];
		[self.networkQueue setRequestDidFailSelector:@selector(requestFailed:)];
		[self.networkQueue setQueueDidFinishSelector:@selector(queueFinished:)];
		[self.networkQueue go];
	}
	return self;
}

- (void)dealloc
{
	kSharedLoader = nil;
	
	[self.networkQueue cancelAllOperations];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[reachability dealloc];
	
	[super dealloc];
}

#pragma mark - Reachability
- (void)reachabilityChanged:(NSNotification* )note
{
	
}

+ (LoaderRequest *)requestPlacesListWithLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude
{
	NSString * requestString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=30000&sensor=false&key=AIzaSyBbxf2s-kSP1xlEcZxazs1FJ-OnwjEi5Ko",latitude,longitude];
	
	LoaderRequest *request = [[LoaderRequest requestWithURLString:requestString] retain];
	[[PlacesLoader shared].networkQueue addOperation:request];
	return request;
}

#pragma mark
#pragma mark - ASIHTTPQueue delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
	NSString *responseString = [request responseString];
	
	id sendObject = responseString;
	
	NSError *error	= nil;
	SBJsonParser *jsonParser = [[SBJsonParser new] autorelease];
	sendObject = [jsonParser objectWithString:(NSString *)sendObject error:&error];
	
	if (error) {
		DLog(@"Error in parsing!!! - %@", error);
		return;
	}
	
	NSArray *tempArray = [sendObject objectForKey:@"results"];
	
	if (tempArray && tempArray.count > 0)
	{
		[[CoreDataManager shared] updateObjectsForEntityName:@"ItemsList" withPropertyLists:tempArray andKeyForIdentifier:@"id"];
	}
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
	//	NSLog(@"Error %@", [request error]);
	if ([request error])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Fail."
																									 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
}

- (void)queueFinished:(ASINetworkQueue *)queue
{
	
}

@end