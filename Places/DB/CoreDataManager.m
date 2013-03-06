#import "CoreDataManager.h"

@interface CoreDataManager()

@property (nonatomic, retain) NSArray *registredContexts;

- (void)changeModifyTimeInObjectsFromContext:(NSManagedObjectContext *)aContext;

- (void)someContextDidChanged:(NSNotification *)notification;

@end

@implementation CoreDataManager

@synthesize managerOperationQueue = _managerOperationQueue;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static NSUInteger kCountForUpdate = 50;

#pragma mark CoreDataManager life cycle
+ (CoreDataManager *)shared
{
	static CoreDataManager *kSharedDataManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		kSharedDataManager = [CoreDataManager new];
	});
	
	return kSharedDataManager;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		[self persistentStoreCoordinator];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_managerOperationQueue release];
	[_managedObjectContext release];
	[_managedObjectModel release];
	[_persistentStoreCoordinator release];
	[_registredContexts release];
	
	[super dealloc];
}

#pragma mark Work with objects in CoreData
- (id)objectForEntityName:(NSString *)entityName withIdentifier:(NSString *)identifier inContext:(NSManagedObjectContext *)context
{
	identifier = [identifier isKindOfClass:[NSNumber class]] ? [(NSNumber *)identifier stringValue] : identifier;
	identifier = [identifier isKindOfClass:[NSString class]] ? identifier : nil;
	
	NSManagedObject *object = nil;
	
	if (entityName && identifier && context)
	{
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
		NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setPredicate:predicate];
		[fetchRequest setEntity:entity];
		
		NSError *error = nil;
		NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
		
		if (fetchedObjects == nil || fetchedObjects.count == 0)
		{
			Class entityClass = NSClassFromString(entityName);
			NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
			object = [[entityClass alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
			[object setValue:identifier forKey:@"identifier"];
		}
		else
		{
			object = [[fetchedObjects lastObject] retain];
		}
		
		[fetchRequest release];
	}
	
	return object.autorelease;
}

- (void)updateObjectsForEntityName:(NSString *)entityName withPropertyLists:(NSArray *)propertyLists andKeyForIdentifier:(NSString *)key
{
	if (entityName && key && propertyLists && propertyLists.count > 0)
	{
		[self.managerOperationQueue addOperationWithBlock:^{
			
			NSManagedObjectContext *context = self.context;
			[self registerContext:context];
			
			NSAutoreleasePool *pool = [NSAutoreleasePool new];
			NSUInteger counter = 0;
			
			for (NSDictionary *propertyList in propertyLists)
			{
				id obj = [self objectForEntityName:entityName withIdentifier:[propertyList valueForKey:key] inContext:context];
				[obj setValuesForKeysWithDictionary:propertyList];
				
				counter ++;
				if (counter == kCountForUpdate)
				{
					[self saveContext:context];
					[pool drain];
					
					counter = 0;
					pool = [NSAutoreleasePool new];
				}
			}
			
			[self saveContext:context];
			[pool drain];
			
			[self removeContext:context];
		}];
	}
}

- (void)changeModifyTimeInObjectsFromContext:(NSManagedObjectContext *)aContext
{
	for (NSManagedObject *managedObject in aContext.registeredObjects)
	{
		if (managedObject.isUpdated || managedObject.isInserted)
		{
			[managedObject setValue:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"lastModify"];
		}
	}
}

- (void)removeDataOlderThanDate:(NSDate *)date
{
	if (date)
	{
		[self.managerOperationQueue addOperationWithBlock:^{
			
			if (self.persistentStoreCoordinator)
			{
				NSManagedObjectContext *context = [self context];
				[self registerContext:context];
				
				for (NSEntityDescription *entityDescription in self.managedObjectModel.entities)
				{
					NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityDescription.name];
					NSArray *entityManagedObjects = [context executeFetchRequest:fetchRequest error:nil];
					[fetchRequest release];
					
					for (NSManagedObject *managedObject in entityManagedObjects)
					{
						if ([managedObject respondsToSelector:@selector(lastModify)])
						{
							NSDate *lastModify = [NSDate dateWithTimeIntervalSince1970:[[managedObject valueForKey:@"lastModify"] doubleValue]];
							if ([lastModify compare:date] == NSOrderedAscending)
							{
								if ((![managedObject.entity.name isEqualToString:@"Checkin"]) && (![managedObject.entity.name isEqualToString:@"UserData"]))
								{
									[context deleteObject:managedObject];
								}
							}
						}
					}
				}
				
				NSError *savingError = nil;
				if ([context hasChanges] && ![context save:&savingError])
				{
					/*
					 Replace this implementation with code to handle the error appropriately.
					 
					 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
					 */
					DLog(@"Unresolved error %@, %@", savingError, [savingError userInfo]);
				}
				[self removeContext:context];
			}
		}];
	}
}

