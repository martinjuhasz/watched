//
//  MJUDiscoverTableViewCell.m
//  watched
//
//  Created by Martin Juhasz on 25/03/14.
//
//

#import "MJUDiscoverTableViewCell.h"
#import "UIColor+Additions.h"

@implementation MJUDiscoverTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"676767"];
        self.backgroundColor = [UIColor colorWithHexString:@"676767"];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:17.0f];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
