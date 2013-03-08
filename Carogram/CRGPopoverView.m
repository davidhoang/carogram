//
//  CRGPopoverView.m
//  Carogram
//
//  Created by Jacob Moore on 3/4/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGPopoverView.h"
#import <QuartzCore/QuartzCore.h>
#import "CRGPopoverCell.h"

#define WIDTH           340.
#define HEIGHT          235.
#define BORDER_WIDTH    10.
#define CORNER_RADIUS   13.
#define PADDING         11.
#define CELL_HEIGHT     44.
#define ARROW_HEIGHT    15.
#define ARROW_WIDTH     18.
#define WINDOW_PADDING  8.

static NSString * const PopoverCellID = @"PopoverCellID";

@interface PopoverViewOverlayWindow : UIWindow
@property (nonatomic,retain) UIWindow* oldKeyWindow;
@end

@implementation PopoverViewOverlayWindow
@synthesize oldKeyWindow;

- (void) makeKeyAndVisible
{
	self.oldKeyWindow = [[UIApplication sharedApplication] keyWindow];
	self.windowLevel = UIWindowLevelAlert;
	[super makeKeyAndVisible];
}

- (void) resignKeyWindow
{
	[super resignKeyWindow];
	[self.oldKeyWindow makeKeyWindow];
}

@end

@class PopoverViewController;

@protocol PopoverViewControllerDelegate <NSObject>

- (void)popoverViewController:(PopoverViewController *)popoverViewController didReceiveTouchesEnded:(NSSet *)touches;

@end

@interface PopoverViewController : UIViewController
@property (weak, nonatomic) id<PopoverViewControllerDelegate>delegate;
@end

@implementation PopoverViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(popoverViewController:didReceiveTouchesEnded:)]) {
        [self.delegate popoverViewController:self didReceiveTouchesEnded:touches];
    }
}

@end

@interface CRGPopoverView() <PopoverViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PopoverViewController *controller;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) CALayer *borderLayer;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *items;
@end

@implementation CRGPopoverView {
    CGRect _rect;
    CGFloat _width;
}

- (id)initWithItems:(NSArray *)items fromRect:(CGRect)rect width:(CGFloat)width
{
    if (self = [super init]) {
        _rect = rect;
        _width = width;
        _items = items;
        [self CRGPopoverView_commonInit];
    }
    return self;
}

- (void)CRGPopoverView_commonInit
{
    float totalHeight = ARROW_HEIGHT + ([self.items count] * CELL_HEIGHT) + (BORDER_WIDTH*2.) + (PADDING*2.);
    CGFloat originX = MIN( ([[self class] windowFrame].size.width - WINDOW_PADDING - _width),
                           (CGRectGetMidX(_rect) - (_width/2.)) );
    self.frame = CGRectMake(originX, CGRectGetMaxY(_rect) + 4., _width, totalHeight);
    self.backgroundColor = [UIColor clearColor];

    float tableHeight = [self.items count] * CELL_HEIGHT;
    
    // Add content view
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(BORDER_WIDTH,
                                                            ARROW_HEIGHT + BORDER_WIDTH,
                                                            _width - (BORDER_WIDTH*2.),
                                                            tableHeight + (PADDING*2.))];
    _contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"popover-bg"]];
    
    // Add border
    _borderLayer = [CALayer layer];
    _borderLayer.frame = CGRectMake(-BORDER_WIDTH, -BORDER_WIDTH, _width, tableHeight + (BORDER_WIDTH*2.) + (PADDING*2.));
    _borderLayer.borderColor = [UIColor colorWithRed:(158./255.) green:(150./255.) blue:(123./255.) alpha:1].CGColor;
    _borderLayer.borderWidth = BORDER_WIDTH;
    _borderLayer.cornerRadius = CORNER_RADIUS;

    [_contentView.layer addSublayer:_borderLayer];

    _contentView.layer.shadowOffset = CGSizeMake(0.,0.5);
    _contentView.layer.shadowOpacity = 1;
    _contentView.layer.shadowRadius = 10;
    _contentView.layer.shadowColor = [UIColor blackColor].CGColor;

    [self addSubview:_contentView];
    
    // Add arrow layer 
    CAShapeLayer *arrowLayer = [CAShapeLayer layer];
    arrowLayer.fillColor = [UIColor colorWithRed:(158./255.) green:(150./255.) blue:(123./255.) alpha:1].CGColor;
    
    CGMutablePathRef path = CGPathCreateMutable();
    float arrowMidX = CGRectGetMidX(_rect) - originX;
    CGPathMoveToPoint(path, NULL, arrowMidX - (ARROW_WIDTH/2.), ARROW_HEIGHT);
    CGPathAddLineToPoint(path, NULL, arrowMidX + (ARROW_WIDTH/2.), ARROW_HEIGHT);
    CGPathAddLineToPoint(path, NULL, arrowMidX, 0.);
    CGPathCloseSubpath(path);
    arrowLayer.path = path;
    
    [self.layer addSublayer:arrowLayer];
    
    // Add table view
    CGRect tableViewFrame = CGRectMake(PADDING,
                                       PADDING,
                                       _width - (BORDER_WIDTH*2.) - (PADDING*2.),
                                       tableHeight);
    _tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    _tableView.rowHeight = CELL_HEIGHT;
    _tableView.scrollEnabled = NO;
    _tableView.layer.cornerRadius = 3.;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentView addSubview:_tableView];
    
    [self setNeedsLayout];
}

