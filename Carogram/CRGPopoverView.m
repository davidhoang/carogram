//
//  CRGPopoverView.m
//  Carogram
//
//  Created by Jacob Moore on 3/4/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGPopoverView.h"
#import <QuartzCore/QuartzCore.h>

#define WIDTH           340.
#define HEIGHT          235.
#define BORDER_WIDTH    10.
#define CORNER_RADIUS   13.
#define PADDING         11.

@interface PopoverViewOverlayWindow : UIWindow
@property (nonatomic,retain) UIWindow* oldKeyWindow;
@end

@implementation  PopoverViewOverlayWindow

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
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *items;
@end

@implementation CRGPopoverView

- (id)initWithItems:(NSArray *)items
{
    if (self = [super init]) {
        _items = items;
        
        self.frame = CGRectMake(677., 47., WIDTH, HEIGHT);
        self.backgroundColor = [UIColor clearColor];
        
        // Add content view
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, WIDTH, HEIGHT - 15)];
        _contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"popover-bg"]];
        
        // Add border
        _contentView.layer.borderColor = [UIColor colorWithRed:(158./255.) green:(150./255.) blue:(123./255.) alpha:1].CGColor;
        _contentView.layer.borderWidth = BORDER_WIDTH;
        _contentView.layer.cornerRadius = CORNER_RADIUS;
        
        _contentView.layer.shadowOffset = CGSizeMake(0.,0.5);
        _contentView.layer.shadowOpacity = .82;
        _contentView.layer.shadowRadius = 10;
        _contentView.layer.shadowColor = [UIColor blackColor].CGColor;

        [self addSubview:_contentView];
        
        // Add arrow layer 
        CAShapeLayer *arrowLayer = [CAShapeLayer layer];
        arrowLayer.fillColor = [UIColor colorWithRed:(158./255.) green:(150./255.) blue:(123./255.) alpha:1].CGColor;
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 310., 15.);
        CGPathAddLineToPoint(path, NULL, 328., 15.);
        CGPathAddLineToPoint(path, NULL, 319., 0.);
        CGPathCloseSubpath(path);
        arrowLayer.path = path;
        
        [self.layer addSublayer:arrowLayer];
        
        // Add table view
        float inset = BORDER_WIDTH + PADDING;
        CGRect tableViewFrame =  CGRectMake(inset,
                                            inset,
                                            _contentView.frame.size.width - (inset*2),
                                            _contentView.frame.size.height - (inset*2));
        _tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self.contentView addSubview:_tableView];
        
        [self setNeedsLayout];
    }
    return self;
}

//#pragma mark - Drawing
//
//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
////    [self drawArrow:context];
//}
//
//- (void)drawArrow:(CGContextRef)context
//{
//    CGContextBeginPath(context);
//    CGContextMoveToPoint(context, 310., 15.);
////    CGContextAddLineToPoint(context, 10., 15.);
//    CGContextAddLineToPoint(context, 328., 15.);
//    CGContextAddLineToPoint(context, 319., 0.);
//    CGContextClosePath(context);
//    CGContextSetFillColorWithColor(context,
//                                   [UIColor colorWithRed:(158./255.) green:(150./255.) blue:(123./255.) alpha:1].CGColor);
//    CGContextFillPath(context);
//}

#pragma mark -

- (CGSize) sizeThatFits: (CGSize) unused
{
    return CGSizeMake(WIDTH, HEIGHT);
//	CGSize s = [self recalcSizeAndLayout: NO];
//	return s;
}

- (void) layoutSubviews
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
//	[self recalcSizeAndLayout: YES];
}

- (void) show
{
//    [self registerBackgroundNotification];
    
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
	
	// add and pulse the alertview
	// add the alertview
	[self.controller.view addSubview: self];
	[self sizeToFit];
//	self.center = CGPointMake( CGRectGetMidX( self.controller.view.bounds ), CGRectGetMidY( self.controller.view.bounds ) );
//	self.frame = CGRectIntegral( self.frame );
//	[self pulse];
	
}

#pragma mark - PopoverViewControllerDelegate

- (void)popoverViewController:(PopoverViewController *)popoverViewController didReceiveTouchesEnded:(NSSet *)touches
{
    [self.window resignKeyWindow];
    
    self.window = nil;

}

#pragma mark - UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.items count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//	UITableViewCell *targetCell = [tableView cellForRowAtIndexPath:indexPath];
//	self.pickerView.date = [self.dateFormatter dateFromString:targetCell.detailTextLabel.text];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellID = @"CellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellID];
	}
	
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    cell.textLabel.text = self.items[indexPath.row];
    
//	cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
//    if (indexPath.row == 0) {
//        cell.detailTextLabel.text = [self.dateFormatter stringFromDate:startDate];
//        if (selectedDate == 0) {
//            [self.tableView selectRowAtIndexPath: indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
//            self.pickerView.date = [self.dateFormatter dateFromString:cell.detailTextLabel.text];
//        }
//    } else {
//        cell.detailTextLabel.text = [self.dateFormatter stringFromDate:endDate];
//        if (selectedDate == 1) {
//            [self.tableView selectRowAtIndexPath: indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
//            self.pickerView.date = [self.dateFormatter dateFromString:cell.detailTextLabel.text];
//        }
//    }
	
	return cell;
}


@end
