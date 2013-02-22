//
//  CRGNewCommentViewController.m
//  Carogram
//
//  Created by Jacob Moore on 2/21/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGNewCommentViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CRGNewCommentViewController ()
@property (strong, nonatomic) IBOutlet UIView *dialogView;
@property (strong, nonatomic) IBOutlet UITextView *commentTextView;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation CRGNewCommentViewController {
    BOOL _showDialog;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupDialog];
    
    self.titleLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:20.];
    
    _showDialog = YES;
    
    self.commentTextView.keyboardType = UIKeyboardTypeTwitter;
    self.commentTextView.layer.borderWidth = 0.5;
    self.commentTextView.layer.borderColor = [UIColor colorWithRed:(199./255.) green:(196./255.) blue:(196./255.) alpha:1.].CGColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_showDialog) {
        // Hide views initially
        self.view.alpha = 0;
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.commentTextView becomeFirstResponder];
    
    if (_showDialog) {
        _showDialog = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.view.alpha = 1;
        }];
    }
}

- (void)viewDidUnload {
    [self setCommentTextView:nil];
    [self setSubmitButton:nil];
    [self setDialogView:nil];
    [self setTitleLabel:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)submit:(UIButton *)sender {
    self.commentTextView.editable = NO;
    self.submitButton.enabled = NO;
    [self.activityIndicator startAnimating];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        WFIGComment *comment = [[WFIGComment alloc] init];
        comment.text = self.commentTextView.text;
        
        NSError *error;
        [comment postToMedia:self.media error:&error];
        
        if (nil != error) NSLog(@"error: %@", [error description]);
        
        dispatch_async( dispatch_get_main_queue(), ^{
            self.commentTextView.editable = YES;
            self.submitButton.enabled = YES;
            [self.activityIndicator stopAnimating];
        });
    });
}

#pragma mark - Instance methods

- (void)setupDialog
{
    CALayer *borderLayer = [CALayer layer];
    borderLayer.frame = CGRectInset(self.dialogView.bounds, -5., -5.);
    borderLayer.cornerRadius = 7.5;
    borderLayer.borderWidth = 5.0;
    borderLayer.borderColor = [UIColor colorWithWhite:1. alpha:0.36].CGColor;

    [self.dialogView.layer insertSublayer:borderLayer atIndex:0];
    
    self.dialogView.layer.cornerRadius = 2.5;
    self.dialogView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.dialogView.layer.shadowOffset = CGSizeMake(0, 7.5);
    self.dialogView.layer.shadowRadius = 12;
    self.dialogView.layer.shadowOpacity = 1;
}

#pragma mark - Touch handling

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Ignore touches in the dialog
    for (UITouch *touch in touches) {
        CGPoint touchPoint = [touch locationInView:self.view];
        if (CGRectContainsPoint(self.dialogView.frame, touchPoint)) return;
    }
    
    [self.commentTextView resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(newCommentViewControllerDidFinish:)]) {
            [self.delegate newCommentViewControllerDidFinish:self];
        }
    }];
}

@end