#pragma mark -

+ (CGRect)windowFrame
{
    CGRect windowFrame = [UIScreen mainScreen].bounds;
    if (windowFrame.size.height > windowFrame.size.width) { // portrait orientation
        CGFloat tempWidth = windowFrame.size.height;
        windowFrame.size.height = windowFrame.size.width;
        windowFrame.size.width = tempWidth;
    }
    return windowFrame;
}

- (CGSize)sizeThatFits:(CGSize)unused
{
	CGSize s = [self recalcSizeAndLayout: NO];
	return s;
}

- (void)layoutSubviews
{
	[self recalcSizeAndLayout: YES];
}

- (CGSize)recalcSizeAndLayout:(BOOL)layout
{
    float tableHeight = [self.items count] * CELL_HEIGHT;
    
    if (layout) {
        _contentView.frame = CGRectMake(BORDER_WIDTH,
                                        ARROW_HEIGHT + BORDER_WIDTH,
                                        _width - (BORDER_WIDTH*2.),
                                        tableHeight + (PADDING*2.));

        _borderLayer.frame = CGRectMake(-BORDER_WIDTH, -BORDER_WIDTH, _width, tableHeight + (BORDER_WIDTH*2.) + (PADDING*2.));

        _tableView.frame = CGRectMake(PADDING,
                                      PADDING,
                                      _width - (BORDER_WIDTH*2.) - (PADDING*2.),
                                      tableHeight);
    }
    float totalHeight = ARROW_HEIGHT + tableHeight + (BORDER_WIDTH*2.) + (PADDING*2.);
    return CGSizeMake( _width, totalHeight );
}

- (void) show
{
	[[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate date]];
    
    self.controller = [[PopoverViewController alloc] init];
	self.controller.view.backgroundColor = [UIColor clearColor];
    self.controller.delegate = self;
    
	// $important - the window is released only when the user clicks an alert view button
    self.window = [[PopoverViewOverlayWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
	self.window.alpha = 0.0;
	self.window.backgroundColor = [UIColor clearColor];
    self.window.rootViewController = self.controller;
	[self.window makeKeyAndVisible];
    
	// fade in the window
	[UIView animateWithDuration: 0.2 animations: ^{
		self.window.alpha = 1;
	}];
	
	[self.controller.view addSubview: self];
	[self sizeToFit];
}

#pragma mark - PopoverViewControllerDelegate

- (void)popoverViewController:(PopoverViewController *)popoverViewController didReceiveTouchesEnded:(NSSet *)touches
{
    [self.window resignKeyWindow];
    self.window = nil;
    
    if ([self.delegate respondsToSelector:@selector(popoverViewDidCancel:)]) {
        [self.delegate popoverViewDidCancel:self];
    }

}

#pragma mark - UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.items count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.window resignKeyWindow];
    self.window = nil;
    
    if ([self.delegate respondsToSelector:@selector(popoverView:didDismissWithItemIndex:)]) {
        [self.delegate popoverView:self didDismissWithItemIndex:indexPath.row];
    }
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	CRGPopoverCell *cell = [tableView dequeueReusableCellWithIdentifier:PopoverCellID];
    if (! cell) {
        cell = [[CRGPopoverCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:PopoverCellID];
    }
    
    cell.titleLabel.text = self.items[indexPath.row];
    
    if (indexPath.row == 0) cell.cellType = CellTypeTop;
    else if (indexPath.row == ([self.items count] - 1)) cell.cellType = CellTypeBottom;
    else cell.cellType = CellTypeMiddle;
	
	return cell;
}

@end
