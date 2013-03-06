//
//  ItemsList.h
//  Places
//
//  Created by Yaroslav Obodov on 11/28/12.
//  Copyright (c) 2012 Yaroslav Obodov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SuperObject.h"

@interface ItemsList : SuperObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * vicinity;

@end
