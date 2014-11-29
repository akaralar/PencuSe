//
//  MenuViewController.m
//  PencuSe
//
//  Created by Ahmet Karalar on 29/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "MenuViewController.h"
#import "Masonry.h"
#import "BoardViewController.h"

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

    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;

    NSArray *titles = @[@"1 vs 1", @"Load Game"];
    NSMutableArray *buttons = [NSMutableArray array];

    for (NSInteger i = 0; i < MenuButtonIndex_COUNT; ++i) {

        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:NSLocalizedString(titles[(NSUInteger)i], nil)
                forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(didTapButton:)
         forControlEvents:UIControlEventTouchUpInside];
        [buttons addObject:button];
        [self.view addSubview:button];

        [button mas_makeConstraints:^(MASConstraintMaker *make) {

            CGFloat yOffset;
            switch ((MenuButtonIndex)i) {

                case MenuButtonIndexMultiplayer:
                    yOffset = -50;
                    break;

                case MenuButtonIndexLoad:
                    yOffset = 50;
                    break;
            
                case MenuButtonIndex_COUNT:
                    NSAssert(NO, @"this shouldn't happen o.O");
                    break;
            }
            make.center.equalTo(self.view).centerOffset(CGPointMake(0, yOffset));
        }];
    }
}

#pragma mark - Actions

- (void)didTapButton:(UIButton *)button
{
    switch ((MenuButtonIndex)[self.buttons indexOfObject:button]) {

        case MenuButtonIndexMultiplayer:

            [self startMultiplayerGame];
            break;

        case MenuButtonIndexLoad:

            [self loadGame];
            break;

        case MenuButtonIndex_COUNT:

            NSAssert(NO, @"this shouldn't happen o.O");
            break;
    }
}

- (void)loadGame
{
    // TODO: implement game loading mechanism
}

- (void)startMultiplayerGame
{
    BoardViewController *controller = [[BoardViewController alloc]
                                       initWithGameMode:GameModeMultiplayer];
}

@end
