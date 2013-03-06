//
//  MainTableViewCell.m
//  Habrahabr
//
//  Created by Yaroslav Obodov on 11/25/12.
//  Copyright (c) 2012 Yaroslav Obodov. All rights reserved.
//

#import "MainTableViewCell.h"

@implementation MainTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self)
	{
		
	}
	return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
	
	if(!newSuperview)
	{
		[iconImage cancelImageLoad];
	}
}

- (void)dealloc
{
	[iconImage release];
	
	[super dealloc];
}

- (void)createAllElements
{
	itemNameLabel = [[[UILabel alloc] init] autorelease];
	[itemNameLabel setNumberOfLines:2];
	[itemNameLabel setBackgroundColor:[UIColor clearColor]];
	[itemNameLabel setFont:[UIFont boldSystemFontOfSize:14]];
	[self.contentView addSubview:itemNameLabel];
	
	itemAddressLabel = [[[UILabel alloc] init] autorelease];
	[itemAddressLabel setNumberOfLines:0];
	[itemAddressLabel setBackgroundColor:[UIColor clearColor]];
	[itemAddressLabel setFont:[UIFont systemFontOfSize:12]];
	[self.contentView addSubview:itemAddressLabel];
	
	iconImage = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"placeholder.png"]];
	iconImage.frame = CGRectMake(214.0f, 15.0f, 71.0f, 71.0f);
	[self.contentView addSubview:iconImage];
}

- (void)setAllElements:(ItemsList*)currentItem
{
	itemNameLabel.text = currentItem.name;
	itemAddressLabel.text = currentItem.vicinity;
	
	CGSize constrainedSize = CGSizeMake(210.0f, 40.0f);
	
	CGSize sizeItemName = [itemNameLabel.text sizeWithFont:itemNameLabel.font constrainedToSize:constrainedSize];
	itemNameLabel.frame = CGRectMake(10.0f, 10.f, sizeItemName.width, sizeItemName.height);
	
	CGSize sizeItemAddress = [itemAddressLabel.text sizeWithFont:itemAddressLabel.font constrainedToSize:constrainedSize];
	itemAddressLabel.frame = CGRectMake(10.0f, y_offset(itemNameLabel), sizeItemAddress.width, sizeItemAddress.height);
	
	iconImage.imageURL = [NSURL URLWithString:currentItem.icon];
}

@end