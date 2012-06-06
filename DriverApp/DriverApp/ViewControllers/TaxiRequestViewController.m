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
#import <AddressBook/AddressBook.h>
#import "AddressAnnotation.h"

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

- (void)dealloc {
    [mapView setDelegate:nil];
    [proceedMapView setDelegate:nil];
    [super dealloc];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{ 
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *reqLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"requestLoc"];
    NSArray *coordinateArray = [reqLocation componentsSeparatedByString:@","];

    if ([coordinateArray count] > 1) {
        float latitude = [[coordinateArray objectAtIndex:0] floatValue];
        float longitude = [[coordinateArray objectAtIndex:1] floatValue];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
        [self geocodeLocationForCoordinate:reqLocation];
        
        AddressAnnotation  *annotation = [[AddressAnnotation alloc] initWithCoordinate:coord];// Make object of Annotation Class
		annotation.title = @"Rider Location";
        [mapView addAnnotation:annotation];
        [proceedMapView addAnnotation:annotation];
    }
    else {
        [self setLabelTexts:@"Sorry, The server failed to send the valid location for Driver"];
    }
}


#pragma mark Map Delegates

// mapView:viewForAnnotation: provides the view for each annotation.
// This method may be called for all or some of the added annotations.
// For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
- (MKAnnotationView *)mapView:(MKMapView *)mapViews viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        MKCoordinateRegion region = mapView.region;
        region.center = [annotation coordinate];
        region.span = MKCoordinateSpanMake(.01, .01);
        [mapViews setRegion:region animated:YES];
        return nil;
    }
    else {
        MKPinAnnotationView *pinView = nil;
		static NSString *defaultPinID = @"Annotation";
		pinView = (MKPinAnnotationView *)[mapViews dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
		if ( pinView == nil )
			pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
		pinView.pinColor = MKPinAnnotationColorGreen;
		pinView.canShowCallout = YES;
        return  pinView;
    }

}


#pragma mark - Map Geocoding

- (void)geocodeLocationForCoordinate:(NSString *)coordinatesString {
    
    NSString *requestUrlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=false", coordinatesString];
    //Creating the HTTP Request and setting the required post values
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrlString]];
    [request setTimeOutSeconds:200];
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(geocodeFinished:)];
    [request setDidFailSelector:@selector(geocodeFailed:)];
    [request startAsynchronous];
}

//If request fails, show an alert to the user and hide the indicator view
- (void)geocodeFinished: (ASIHTTPRequest *)request {
    NSDictionary *dict = [[request responseString] JSONValue];
    NSArray *addressArray = [dict valueForKey:@"results"];
    if ([addressArray count]) {
        NSDictionary *addressDict = [addressArray objectAtIndex:0];
        NSString *address = [addressDict valueForKey:@"formatted_address"];
        if (address) {
            NSArray *compsArray = [address componentsSeparatedByString:@","];
            if ([compsArray count] > 1) {
                NSString *firstStreetString = [compsArray objectAtIndex:0];
                NSMutableString *addressString = [NSMutableString stringWithString:firstStreetString];
                int index = 0;
                for (NSString *str in compsArray) {
                    if (index == 0) {
                        [addressString appendString:@"\n"];
                        index ++;
                        continue;
                    }
                    else if (index == 1) {
                        [addressString appendString:str];
                    }
                    else {
                        [addressString appendFormat:@", %@", str];
                    }
                    index++;
                }
                [self setLabelTexts:addressString];
            }
            else {
                [self setLabelTexts:address];
            }
        }
        else {
            [self setLabelTexts:@"Reverse Geocoding Failed: Could not retrieve the specified place information."];
        }
    }
    else {
         [self setLabelTexts:@"Reverse Geocoding Failed: Could not retrieve the specified place information."];
    }
}

- (void)geocodeFailed: (ASIHTTPRequest *)request {
    [self setLabelTexts:@"Reverse Geocoding Failed: Could not retrieve the specified place information."];
}

- (void)setLabelTexts: (NSString *)string {
    descriptionLabel.text = string;
    proceedToDescriptionLabel.text = string;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SET_STATUS_AVAILABLE" object:nil];
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
