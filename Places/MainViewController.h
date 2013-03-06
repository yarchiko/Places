//
//  MainViewController.h
//  Habrahabr
//
//  Created by Yaroslav Obodov on 11/25/12.
//  Copyright (c) 2012 Yaroslav Obodov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate,CLLocationManagerDelegate>

{
	UITableView                     * table;
	
	NSFetchedResultsController      * fetchedResultsController;
	
	CLLocationManager								* _locationManager;
	CLLocationCoordinate2D					_currentLocation;
}

@property (nonatomic,readonly) NSFetchedResultsController* fetchedResultsController;

@end
