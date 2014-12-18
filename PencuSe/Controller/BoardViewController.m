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
#import "GameEngine.h"
#import "Game.h"

@interface BoardViewController ()

@property (nonatomic) BoardView *boardView;
@property (nonatomic) NSArray *checkers;

- (void)didStartNewGame:(NSNotification *)notification;
- (void)didMakeMove:(NSNotification *)notification;
- (void)didHitBlot:(NSNotification *)notification;

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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didStartNewGame:)
                                                 name:DidStartGame
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didMakeMove:)
                                                 name:DidMakeMove
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didHitBlot:)
                                                 name:DidHitBlot
                                               object:nil];


}

- (void)didStartNewGame:(NSNotification *)notification
{
    for (Checker *checker in [GameEngine sharedEngine].game.checkers) {

        [self.boardView createCheckerWithColor:checker.color atIndex:checker.index];
    }
}

- (void)didMakeMove:(NSNotification *)notification
{
    NSInteger toIdx = [[notification.object lastObject] integerValue];

    [self.boardView placeChecker:self.boardView.selectedCheckerView
                         atIndex:toIdx
                        animated:YES];
    
}

- (void)didHitBlot:(NSNotification *)notification
{
    NSInteger fromIdx = [[notification.object firstObject] integerValue];
    NSInteger toIdx = [[notification.object lastObject] integerValue];


    CheckerView *checker = [self.boardView topCheckerAtIndex:fromIdx
                                                    forColor:[GameEngine sharedEngine].opponentColor];
    [self.boardView placeChecker:checker
                         atIndex:toIdx
                        animated:YES];

}

#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];

    CheckerColor movingColor = [GameEngine sharedEngine].movingColor;
    NSInteger pointIndex = [self.boardView pointViewIndexForTouch:touch withEvent:event];
    CheckerView *checker = [self.boardView topCheckerAtIndex:pointIndex
                                                    forColor:movingColor];

    // return if no checker found on point or checker is opponent's or waiting for roll
    if (!checker ||
        [GameEngine sharedEngine].isWaitingForRoll) {
        return;
    }

    [self.boardView selectTopCheckerForTouch:touch
                                   withEvent:event
                                    forColor:movingColor];
    [self.boardView highlightIndex:pointIndex
                         withColor:PointHighlightColorSelected];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.boardView.selectedCheckerView) {
        return;
    }

    UITouch *touch = [touches anyObject];
    CGPoint center = [touch locationInView:self.boardView];
    self.boardView.selectedCheckerView.center = center;

    NSInteger pointIndex = [self.boardView pointViewIndexForTouch:touch withEvent:event];

    BOOL isAllowed = [[GameEngine sharedEngine]
                      canMoveCheckerAtIndex:self.boardView.selectedCheckerIndex
                      toIndex:pointIndex];

    PointHighlightColor color = (isAllowed ?
                                 PointHighlightColorAllowed :
                                 PointHighlightColorForbidden);
    [self.boardView highlightIndex:[self.boardView pointViewIndexForTouch:touch withEvent:event]
                         withColor:color];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.boardView.selectedCheckerView) {
        return;
    }

    UITouch *touch = [touches anyObject];

    NSInteger pointIndex = [self.boardView pointViewIndexForTouch:touch withEvent:event];
    BOOL isAllowed = [[GameEngine sharedEngine]
                      canMoveCheckerAtIndex:self.boardView.selectedCheckerIndex
                      toIndex:pointIndex];

    if (!isAllowed) {
        pointIndex = self.boardView.selectedCheckerIndex;
    }

    [[GameEngine sharedEngine] moveCheckerAtIndex:self.boardView.selectedCheckerIndex 
                                          toIndex:pointIndex];
}

@end
