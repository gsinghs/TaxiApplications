//
//  AppDelegate.m
//  RiderApp
//
//  Created by Gursharan Singh on 30/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "SignUpViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FindATaxiViewController.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"
#import "CommonMethods.h"
#import "NSString+SBJSON.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController;
@synthesize latitudeVal;
@synthesize longitudeVal;
@synthesize mLocationManager;

- (void)dealloc
{
    [navigationController release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    UIViewController *viewController = nil;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"registeredOnServer"]) {
        viewController = [[FindATaxiViewController alloc] initWithNibName:@"FindATaxiViewController" bundle:nil];
        [[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(statusChange:) name:@"STATUS_REQUEST" object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(taxiFound:) name:@"TAXI_FOUND" object:nil];
    }
    else {
        viewController = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
    }
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
    self.navigationController.navigationBarHidden = YES;
    [viewController release];
    [self updateTheLocation];
    
    // Register for notifications
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound| UIRemoteNotificationTypeBadge)];  
    
    // Handle the notification at launch
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo != nil) {
        [self handleNotification:userInfo];
    }
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    [self performSelector:@selector(checkingStatusForOldRequests)];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // UALOG(@"APN device token: %@", deviceToken);
    // Updates the device token and registers the token with UA
    NSString* newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:newToken forKey:@"APNS_Token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)handleNotification: (NSDictionary *)userInfo {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    if ([[[userInfo valueForKey:@"aps"] valueForKey:@"alert"] isEqualToString:@"Taxi Found"]) {
         [[NSUserDefaults standardUserDefaults] setObject:[userInfo valueForKey:@"request"] forKey:@"request"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TAXI_FOUND" object:[userInfo valueForKey:@"request"]];
    }
}

- (void)checkingStatusForOldRequests {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"madeRequestID"]) {
        [self showLoadingIndicator];
        [self performSelector:@selector(makeRequestOnServer)];
    }
}

#pragma mark- Server Posting Methods

//Make a server call to create an account on server
- (void)makeRequestOnServer {
    NSString *requestUrlString = hostURL;
    
    //Creating the HTTP Request and setting the required post values
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrlString]];
    [request setPostValue:@"request" forKey:@"axn"];
    [request setPostValue:@"checkstatus" forKey:@"code"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"madeRequestID"] forKey:@"request_id"];
    [request setPostValue:[CommonMethods uniqueDeviceID] forKey:@"deviceid"];
   
    [request setTimeOutSeconds:200];
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(uploadReportFinished:)];
    [request setDidFailSelector:@selector(uploadReportFailed:)];
    [request startAsynchronous];
    
}

//If request fails, show an alert to the user and hide the indicator view
- (void)uploadReportFailed:(ASIHTTPRequest *)request {
    NSLog(@"uploadReportFailed: %@", [request responseString]);
    [self hideLoadingIndicator];
}

//If request finishes, hide the loading indicator and pass him to the next view
- (void)uploadReportFinished: (ASIHTTPRequest *)request {
    NSDictionary *dict = [[request responseString] JSONValue];    
    if ([[dict valueForKey:@"returnCode"] intValue] == 0) { //Everything was fine on server
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"request"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"STATUS_REQUEST" object:dict];
    }
    [self hideLoadingIndicator];
}


// Copy and paste this method into your AppDelegate to recieve push
// notifications for your application while the app is running.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self handleNotification:userInfo];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    [self updateTheLocation];
    [self performSelector:@selector(checkingStatusForOldRequests)];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - Loader Methods

//Create Loading Indicator object to be shown, when web-service calls etc are made.
-(void) showLoadingIndicator
{
	if(loadingView == nil)
	{
		loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 120)];
        loadingView.center = self.window.center;
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, loadingView.frame.size.width, 35)];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:18.6];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"Rider App";
        [loadingView addSubview:label];
        [label release];
        
        loadingView.layer.cornerRadius = 10;
        loadingView.layer.borderColor = [[UIColor whiteColor] CGColor];
        loadingView.layer.borderWidth = 3;
		loadingView.backgroundColor = [UIColor blackColor];
		loadingView.alpha = 0.81;	
		loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		loader.center = CGPointMake(loadingView.frame.size.width/2, loadingView.frame.size.height/2);
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, loader.center.y+15, loadingView.frame.size.width, 30)];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:15];
        label.text = @"Please Wait..";
        label.backgroundColor = [UIColor clearColor];
        [loadingView addSubview:label];
        [label release];
        
		[loader startAnimating];
		[loadingView addSubview:loader];
		[self.window addSubview:loadingView];
	}
}

//Hide the loading indicator
-(void) hideLoadingIndicator {
	if(loadingView !=nil) {
		[loader stopAnimating];
		[loader release];
		loader = nil;	
		[loadingView removeFromSuperview];
		[loadingView release];
		loadingView = nil;
	}
}

#pragma mark - Location Related

- (void)updateTheLocation {
    if (!mLocationManager) {
        self.mLocationManager.delegate = nil;
        self.mLocationManager = nil;
        CLLocationManager *locMngr = [[CLLocationManager alloc] init];
        self.mLocationManager = locMngr;
        self.mLocationManager.delegate = self;
        self.mLocationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        self.mLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.mLocationManager.delegate = self;
        [locMngr release];
    }
    else {
        self.mLocationManager.delegate = self;
    }
    locationManagerCount = 0;
    [self.mLocationManager startUpdatingLocation];
}

#pragma mark locationManager delegate
-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    NSDate *eventDate = newLocation.timestamp; 
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow]; 
    if (abs(howRecent) < 5.0) { 
        self.latitudeVal = newLocation.coordinate.latitude;
        self.longitudeVal = newLocation.coordinate.longitude;
    }
}

-(void) locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
    [self showAlertWithMessage:[error localizedDescription]];
    [self.mLocationManager stopUpdatingLocation];
    self.mLocationManager.delegate = nil;
    self.mLocationManager = nil;
}

- (void)showAlertWithMessage: (NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TaxiRider App" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

#pragma mark - Check Connectivity

- (BOOL)isInternetAvailable {
    
	//check for match status initially.
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];	
	NetworkStatus remoteHostStatus = [hostReach currentReachabilityStatus];	
    
    if (remoteHostStatus == NotReachable) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Internet connection not available. You need to have an internet connection to use this application." 
                                                            message:nil 
                                                           delegate:self 
                                                  cancelButtonTitle:nil 
                                                  otherButtonTitles:@"OK", nil];
		[alertView show];
		[alertView release];
		alertView = nil;
        return NO;
    }
    else {
		return YES;
	}
}




@end
