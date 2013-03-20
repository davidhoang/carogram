//
//  CRGFullGridViewController.m
//  Carogram
//
//  Created by Jacob Moore on 8/27/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGFullGridViewController.h"
#import "CRGImageGridViewCell.h"

#define kNumberOfColumns 4

@interface CRGFullGridViewController ()
@property (strong, nonatomic) NSArray *gridCells;
@property (nonatomic) int page;
@end

@implementation CRGFullGridViewController {
    int _offset;
}

- (id)initWithMediaCollection:(WFIGMediaCollection *)mediaCollection atPage:(int)aPage offset:(int)offset
{
    self = [super initWithMediaCollection:mediaCollection atPage:aPage];
    if (self) {
        _offset = offset;
    }
    return self;
}

- (id)initWithMediaCollection:(WFIGMediaCollection *)mediaCollection atPage:(int)aPage
{
    self = [super initWithMediaCollection:mediaCollection atPage:aPage];
    if (self) {
        _offset = 0;
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
    NSMutableArray *cells = [[NSMutableArray alloc] initWithCapacity:kGridCount];
    for (int i = 0; i < kGridCount; i++) {
        int index = i + (self.page * kGridCount);
        if (index >= [self.mediaCollection count]) {
            self.gridFull = NO;
            break;
        } else if (i == (kGridCount - 1)) {
            self.gridFull = YES;
        }
        
        WFIGMedia *media = [self.mediaCollection objectAtIndex:(index + _offset)];
        
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
        int index = tag + (self.page * kGridCount) + _offset;
    
        [self.delegate didSelectMedia:[self.mediaCollection objectAtIndex:index] fromRect:btn.frame];
    }
}

#pragma mark - CRGGridViewController protocol

+ (int)pageCountWithMediaCount:(int)mediaCount
{
    return ceil((double)mediaCount / (double)kGridCount);
}

- (void)setFocusIndex:(int)focusIndex
{
    [super setFocusIndex:focusIndex];
    
    if (focusIndex >= 0 && focusIndex < [self.gridCells count])
        [self.view bringSubviewToFront:self.gridCells[focusIndex]];
}

- (void)setPeripheryAlpha:(CGFloat)peripheryAlpha
{
    [super setPeripheryAlpha:peripheryAlpha];
    
    for (int i = 0; i < [self.gridCells count]; i++) {
        if (i == self.focusIndex) continue;
        CRGImageGridViewCell *cell = self.gridCells[i];
        cell.alpha = peripheryAlpha;
    }
}

- (int)indexOfMediaAtPoint:(CGPoint)point
{
    float columnDivisor = self.view.bounds.size.width / kNumberOfColumns;
    int column = (int)(point.x / columnDivisor);

    float rowDivisor = self.view.bounds.size.height / (kGridCount/kNumberOfColumns);
    int row = (int)(point.y / rowDivisor);

    int index = row * kNumberOfColumns + column;
    if (index >= [self.gridCells count]) index = [self.gridCells count] - 1;
    
    return index;
}

- (UIView *)gridCellAtPoint:(CGPoint)point
{
    float columnDivisor = self.view.bounds.size.width / kNumberOfColumns;
    int column = (int)(point.x / columnDivisor);
    
    float rowDivisor = self.view.bounds.size.height / (kGridCount/kNumberOfColumns);
    int row = (int)(point.y / rowDivisor);
    
    int index = row * kNumberOfColumns + column;
    if (index >= [self.gridCells count]) return nil;
    return self.gridCells[index];
}

- (UIView *)gridCellAtIndex:(int)index
{
    if (index < 0 || index >= [self.gridCells count]) return nil;
    return self.gridCells[index];
}

@end
