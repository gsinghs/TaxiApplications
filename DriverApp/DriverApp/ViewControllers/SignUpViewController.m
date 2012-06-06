//
//  SignUpViewController.m
//  DriverApp
//
//  Created by Gursharan Singh on 30/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignUpViewController.h"
#import "HomeViewController.h"
#import "ASIFormDataRequest.h"
#import "CommonMethods.h"
#import "AppDelegate.h"
#import "NSString+SBJSON.h"

#import "SignUpCustomCell.h"

@implementation SignUpViewController
@synthesize tableViewData;
@synthesize mTableView;



#pragma mark -
#pragma mark UIViewController methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Registration";
  	
    nameString = [[NSMutableString alloc] initWithString:@""];
    companyString = [[NSMutableString alloc] initWithString:@""];
	cabString = [[NSMutableString alloc] initWithString:@""];
	
	
	NSMutableDictionary *fullNameDic = [[NSMutableDictionary alloc] init];
	[fullNameDic setValue:@"Name" forKey:@"fieldName"];
	[fullNameDic setValue:@"John Appleased" forKey:@"fieldPlaceholder"];
	[fullNameDic setValue:nameString forKey:@"fieldValue"];
	
    NSMutableDictionary *companyDict = [[NSMutableDictionary alloc] init];
	[companyDict setValue:@"Company" forKey:@"fieldName"];
	[companyDict setValue:@"Metro Cab" forKey:@"fieldPlaceholder"];
	[companyDict setValue:companyString forKey:@"fieldValue"];
    
	NSMutableDictionary *cabDict = [[NSMutableDictionary alloc] init];
	[cabDict setValue:@"Cab #" forKey:@"fieldName"];
	[cabDict setValue:@"123" forKey:@"fieldPlaceholder"];
	[cabDict setValue:cabString forKey:@"fieldValue"];
   
	NSArray *section = [[NSArray alloc] initWithObjects:fullNameDic, companyDict, cabDict, nil];
	[fullNameDic release];
	[companyDict release];
	[cabDict release];
	
	NSArray *array = [[NSArray alloc] initWithObjects:section, nil];
	self.tableViewData = array;
	[array release];
	
	[section release];
	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:YES];
	
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
    
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.tableViewData = nil;
	self.mTableView = nil;
    
}


- (void)dealloc {
	[cabString release];
	[companyString release];
	[nameString release];
	[mTableView release];
	[tableViewData release];
    [super dealloc];
}



