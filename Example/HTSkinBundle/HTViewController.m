//
//  HTViewController.m
//  HTSkinBundle
//
//  Created by nscribble on 11/09/2022.
//  Copyright (c) 2022 nscribble. All rights reserved.
//

#import "HTViewController.h"
#import "HTSkinBundle_Example-Swift.h"

@interface HTViewController ()

@end

@implementation HTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    TTTestViewController *controller = [[TTTestViewController alloc] init];
    [self.view addSubview:controller.view];
    controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [controller.view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
        [controller.view.heightAnchor constraintEqualToAnchor:self.view.heightAnchor],
        [controller.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [controller.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor]
    ]];
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
