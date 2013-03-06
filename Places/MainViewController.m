//
//  MainViewController.m
//  Habrahabr
//
//  Created by Yaroslav Obodov on 11/25/12.
//  Copyright (c) 2012 Yaroslav Obodov. All rights reserved.
//

#import "MainViewController.h"
#import "PlacesLoader.h"

#import "ItemsList.h"
#import "MainTableViewCell.h"

@implementation MainViewController

@synthesize fetchedResultsController;

- (id)init
{
	self = [super init];
	if (self)
	{
		if([CLLocationManager authorizationStatus]!= kCLAuthorizationStatusDenied)
    {
			if(!_locationManager)
			{
				_locationManager = [[CLLocationManager alloc] init];
				_locationManager.delegate = self;
				_locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
			}
			[_locationManager stopUpdatingLocation];
			[_locationManager startUpdatingLocation];
			
			[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateLocation) userInfo:nil repeats:YES];
    }
    else
		{
			MY_ALLERT(@"", @"Для определения местоположения необходимо включить геолокацию в настройках");
    }
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UIView *background = [[UIView alloc] init];
	background.backgroundColor = [UIColor lightGrayColor];
	background.frame = CGRectMake(0.0f, 0.0f, 320.0f, 420.0f);
	[self.view addSubview:background];
	[background release];
	
	table = [[[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped] autorelease];
	[table setDelegate:self];
	[table setDataSource:self];
	[self.view addSubview:table];
}

- (void) viewDidAppear: (BOOL) animated
{
	[super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

#pragma mark - Table view dataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.fetchedResultsController.fetchedObjects count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 92;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = [NSString stringWithFormat:@"%d",indexPath.row];
	
	MainTableViewCell *cell =  (MainTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell)
	{
		cell = [[[MainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		[cell createAllElements];
	}
	[cell setAllElements:[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row]];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
}

#pragma mark fethedResultsController

- (NSFetchedResultsController*) fetchedResultsController
{
	if (fetchedResultsController != nil)
	{
		fetchedResultsController.delegate = (id <NSFetchedResultsControllerDelegate>) self;
		return fetchedResultsController;
	}
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemsList" inManagedObjectContext:[CoreDataManager shared].managedObjectContext];
	[request setEntity:entity];
	
	[request setSortDescriptors:[NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"identifier" ascending:YES], nil]];
	
	fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[CoreDataManager shared].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	fetchedResultsController.delegate = (id <NSFetchedResultsControllerDelegate>) self;
	
	NSError *error = nil;
	
	if (![fetchedResultsController performFetch:&error])
	{
		//abort();
	}
	return fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	[table endUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	SAFE_KILL(fetchedResultsController);
	
	[table beginUpdates];
	[table reloadData];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
	
	switch(type)
	{
		case NSFetchedResultsChangeInsert:
			//			NSLog(@"Insert: [%i]", indexPath.row);
			break;
			
		case NSFetchedResultsChangeDelete:
			//			NSLog(@"Delete: [%i]", indexPath.row);
			break;
			
		case NSFetchedResultsChangeUpdate:
			//			NSLog(@"Update: [%i]", indexPath.row);
			break;
			
		case NSFetchedResultsChangeMove:
			//			NSLog(@"Move: [%i]", indexPath.row);
			break;
	}
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	_currentLocation = newLocation.coordinate;
	[_locationManager stopUpdatingLocation];
	
	[PlacesLoader requestPlacesListWithLatitude:_currentLocation.latitude andLongitude:_currentLocation.longitude];
}

-(void)updateLocation
{
	[_locationManager stopUpdatingLocation];
	[_locationManager startUpdatingLocation];
}

@end