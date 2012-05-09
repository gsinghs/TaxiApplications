//
//  SignUpViewController.h
//  DriverApp
//
//  Created by Gursharan Singh on 30/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"

@interface SignUpViewController : UIViewController <UITextFieldDelegate> {
    IBOutlet CustomTextField *nameTxtField;
    IBOutlet CustomTextField *phoneNumberTxtField;

}

- (IBAction)signUpClicked:(id)sender;
- (BOOL)validateTextOfTextFieldForNull: (UITextField *)textField;
- (void)showAlertWithMessage: (NSString *)message;

@end
