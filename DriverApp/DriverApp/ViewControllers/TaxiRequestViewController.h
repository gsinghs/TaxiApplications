//
//  TaxiRequestViewController.h
//  DriverApp
//
//  Created by Gursharan Singh on 30/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaxiRequestViewController : UIViewController {
    IBOutlet UILabel *descriptionLabel;
    IBOutlet UILabel *distanceLabel;
    IBOutlet UIView *requestAcceptedView;
}

- (IBAction)acceptRequestClicked:(id)sender;
- (IBAction)rejectRequestClicked:(id)sender;
- (IBAction)callcustomerClicked:(id)sender;
- (void)showAlertWithMessage: (NSString *)message;
- (IBAction)doneClicked:(id)sender;

@end