#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [tableViewData count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[tableViewData objectAtIndex:section] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SignUpCustomCell";
    
    SignUpCustomCell *cell = (SignUpCustomCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		
		
		
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SignUpCustomCell" owner:nil options:nil];
		
		for(id currentObject in topLevelObjects)
		{
			if([currentObject isKindOfClass:[UITableViewCell class]])
			{
				cell = (SignUpCustomCell *) currentObject;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				//cell.backgroundColor = [UIColor clearColor];
				break;
			}
		}		
	}
	
	cell.fieldNameLabel.text = [[[tableViewData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] valueForKey:@"fieldName"];
    cell.fieldValueTextField.delegate = self;
	cell.indexPath = indexPath;
	
	
	NSString *fieldValue = [[[tableViewData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] valueForKey:@"fieldValue"];
	if([fieldValue isEqualToString:@""])
	{
		cell.fieldValueTextField.borderStyle = UITextBorderStyleNone;
		cell.fieldValueTextField.text = @"";
		cell.fieldValueTextField.placeholder = [[[tableViewData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] valueForKey:@"fieldPlaceholder"];
	}
	else
	{
		cell.fieldValueTextField.borderStyle = UITextBorderStyleNone;
		cell.fieldValueTextField.text = fieldValue;
		cell.fieldValueTextField.placeholder = [[[tableViewData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] valueForKey:@"fieldPlaceholder"];
	}
    return cell;
}

#pragma mark -
#pragma mark Action methods

- (IBAction)submit:(id)sender
{
	
	if(![(AppDelegate *)[[UIApplication sharedApplication] delegate] isInternetAvailable])
	{
		UIAlertView *newAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Server not reachable. Please check your internet connectivity" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[newAlertView show];
		[newAlertView release];
		
		return;
	}
    
    NSString *name = [[[[tableViewData objectAtIndex:0] objectAtIndex:0] valueForKey:@"fieldValue"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSString *cmpny = [[[[tableViewData objectAtIndex:0] objectAtIndex:1] valueForKey:@"fieldValue"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];;
	NSString *cab = [[[[tableViewData objectAtIndex:0] objectAtIndex:2] valueForKey:@"fieldValue"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];;
	
    if ([self validateTextForNull:name] == NO) {
        [self showAlertWithMessage:@"Please enter your name."];
        return;
    }
    if ([self validateTextForNull:cmpny]  == NO) {
        [self showAlertWithMessage:@"Please enter your Company."];
        return;
    }
    if ([self validateTextForNull:cab]  == NO) {
        [self showAlertWithMessage:@"Please enter your Cab Number."];
        return;
    }
    [self performSelector:@selector(createAccountOnServer)];
	    
}

#pragma mark -
#pragma mark UITextField delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGRect newFrame = self.view.frame;
    newFrame.origin.y = 0;
    self.view.frame = newFrame;
    [UIView commitAnimations];
    
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	//textField.borderStyle = UITextBorderStyleRoundedRect;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGRect newFrame = self.view.frame;
    newFrame.origin.y = -120;
    self.view.frame = newFrame;
    [UIView commitAnimations];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	
	
	textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	if(![textField.text isEqualToString:@""])
	{
		textField.borderStyle = UITextBorderStyleNone;
	}
	
	
	SignUpCustomCell *cell = (SignUpCustomCell *)[[textField superview] superview];
	NSMutableString *changedString = [[[tableViewData objectAtIndex:cell.indexPath.section] objectAtIndex:cell.indexPath.row] valueForKey:@"fieldValue"];
	[changedString setString:textField.text];
	
}



#pragma mark -
#pragma mark UIAlertView delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView.tag == 1)
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
	
}


//Check for valid value of text field
- (BOOL)validateTextForNull: (NSString *)string {
    if (string && ![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        return YES;
    }
    return NO;
}


- (void)showAlertWithMessage: (NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TaxiRider App" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

#pragma mark- Server Posting Methods

//Make a server call to create an account on server
- (void)createAccountOnServer {
    NSString *requestUrlString = hostURL;
    
    //Show loading view while server call is in place
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoadingIndicator];
    
    //Creating the HTTP Request and setting the required post values
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrlString]];

    [request setPostValue:@"signup" forKey:@"axn"];
    [request setPostValue:@"driver" forKey:@"code"];
    [request setPostValue:[CommonMethods uniqueDeviceID] forKey:@"deviceid"];

    NSString *name = [[[[tableViewData objectAtIndex:0] objectAtIndex:0] valueForKey:@"fieldValue"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSString *cmpny = [[[[tableViewData objectAtIndex:0] objectAtIndex:1] valueForKey:@"fieldValue"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];;
	NSString *cab = [[[[tableViewData objectAtIndex:0] objectAtIndex:2] valueForKey:@"fieldValue"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];;

    [request setPostValue:name forKey:@"name"];
    [request setPostValue:cmpny forKey:@"company"];
    [request setPostValue:cab forKey:@"cab"];
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
    
}

//If request finishes, check for the response string, hide the loading indicator and pass him to the next view if response OK
- (void)uploadReportFinished: (ASIHTTPRequest *)request {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideLoadingIndicator];

    NSDictionary *dict = [[request responseString] JSONValue];
    //NSLog(@"uploadReportFinished: %@", dict);
    
    if ([[dict valueForKey:@"returnCode"] intValue] == 0) { //Everything was fine on server.
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"registeredOnServer"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        HomeViewController *viewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:[NSBundle mainBundle]];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navigationController.navigationBarHidden = YES;
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        appDelegate.window.rootViewController = navigationController;
        [viewController release];
        [navigationController release];
    }
    else {
        [self showAlertWithMessage:[NSString stringWithFormat:@"Error from Server: %@", [dict valueForKey:@"error"]]];
    }
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
