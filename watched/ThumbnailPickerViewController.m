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
    self.gridView.backgroundColor = [UIColor clearColor];
    self.gridView.style = GMGridViewStyleSwap;
    self.gridView.itemSpacing = 10.0f;
    self.gridView.minEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    self.gridView.centerGrid = YES;
    self.gridView.actionDelegate = self;
    self.gridView.dataSource = self;
    [self.view addSubview:self.gridView];

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
    if(self.imageType == ImageTypePoster) return CGSizeMake(89.0f, 126.0f);
    return CGSizeMake(300.0f, 126.0f);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)aGridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self GMGridView:aGridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell) 
    {
        cell = [[GMGridViewCell alloc] init];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor grayColor];

        cell.contentView = view;
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [imageView setImageWithURL:[[self.imageURLs objectAtIndex:index] objectForKey:@"url"]];
    [cell.contentView addSubview:imageView];
    
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
