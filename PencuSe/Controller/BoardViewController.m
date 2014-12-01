//
//  BoardViewController.m
//  PencuSe
//
//  Created by Ahmet Karalar on 29/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "BoardViewController.h"
#import "BoardView.h"
#import "Masonry.h"
#import "PointView.h"
#import "CheckerView.h"
#import "BlocksKit.h"

@interface BoardViewController ()

@property (nonatomic) BoardView *boardView;
@property (nonatomic) NSArray *checkers;

@end

@implementation BoardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    self.boardView = [[BoardView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.boardView];

    [self.boardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    for (NSInteger i = 0; i < 2; ++i) {

        for (NSInteger j = 0; j < 15; ++j) {

        }
    }



}

@end
