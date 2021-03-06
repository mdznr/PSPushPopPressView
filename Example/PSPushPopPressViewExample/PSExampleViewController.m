//
//  PSViewController.m
//  PSPushPopPressViewExample
//
//  Created by Peter Steinberger on 11/16/11.
//  Copyright (c) 2011 Peter Steinberger. All rights reserved.
//

#import "PSExampleViewController.h"
#import "PSPushPopPressView.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "AVPlayerDemoPlaybackViewController.h"

@implementation PSExampleViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"ExampleView" owner:self options:nil];
    containerView_ = [nibArray objectAtIndex:0];
    containerView_.frame = self.view.bounds;
    containerView_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:containerView_];

    // Create the push pop press container.
    CGRect firstRect = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? CGRectMake(140, 40, 500, 400) : CGRectMake(10, 10, 300, 300);
    pushPopPressView_ = [[PSPushPopPressView alloc] init];
	pushPopPressView_.frame = firstRect;
    pushPopPressView_.pushPopPressViewDelegate = self;
    [containerView_ addSubview:pushPopPressView_];

    // Add a cat image to the container.
    UIImageView *catImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cat.jpg"]];
    catImageView.frame = pushPopPressView_.bounds;
    catImageView.contentMode = UIViewContentModeScaleAspectFill;
    catImageView.backgroundColor = [UIColor blackColor];
    catImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    catImageView.clipsToBounds = YES;
    [pushPopPressView_ addSubview:catImageView];
	
	
    // Create a second Push Pop Press container, with a video.
    pushPopPressVideoView_ = [[PSPushPopPressView alloc] initWithFrame:CGRectMake(140, 500, 500, 400)];
    pushPopPressVideoView_.pushPopPressViewDelegate = self;
    [containerView_ addSubview:pushPopPressVideoView_];
	
    // create the movie player controller
    AVPlayerDemoPlaybackViewController *moviePlayer = [[AVPlayerDemoPlaybackViewController alloc] init];
    moviePlayer.URL = [NSURL URLWithString:@"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"];
	//    MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:@"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"]];
    [self addChildViewController:moviePlayer];
    moviePlayer.view.frame = pushPopPressVideoView_.bounds;
    moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [pushPopPressVideoView_ addSubview:moviePlayer.view];
    [moviePlayer play:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // be sure to nil out delegates
    pushPopPressView_.pushPopPressViewDelegate = nil;
    pushPopPressView_ = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}



#pragma mark - PSPushPopPressViewDelegate

- (void)pushPopPressViewDidStartManipulation:(PSPushPopPressView *)pushPopPressView
{
    NSLog(@"pushPopPressViewDidStartManipulation: %@", pushPopPressView);

    activeCount_++;
    [UIView animateWithDuration:0.4f
						  delay:0.0f
						options:UIViewAnimationOptionBeginFromCurrentState
					 animations:^{
						 // Note that this transformation can't just be applied to self.view, since already applied transforms would be lost.
						 containerView_.transform = CGAffineTransformMakeScale(0.97, 0.97);
    } completion:nil];
}

- (void)pushPopPressViewDidFinishManipulation:(PSPushPopPressView *)pushPopPressView
{
    NSLog(@"pushPopPressViewDidFinishManipulation: %@", pushPopPressView);

    if ( activeCount_ > 0 ) {
        activeCount_--;
        if ( activeCount_ == 0 ) {
            [UIView animateWithDuration:0.45f
								  delay:0.0f
								options:UIViewAnimationOptionBeginFromCurrentState
							 animations:^{
								 containerView_.transform = CGAffineTransformIdentity;
							 }
							 completion:^(BOOL finished){}];
        }
    }
}

- (void)pushPopPressViewWillAnimateToOriginalFrame:(PSPushPopPressView *)pushPopPressView
										  duration:(NSTimeInterval)duration
{
    NSLog(@"pushPopPressViewWillAnimateToOriginalFrame: %@duration: %f", pushPopPressView, duration);
}

- (void)pushPopPressViewDidAnimateToOriginalFrame:(PSPushPopPressView *)pushPopPressView
{
    NSLog(@"pushPopPressViewDidAnimateToOriginalFrame: %@", pushPopPressView);

    // Update autoresizing mask to adapt to width only.
    pushPopPressView.autoresizingMask = UIViewAutoresizingNone;

    // Ensure the view doesn't overlap with another (possible fullscreen) view.
    [containerView_ sendSubviewToBack:pushPopPressView];
}

- (void)pushPopPressViewWillAnimateToFullscreenWindowFrame:(PSPushPopPressView *)pushPopPressView
												  duration:(NSTimeInterval)duration
{
    NSLog(@"pushPopPressViewWillAnimateToFullscreenWindowFrame:%@ duration: %f", pushPopPressView, duration);
}

- (void)pushPopPressViewDidAnimateToFullscreenWindowFrame:(PSPushPopPressView *)pushPopPressView
{
    NSLog(@"pushPopPressViewDidAnimateToFullscreenWindowFrame: %@", pushPopPressView);

    // Update the autoresizing mask to adapt to borders.
    pushPopPressView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

- (BOOL)pushPopPressViewShouldAllowTapToAnimateToOriginalFrame:(PSPushPopPressView *)pushPopPressView
{
    NSLog(@"pushPopPressViewShouldAllowTapToAnimateToOriginalFrame: %@", pushPopPressView);
    return YES;
}

- (BOOL)pushPopPressViewShouldAllowTapToAnimateToFullscreenWindowFrame:(PSPushPopPressView *)pushPopPressView
{
    NSLog(@"pushPopPressViewShouldAllowTapToAnimateToFullscreenWindowFrame: %@", pushPopPressView);
    return YES;
}

- (void)pushPopPressViewDidReceiveTap:(PSPushPopPressView *)pushPopPressView
{
    NSLog(@"pushPopPressViewDidReceiveTap: %@", pushPopPressView);
}

@end
