//
//  TaxiRequestViewController.m
//  DriverApp
//
//  Created by Gursharan Singh on 30/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TaxiRequestViewController.h"
#import "AppDelegate.h"
#import "ASIFormDataRequest.h"
#import "CommonMethods.h"
#import "NSString+SBJSON.h"

@implementation TaxiRequestViewController

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

#pragma mark - Button Clicks

- (IBAction)acceptRequestClicked:(id)sender {
    [self performSelector:@selector(acceptRequestOnServer)];
}

- (IBAction)rejectRequestClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)callcustomerClicked:(id)sender {
    
}

- (IBAction)doneClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark- Server Posting Methods

//Make a server call to create an account on server
- (void)acceptRequestOnServer {
    NSString *requestUrlString = hostURL;
    
    //Show loading view while server call is in place
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoadingIndicator];
    
    //Creating the HTTP Request and setting the required post values
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrlString]];
    [request setPostValue:@"request" forKey:@"axn"];
    [request setPostValue:@"accept" forKey:@"code"];
    [request setPostValue:[CommonMethods uniqueDeviceID] forKey:@"deviceid"];
    
    [request setPostValue:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"taxiRequestId"]] forKey:@"request_id"];
    [self showAlertWithMessage:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"taxiRequestId"]]];
    [request setPostValue:@"0" forKey:@"status"];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"APNS_Token"]) {
        [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"APNS_Token"] forKey:@"token"];
    }
    [request setTimeOutSeconds:200];
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(uploadReportFinished:)];
    [request setDidFailSelector:@selector(uploadReportFailed:)];
    [request startAsynchronous];
    
}

//If request fails, show an alert to the user and hide the indicator view
- (void)uploadReportFailed:(ASIHTTPRequest *)request {
    NSLog(@"uploadReportFailed: %@", [request responseString]);
    [self showAlertWithMessage:@"Server call failed, Please try again later."];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideLoadingIndicator];
    
}

//If request finishes, check for the response string, hide the loading indicator and pass him to the next view if response OK
- (void)uploadReportFinished: (ASIHTTPRequest *)request {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideLoadingIndicator];
    
    NSDictionary *dict = [[request responseString] JSONValue];
    //NSLog(@"uploadReportFinished: %@", dict);
    
    if ([[dict valueForKey:@"returnCode"] intValue] == 0) { //Everything was fine on server.
        [self.view addSubview:requestAcceptedView];
    }
    else {
        [self showAlertWithMessage:[NSString stringWithFormat:@"Error from Server: %@", [dict valueForKey:@"error"]]];
    }
    
}


- (void)showAlertWithMessage: (NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TaxiRider App" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}



@end
