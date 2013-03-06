//
//  LoaderRequest.h
//  Habrahabr
//
//  Created by Yaroslav Obodov on 11/25/12.
//  Copyright (c) 2012 Yaroslav Obodov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

@interface LoaderRequest : ASIFormDataRequest

{
	id <NSObject> resultDelegate;
}

@property (nonatomic, retain) id <NSObject> resultDelegate;

@property (nonatomic, readonly) NSArray *postData;
@property (nonatomic, readonly) BOOL cancelled;

+ (LoaderRequest *)requestWithURLString:(NSString *)urlString;

- (void)setPostValues:(NSDictionary *)postValues;


@end