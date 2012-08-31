//
//  UIColor+Additions.h
//  watched
//
//  Created by Martin Juhasz on 25.07.12.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (Additions)
- (CGColorSpaceModel) colorSpaceModel;
- (NSString *) colorSpaceString;

- (NSArray *) arrayFromRGBAComponents;
- (CGFloat) red;
- (CGFloat) blue;
- (CGFloat) green;
- (CGFloat) alpha;

- (NSString *) stringFromColor;
- (NSString *) hexStringFromColor;

+ (UIColor *) colorWithString: (NSString *) stringToConvert;
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;
@end


