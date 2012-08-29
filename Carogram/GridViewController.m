//
//  GridViewController.m
//  Carogram
//
//  Created by Jacob Moore on 8/27/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "GridViewController.h"
#import "ImageGridViewCell.h"

@interface GridViewController ()
@property (strong, nonatomic) NSArray *gridCells;
- (void)initGrid;
@end

@implementation GridViewController {
@private
    int page;
}
@synthesize gridCells = _gridCells;

- (id)initWithMediaCollection:(WFIGMediaCollection *)mediaCollection atPage:(int)aPage
{
    self = [super init];
    if (self) {
        self.mediaCollection = mediaCollection;
        page = aPage;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initGrid];
}

- (void)initGrid
{
    NSMutableArray *cells = [[NSMutableArray alloc] initWithCapacity:kImageCount];
    for (int i = 0; i < kImageCount; i++) {
        int index = i + (page * kImageCount);
        if (index >= [self.mediaCollection count]) break;
        WFIGMedia *media = [self.mediaCollection objectAtIndex:index];
        
        int x = 46 + ((i % 4) * 244);
        int y = 26 + ((i / 4) * 224);

//        int x = 28 + ((i % 4) * 256);
//        int y = 16 + ((i / 4) * 232);
        
        CGRect frame = CGRectMake(x, y, 200, 200);
        ImageGridViewCell *cell = [[ImageGridViewCell alloc] initWithMedia:media frame:frame];
        [cells addObject:cell];
        [self.view addSubview:cell];
    }
    self.gridCells = cells;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}

@end