#pragma mark Actions with contexts
- (void)someContextDidChanged:(NSNotification *)notification
{
	NSMutableArray *contextListForLock = [NSMutableArray arrayWithArray:self.registredContexts];
	[contextListForLock filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %@", notification.object]];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		
		[contextListForLock makeObjectsPerformSelector:@selector(lock)];
		[self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
		[contextListForLock makeObjectsPerformSelector:@selector(unlock)];
	});
}

- (void)saveContext:(NSManagedObjectContext *)context
{
	NSError *error = nil;
	if (context != nil)
	{
		if ([context hasChanges])
		{
			[self changeModifyTimeInObjectsFromContext:context];
			
			if (![context save:&error])
			{
				// Replace this implementation with code to handle the error appropriately.
				// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				DLog(@"Unresolved error %@, %@", error, [error userInfo]);
			}
		}
	}
}

- (void)registerContext:(NSManagedObjectContext *)context
{
	if (context)
	{
		@try {
			
			if (!_registredContexts)
			{
				_registredContexts = [NSArray new];
			}
			
			if (![_registredContexts containsObject:context])
			{
				[[NSNotificationCenter defaultCenter] addObserver:self
																								 selector:@selector(someContextDidChanged:)
																										 name:NSManagedObjectContextDidSaveNotification
																									 object:context];
				
				NSMutableArray *mutArray = [[NSMutableArray alloc] initWithArray:_registredContexts];
				[mutArray addObject:context];
				[self setRegistredContexts:mutArray];
				[mutArray release];
			}
		}
		@catch (NSException *exception) {
			DLog(@"Не удалось добавить контекст.%@", exception.reason);
		}
	}
}

- (void)removeContext:(NSManagedObjectContext *)context
{
	if (context && _registredContexts && [_registredContexts containsObject:context])
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
		
		NSMutableArray *mutArray = [[NSMutableArray alloc] initWithArray:_registredContexts];
		[mutArray removeObject:context];
		[self setRegistredContexts:(mutArray.count > 0) ? mutArray : nil];
		[mutArray release];
	}
}

#pragma mark - Core Data stack
- (NSOperationQueue *)managerOperationQueue
{
	if (!_managerOperationQueue)
	{
		_managerOperationQueue = [NSOperationQueue new];
		[_managerOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
	}
	return _managerOperationQueue;
}

- (NSManagedObjectContext *)context
{
	NSManagedObjectContext *context = nil;
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil)
	{
		context = [[NSManagedObjectContext alloc] init];
		[context setPersistentStoreCoordinator:coordinator];
		
		context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
	}
	return context.autorelease;
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
	if (_managedObjectContext != nil)
	{
		return _managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil)
	{
		_managedObjectContext = [[NSManagedObjectContext alloc] init];
		[_managedObjectContext setPersistentStoreCoordinator:coordinator];
		
		_managedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
	}
	return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
	if (_managedObjectModel != nil)
	{
		return _managedObjectModel;
	}
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Places" withExtension:@"momd"];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (_persistentStoreCoordinator != nil)
	{
		return _persistentStoreCoordinator;
	}
	
	NSError *error = nil;
	NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Places.sqlite"];
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
	{
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible;
		 * The schema for the persistent store is incompatible with current managed object model.
		 Check the error message to determine what the actual problem was.
		 
		 
		 If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
		 
		 If you encounter schema incompatibility errors during development, you can reduce their frequency by:
		 * Simply deleting the existing store:
		 [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
		 
		 * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
		 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
		 
		 Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
		 
		 */
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:storeURL.path])
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Структура БД изменилась.\nВся закешированная информация была стерта."
																													message:nil
																												 delegate:nil
																								cancelButtonTitle:@"OK"
																								otherButtonTitles:nil, nil].autorelease;
			[alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
			
			[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
			
			for (NSString *key in [NSUserDefaults standardUserDefaults].dictionaryRepresentation)
			{
				[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
			}
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
			{
				DLog(@"Unresolved error %@, %@", error, [error userInfo]);
				abort();
			}
		}
	}
	
	return _persistentStoreCoordinator;
}

#pragma mark - Application's Dx`ocuments directory
// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
