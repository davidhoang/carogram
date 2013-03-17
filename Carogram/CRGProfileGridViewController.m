//
//  CRGProfileGridViewController.m
//  Carogram
//
//  Created by Jacob Moore on 3/14/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGProfileGridViewController.h"
#import "CRGImageGridViewCell.h"
#import "UIImageView+WebCache.h"
#import "CRGFullGridViewController.h"

#define kNumberOfColumns  3
#define kInfoViewWidth    280.

@interface CRGProfileGridViewController ()
@property (strong, nonatomic) UIImageView *headerImageView;
@property (strong, nonatomic) NSArray *gridCells;
@end

@implementation CRGProfileGridViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    WFIGMedia *firstMedia = [self.mediaCollection objectAtIndex:0];
    NSURL *imageURL = [NSURL URLWithString:[firstMedia lowResolutionURL]];
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 29, kInfoViewWidth, kInfoViewWidth)];
    [self.headerImageView setImageWithURL:imageURL];
    
    [self.view addSubview:self.headerImageView];
    
    [self initGrid];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initGrid
{
    NSMutableArray *cells = [[NSMutableArray alloc] initWithCapacity:kProfileGridCount];
    for (int i = 1; i < kProfileGridCount; i++) {
        int index = i + (self.page * kProfileGridCount);
        if (index >= [self.mediaCollection count]) {
            self.gridFull = NO;
            break;
        } else if (i == (kProfileGridCount - 1)) {
            self.gridFull = YES;
        }
        
        WFIGMedia *media = [self.mediaCollection objectAtIndex:index];
        
        int gridIndex = i - 1;
        int x = 295 + ((gridIndex % kNumberOfColumns) * 244);
        int y = 29 + ((gridIndex / kNumberOfColumns) * 230);
        
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

#pragma mark - CRGGridViewController protocol

+ (int)pageCountWithMediaCount:(int)mediaCount
{
    return ceil((double)(mediaCount + 2) / (double)kGridCount);
}

- (int)indexOfMediaAtPoint:(CGPoint)point
{
    if (point.x < kInfoViewWidth) return 0;

    float columnDivisor = (self.view.bounds.size.width - kInfoViewWidth) / kNumberOfColumns;
    int column = (int)((point.x - kInfoViewWidth) / columnDivisor);

    float rowDivisor = self.view.bounds.size.height / ((kGridCount-1)/kNumberOfColumns);
    int row = (int)(point.y / rowDivisor);

    int index = row * kNumberOfColumns + column + 1;
    if (index >= kProfileGridCount) index = kProfileGridCount - 1;
    return index;
}

- (UIView *)gridCellAtPoint:(CGPoint)point
{
    if (point.x < kInfoViewWidth) return self.headerImageView;

    float columnDivisor = (self.view.bounds.size.width - kInfoViewWidth) / kNumberOfColumns;
    int column = (int)((point.x - kInfoViewWidth) / columnDivisor);
    
    float rowDivisor = self.view.bounds.size.height / ((kGridCount-1)/kNumberOfColumns);
    int row = (int)(point.y / rowDivisor);
    
    int index = row * kNumberOfColumns + column;
    if (index >= [self.gridCells count]) return nil;
    return self.gridCells[index];
}

- (UIView *)gridCellAtIndex:(int)index
{
    if (index < 0 || index >= [self.gridCells count]) return nil;
    if (index == 0) return self.headerImageView;
    return self.gridCells[index - 1];
}

- (void)setFocusIndex:(int)focusIndex
{
    [super setFocusIndex:focusIndex];
    
    if (focusIndex == 0) [self.view bringSubviewToFront:self.headerImageView];
    else if (focusIndex > 0 && focusIndex <= [self.gridCells count]) {
        [self.view bringSubviewToFront:self.gridCells[focusIndex-1]];
    }
}

- (void)setPeripheryAlpha:(CGFloat)peripheryAlpha
{
    [super setPeripheryAlpha:peripheryAlpha];

    if (self.focusIndex != 0) self.headerImageView.alpha = peripheryAlpha;

    for (int i = 0; i < [self.gridCells count]; i++) {
        if ((i + 1) == self.focusIndex) continue;
        UIView *gridCell = self.gridCells[i];
        gridCell.alpha = peripheryAlpha;
    }
}

@end
