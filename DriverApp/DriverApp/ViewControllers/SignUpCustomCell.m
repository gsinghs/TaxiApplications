//
//  SignUpCustomCell.m
//  DriverApp
//
//  Created by Gursharan Singh on 21/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SignUpCustomCell.h"


@implementation SignUpCustomCell

@synthesize fieldNameLabel;
@synthesize fieldValueTextField;
@synthesize indexPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[indexPath release];
	[fieldValueTextField release];
	[fieldNameLabel release];
    [super dealloc];
}






@end
