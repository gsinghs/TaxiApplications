//
//  SignUpViewController.h
//  DriverApp
//
//  Created by Gursharan Singh on 30/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"

@interface SignUpViewController : UIViewController  <UITextFieldDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate> {
	NSArray *tableViewData;
	
	UITableView *mTableView;
	NSMutableString *nameString;
    NSMutableString *companyString;
	NSMutableString *cabString;
    
    	
}

@property (nonatomic, retain) NSArray *tableViewData;
@property (nonatomic, retain) IBOutlet UITableView *mTableView;


- (IBAction)submit:(id)sender;
- (void)showAlertWithMessage: (NSString *)message;
- (void)createAccountOnServer;
- (BOOL)validateTextForNull: (NSString *)string;
@end
