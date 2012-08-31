//
//  ThumbnailPickerViewController.m
//  watched
//
//  Created by Martin Juhasz on 04.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailPickerViewController.h"
#import "UIImageView+AFNetworking.h"

@interface ThumbnailPickerViewController ()

@end

@implementation ThumbnailPickerViewController

@synthesize gridView;
@synthesize imageURLs;
@synthesize imageType;
@synthesize delegate;

#define kOverlayTag 23142
#define kImageTag 23141


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gridView = [[GMGridView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    self.gridView.backgroundColor = HEXColor(0xe6e6e6);
    self.gridView.style = GMGridViewStylePush;
    self.gridView.itemSpacing = 3.0f;
    if(self.imageType == ImageTypeBackdrop) {
        self.gridView.minEdgeInsets = UIEdgeInsetsMake(9.0f, 9.0f, 9.0f, 0.0f);
        self.gridView.itemSpacing = 8.0f;
    }
    self.gridView.centerGrid = NO;
    self.gridView.alwaysBounceVertical = YES;
    self.gridView.actionDelegate = self;
    self.gridView.dataSource = self;
    [self.view addSubview:self.gridView];
    
    if(self.imageType == ImageTypePoster) {
        self.title = NSLocalizedString(@"THUMBNAILVIEW_TITLE_POSTER", nil);
    } else {
        self.title = NSLocalizedString(@"THUMBNAILVIEW_TITLE_BACKDROP", nil);
    }

}

- (void)viewDidUnload
{
    [self setGridView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [self.imageURLs count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if(self.imageType == ImageTypePoster) return CGSizeMake(75.0f, 103.0f);
    return CGSizeMake(302.0f, 102.0f);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)aGridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self GMGridView:aGridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell) 
    {
        cell = [[GMGridViewCell alloc] init];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        view.backgroundColor = [UIColor clearColor];
        
        // image
        UIImageView *posterImageView = [[UIImageView alloc] init];
        posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        posterImageView.clipsToBounds = YES;
        if(self.imageType == ImageTypePoster) {
            posterImageView.frame = CGRectMake(2.0f, 2.0f, 71.0f, 99.0f);
        } else {
            posterImageView.frame = CGRectMake(1.0f, 1.0f, 300.0f, 100.0f);
        }
        posterImageView.tag = kImageTag;
        [view addSubview:posterImageView];
        
        // cover
        UIImageView *posterCover = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        posterCover.contentMode = UIViewContentModeScaleAspectFill;
        posterCover.clipsToBounds = YES;
        posterCover.tag = kOverlayTag;
        if(self.imageType == ImageTypePoster) {
            posterCover.image = [UIImage imageNamed:@"dv_cover-overlay.png"];
        } else {
            posterCover.image = [UIImage imageNamed:@"dv_poster-overlay.png"];
        }
        [view addSubview:posterCover];
        
        cell.contentView = view;
    }
    
    UIImageView *posterImageView = (UIImageView *)[cell viewWithTag:kImageTag];
    UIImage *placeHolder;
    
    if(self.imageType == ImageTypePoster) {
        placeHolder = [UIImage imageNamed:@"dv_placeholder-cover.png"];
    } else {
        placeHolder = [UIImage imageNamed:@"dv_placeholder-poster.png"];
    }
    
    [posterImageView setImageWithURL:[[self.imageURLs objectAtIndex:index] objectForKey:@"url"] placeholderImage:placeHolder];

    return cell;
}


- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return NO;
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark GMGridViewDelegate

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    NSString *imagePath = [[self.imageURLs objectAtIndex:position] objectForKey:@"path"];
    if(!imagePath) return;
    if (self.delegate && [self.delegate respondsToSelector:@selector(thumbnailPicker:didSelectImage:forImageType:)]) {
        [self.delegate thumbnailPicker:self didSelectImage:imagePath forImageType:self.imageType];
    }
}

@end
