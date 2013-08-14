//
//  MJUTrailer.h
//  watched
//
//  Created by Martin Juhasz on 09.08.13.
//
//
#import "MTLModel.h"
#import "MTLJSONAdapter.h"

typedef NS_ENUM(NSInteger, MJUTrailerType) {
    MJUTrailerTypeYoutube,
    MJUTrailerTypeQuicktime
};

typedef NS_ENUM(NSInteger, MJUTrailerQuality) {
    MJUTrailerQualityHD,
    MJUTrailerQualitySD
};

@interface MJUTrailer : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) MJUTrailerQuality size;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, assign) MJUTrailerType type;

+ (id)trailerFromJSONDictionary:(NSDictionary*)aDictionary;

@end
