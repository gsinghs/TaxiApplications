//
//  HomeViewController.m
//  DriverApp
//
//  Created by Gursharan Singh on 30/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"
#import "TaxiRequestViewController.h"
#import "AppDelegate.h"
#import "ASIFormDataRequest.h"
#import "CommonMethods.h"
#import "NSString+SBJSON.h"

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestForTaxi:) name:@"REQUEST_FOR_TAXI" object:nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma - Notification

- (void)requestForTaxi: (NSNotification *)notification {
  //  NSDictionary *requestDict = [notification object];
    TaxiRequestViewController *viewController = [[TaxiRequestViewController alloc] initWithNibName:@"TaxiRequestViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

#pragma - button clicks

- (IBAction)availableORHireClicked:(UIButton *)sender {
    
    [self postStatusOnServer:[sender tag]];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([sender tag] == 0) {//occupy clicked
        [occupyButton setTitle:@"OCCUPIED" forState:UIControlStateNormal];
        [availableButton setTitle:@"Available" forState:UIControlStateNormal];
        availableButton.titleLabel.textColor = [UIColor blackColor];
        occupyButton.titleLabel.textColor = [UIColor yellowColor];
        [occupyButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [availableButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [availableButton setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
        [occupyButton setBackgroundImage:nil forState:UIControlStateNormal];
        [appDelegate stopTimers];
    }
    else {
        [occupyButton setTitle:@"Occupy" forState:UIControlStateNormal];
        [availableButton setTitle:@"AVAILABLE" forState:UIControlStateNormal];
        availableButton.titleLabel.textColor = [UIColor yellowColor];
        occupyButton.titleLabel.textColor = [UIColor blackColor];
        [availableButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [occupyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [occupyButton setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
        [availableButton setBackgroundImage:nil forState:UIControlStateNormal];
        [appDelegate locationUpdatingTimer];
    }
    occupyButton.userInteractionEnabled = NO;
    availableButton.userInteractionEnabled = NO;
}


#pragma mark- Server Posting Methods

//Make a server call to create an account on server
- (void)postStatusOnServer:(int)status {
    NSString *requestUrlString = hostURL;
    
    //Show loading view while server call is in place
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoadingIndicator];
 
    //Creating the HTTP Request and setting the required post values
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrlString]];
    [request setPostValue:@"driver" forKey:@"axn"];
    [request setPostValue:@"newstatus" forKey:@"code"];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"APNS_Token"]) {
        [request setPostValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"APNS_Token"] forKey:@"token"];
    }
    [request setPostValue:[CommonMethods uniqueDeviceID] forKey:@"deviceid"];
    
    [request setPostValue:[NSString stringWithFormat:@"%d", status] forKey:@"status"];
    NSString *locString = [NSString stringWithFormat:@"%f,%f", appDelegate.latitudeVal, appDelegate.longitudeVal];
    
    [request setPostValue:locString forKey:@"location"];
    [request setTimeOutSeconds:200];
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(uploadReportFinished:)];
    [request setDidFailSelector:@selector(uploadReportFailed:)];
    [request startAsynchronous];
    
}

//If request fails, show an alert to the user and hide the indicator view
- (void)uploadReportFailed:(ASIHTTPRequest *)request {
    NSLog(@"uploadReportFailed: %@", [request responseString]);
    [self showAlertWithMessage:@"Uploading to Server failed, Please try again later."];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideLoadingIndicator];
    occupyButton.userInteractionEnabled = YES;
    availableButton.userInteractionEnabled = YES;

}

//If request finishes, hide the loading indicator and pass him to the next view
- (void)uploadReportFinished: (ASIHTTPRequest *)request {
    occupyButton.userInteractionEnabled = YES;
    availableButton.userInteractionEnabled = YES;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideLoadingIndicator];
    
    NSDictionary *dict = [[request responseString] JSONValue];
    NSLog(@"uploadReportFinished: %@", dict);
    
    if ([[dict valueForKey:@"returnCode"] intValue] == 0) { //Everything was fine on server.
       
    }
    else {
        [self showAlertWithMessage:[NSString stringWithFormat:@"Error from Server: %@", [dict valueForKey:@"error"]]];
    }
}

#pragma - Other helpers

- (void)showAlertWithMessage: (NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TaxiRider App" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}


@end
