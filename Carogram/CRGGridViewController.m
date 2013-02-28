//
//  CRGGridViewController.m
//  Carogram
//
//  Created by Jacob Moore on 8/27/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGGridViewController.h"
#import "CRGImageGridViewCell.h"

#define kNumberOfColumns 4

@interface CRGGridViewController ()
@property (strong, nonatomic) NSArray *gridCells;
- (void)initGrid;
@end

@implementation CRGGridViewController {
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
        
        int x = 46 + ((i % kNumberOfColumns) * 244);
        int y = 29 + ((i / kNumberOfColumns) * 230);
        
        CGRect frame = CGRectMake(x, y, 200, 200);
        CRGImageGridViewCell *cell = [[CRGImageGridViewCell alloc] initWithMedia:media frame:frame];
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

- (int)indexOfMediaAtPoint:(CGPoint)point
{
    float columnDivisor = self.view.bounds.size.width / kNumberOfColumns;
    int column = (int)(point.x / columnDivisor);

    float rowDivisor = self.view.bounds.size.height / (kImageCount/kNumberOfColumns);
    int row = (int)(point.y / rowDivisor);

    int index = row * kNumberOfColumns + column;
    if (index >= [self.gridCells count]) index = [self.gridCells count] - 1;
    
    return index;
}

- (CGRect)mediaFrameAtPoint:(CGPoint)point
{
    float columnDivisor = self.view.bounds.size.width / kNumberOfColumns;
    int column = (int)(point.x / columnDivisor);
    
    float rowDivisor = self.view.bounds.size.height / (kImageCount/kNumberOfColumns);
    int row = (int)(point.y / rowDivisor);
    
    int index = row * kNumberOfColumns + column;
    if (index >= [self.gridCells count]) index = [self.gridCells count] - 1;
        
    CRGImageGridViewCell *cell = self.gridCells[index];

    return cell.frame;
}

@end
