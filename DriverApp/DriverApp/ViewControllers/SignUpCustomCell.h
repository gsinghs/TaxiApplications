//
//  SignUpCustomCell.h
//  DriverApp
//
//  Created by Gursharan Singh on 21/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SignUpCustomCell : UITableViewCell {
	
	UILabel *fieldNameLabel;
	UITextField *fieldValueTextField;
	NSIndexPath *indexPath;
}

@property (nonatomic, retain) IBOutlet UILabel *fieldNameLabel;
@property (nonatomic, retain) IBOutlet UITextField *fieldValueTextField;
@property (nonatomic, retain) NSIndexPath *indexPath;

@end
