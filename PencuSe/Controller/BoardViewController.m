//
//  BoardViewController.m
//  PencuSe
//
//  Created by Ahmet Karalar on 29/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "BoardViewController.h"

@interface BoardViewController ()

@end

@implementation BoardViewController

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    NSLog(@"%@", NSStringFromCGSize(size));
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor yellowColor];

}
@end
