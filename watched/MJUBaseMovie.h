//
//  MJUMovie.h
//  watched
//
//  Created by Martin Juhasz on 15.08.13.
//
//

#import <Foundation/Foundation.h>

@interface MJUBaseMovie : NSObject

@property (nonatomic, strong) NSNumber* adult;
@property (nonatomic, strong) NSString* backdropPath;
@property (nonatomic, strong) NSString* backdropURL;
@property (nonatomic, strong) NSNumber* budget;
@property (nonatomic, strong) NSString* homepage;
@property (nonatomic, strong) NSString* imdbID;
@property (nonatomic, strong) NSNumber* movieID;
@property (nonatomic, strong) NSString* note;
@property (nonatomic, strong) NSString* originalTitle;
@property (nonatomic, strong) NSString* overview;
@property (nonatomic, strong) NSNumber* popularity;
@property (nonatomic, strong) NSString* posterPath;
@property (nonatomic, strong) NSString* posterURL;
@property (nonatomic, strong) NSNumber* rating;
@property (nonatomic, strong) NSDate* releaseDate;
@property (nonatomic, strong) NSNumber* revenue;
@property (nonatomic, strong) NSNumber* runtime;
@property (nonatomic, strong) NSString* tagline;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSDate* watchedOn;

@end
