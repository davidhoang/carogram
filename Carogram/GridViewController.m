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
    BOOL gridFull;
}
@synthesize gridCells = _gridCells;

- (id)initWithMediaCollection:(WFIGMediaCollection *)mediaCollection atPage:(int)aPage
{
    self = [super init];
    if (self) {
        self.mediaCollection = mediaCollection;
        page = aPage;
        gridFull = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"view bounds: %@", NSStringFromCGRect(self.view.bounds));
    [self initGrid];
}

- (void)initGrid
{
    NSMutableArray *cells = [[NSMutableArray alloc] initWithCapacity:kImageCount];
    for (int i = 0; i < kImageCount; i++) {
        int index = i + (page * kImageCount);
        if (index >= [self.mediaCollection count]) {
            gridFull = NO;
            break;
        } else if (i == (kImageCount - 1)) {
            gridFull = YES;
        }
        
        WFIGMedia *media = [self.mediaCollection objectAtIndex:index];
        
        int x = 46 + ((i % 4) * 244);
        int y = 29 + ((i / 4) * 230);
        
        CGRect frame = CGRectMake(x, y, 200, 200);
        ImageGridViewCell *cell = [[ImageGridViewCell alloc] initWithMedia:media frame:frame];
        [cells addObject:cell];
        [self.view addSubview:cell];
        
        // Add invisible button
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = frame;
        btn.tag = i;
        [btn addTarget:self action:@selector(touchCell:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
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

- (void)touchCell:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectMedia:fromRect:)]) {
        UIButton *btn = (UIButton *)sender;
        int tag = btn.tag;
        int index = tag + (page * kImageCount);
    
        [self.delegate didSelectMedia:[self.mediaCollection objectAtIndex:index] fromRect:btn.frame];
    }
}

- (BOOL)isGridFull
{
    return gridFull;
}

@end
