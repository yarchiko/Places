//
//  PlacesLoader.h
//  Places
//
//  Created by Yaroslav Obodov on 11/25/12.
//  Copyright (c) 2012 Yaroslav Obodov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@class ASINetworkQueue;
@class LoaderRequest;
@class Reachability;

@interface PlacesLoader : NSObject

{
	ASINetworkQueue                 *networkQueue;
	ASINetworkQueue                 *imagesQueue;
	Reachability                    *reachability;
}

@property (nonatomic, retain) ASINetworkQueue *networkQueue;
@property (nonatomic, assign, readonly) Reachability *reachability;

+ (PlacesLoader *)shared;
+ (BOOL)reachable;
+ (BOOL)reachableWiFi;

+ (LoaderRequest *)requestPlacesListWithLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude;

@end