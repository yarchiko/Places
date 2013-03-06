//
//  MainTableViewCell.h
//  Habrahabr
//
//  Created by Yaroslav Obodov on 11/25/12.
//  Copyright (c) 2012 Yaroslav Obodov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemsList.h"
#import <QuartzCore/QuartzCore.h>
#import "EGOImageView.h"

@interface MainTableViewCell : UITableViewCell

{
	UILabel				*itemNameLabel;
	UILabel				*itemAddressLabel;
	EGOImageView	*iconImage;
}

- (void)createAllElements;
- (void)setAllElements:(ItemsList*)currentItem;

@end