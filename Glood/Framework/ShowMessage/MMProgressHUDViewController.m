//
//  MMProgressHUDViewController.m
//  MMProgressHUDDemo
//
//  Created by Lars Anderson on 6/28/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMProgressHUDViewController.h"
#import "MMProgressHUDWindow.h"
#import "MMProgressHUD.h"

@implementation MMProgressHUDViewController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setView:(UIView *)view{
    [self prefersStatusBarHidden];
    [super setView:view];
    
    //this line is important. this tells the view controller to not resize
    //  the view to display the status bar.
    [self setWantsFullScreenLayout:YES];
}

- (BOOL)oldRootViewControllerShouldRotateToOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    BOOL shouldRotateToOrientation = NO;
    MMProgressHUDWindow *win = (MMProgressHUDWindow *)self.view.window;
    UIViewController *rootViewController = win.oldWindow.rootViewController;
    
    if ([[self superclass] instancesRespondToSelector:@selector(presentedViewController)] &&
        ([rootViewController presentedViewController] != nil)) {
        shouldRotateToOrientation = [rootViewController.presentedViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
    
    if ((shouldRotateToOrientation == NO) &&
        (rootViewController != nil)) {
        shouldRotateToOrientation = [rootViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
    else if(rootViewController == nil){
        
        shouldRotateToOrientation = [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
    
    return shouldRotateToOrientation;
}

/** The rotation callbacks for this view controller will never get fired on iOS <5.0. This must be related to creating a view controller in a new window besides the default keyWindow. Since this is the case, the manual method of animating the rotating the view's transform is used via notification observers added in setView: above.
 
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    if ([self.view.window isKindOfClass:[MMProgressHUDWindow class]]) {
        return [self oldRootViewControllerShouldRotateToOrientation:toInterfaceOrientation];;
    }
    else{
        return [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
}

- (NSUInteger)supportedInterfaceOrientations{
    MMProgressHUDWindow *win = (MMProgressHUDWindow *)self.view.window;
    UIViewController *rootViewController = win.oldWindow.rootViewController;
    
    if ([win isKindOfClass:[MMProgressHUDWindow class]] &&
        [rootViewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return [rootViewController supportedInterfaceOrientations];
    }
    else{
    }
    
    return [super supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate{
    MMProgressHUDWindow *win = (MMProgressHUDWindow *)self.view.window;
    UIViewController *rootViewController = win.oldWindow.rootViewController;
    
    if ([win isKindOfClass:[MMProgressHUDWindow class]] &&
        [rootViewController respondsToSelector:@selector(shouldAutorotate)]) {
        
        return [rootViewController shouldAutorotate];
    }
    else{
    }
    
    return [super shouldAutorotate];
}

- (void)dealloc{
}

@end
