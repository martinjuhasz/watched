//
//  MJUCastDetailSegue.h
//  watched
//
//  Created by Martin Juhasz on 06.08.13.
//
//

#import <UIKit/UIKit.h>
#import "MJUPerson.h"

@interface MJUCastDetailViewController : UIViewController

@property (strong, nonatomic) MJUPerson *person;
@property (weak, nonatomic) IBOutlet UILabel *biographyLabel;

@end
