//
//  GameViewController.m
//  PencuSe
//
//  Created by Ahmet Karalar on 30/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "GameViewController.h"
#import "BoardViewController.h"
#import "DashboardViewController.h"
#import "Masonry.h"

@interface GameViewController ()

@property (nonatomic) GameMode gameMode;

@property (nonatomic) UIView *boardContainerView;
@property (nonatomic) UIView *dashboardContainerView;

@property (nonatomic) BoardViewController *boardController;
@property (nonatomic) DashboardViewController *dashboardController;

- (void)setupConstraints;
- (void)setupHorizontalLayout;
- (void)setupVerticalLayout;

@end

@implementation GameViewController

- (instancetype)initWithGameMode:(GameMode)mode
{
    self = [self init];

    if (!self) {
        return nil;
    }

    _gameMode = mode;

    return self;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    UIView *view = [[UIView alloc] init];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor darkGrayColor];

    self.boardContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    [view addSubview:self.boardContainerView];

    self.dashboardContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    [view addSubview:_dashboardContainerView];

    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupConstraints];

    self.boardController = [[BoardViewController alloc] init];
    [self addChildViewController:self.boardController];
    [self.boardContainerView addSubview:self.boardController.view];
    [self.boardController didMoveToParentViewController:self];

    self.dashboardController = [[DashboardViewController alloc] init];
    [self addChildViewController:self.dashboardController];
    [self.dashboardContainerView addSubview:self.dashboardController.view];
    [self.dashboardController didMoveToParentViewController:self];
}

#pragma mark - Rotation Handling

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if (size.width > size.height) {

        [self setupHorizontalLayout];
    }
    else {

        [self setupVerticalLayout];
    }
}

#pragma mark - Constraints

- (void)setupConstraints
{
    CGSize size = [UIScreen mainScreen].bounds.size;

    if (size.width > size.height) {

        [self setupHorizontalLayout];
    }
    else {

        [self setupVerticalLayout];
    }
}

- (void)setupHorizontalLayout
{
    [self.boardContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {

        make.top.bottom.and.left.equalTo(self.view);
        make.right.equalTo(self.dashboardContainerView.mas_left);
    }];

    [self.dashboardContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {

        make.top.bottom.and.right.equalTo(self.view);
        make.width.equalTo(self.view).dividedBy(6);
    }];
}

- (void)setupVerticalLayout
{
    [self.boardContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {

        make.left.top.and.right.equalTo(self.view);
        make.bottom.equalTo(self.dashboardContainerView.mas_top);
    }];

    [self.dashboardContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {

        make.left.bottom.and.right.equalTo(self.view);
        make.height.equalTo(self.view).dividedBy(2);
    }];
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
