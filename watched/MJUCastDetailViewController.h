//
//  MJUCastDetailSegue.h
//  watched
//
//  Created by Martin Juhasz on 06.08.13.
//
//

#import <UIKit/UIKit.h>

@interface MJUCastDetailViewController : UIViewController

@property (strong, nonatomic) NSNumber *personID;
@property (weak, nonatomic) IBOutlet UILabel *biographyLabel;

@end
