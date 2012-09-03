//
//  MJInternetConnection.h
//  watched
//
//  Created by Martin Juhasz on 03.09.12.
//
//

#import <Foundation/Foundation.h>

@interface MJInternetConnection : NSObject

@property (nonatomic, assign) BOOL internetAvailable;

+ (id)sharedInternetConnection;
- (void)displayAlert;

@end
