//
//  MenuViewController.m
//  PencuSe
//
//  Created by Ahmet Karalar on 29/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "MenuViewController.h"

typedef NS_ENUM(NSInteger, MenuButtonIndex) {
    MenuButtonIndexMultiplayer,
    MenuButtonIndexLoad,

    MenuButtonIndex_COUNT
};


@interface MenuViewController ()

@property (nonatomic) NSArray *buttons;


- (void)didTapButton:(UIButton *)button;

- (void)startMultiplayerGame;
- (void)loadGame;

@end

@implementation MenuViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];


    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:NSLocalizedString(@"1 vs 1", nil) forState:UIControlStateNormal];

    
}

#pragma mark - Actions

- (void)didTapButton:(UIButton *)button
{
    
}

- (void)loadGame
{
    
}

- (void)startMultiplayerGame
{
    
}

@end
