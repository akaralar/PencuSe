//
//  DashboardViewController.m
//  PencuSe
//
//  Created by Ahmet Karalar on 30/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "DashboardViewController.h"
#import "GameEngine.h"
#import "Masonry.h"

@interface DashboardViewController ()

@property (nonatomic) UILabel *infoLabel;

@end

@interface DashboardViewController ()

- (void)didReceiveNotification:(NSNotification *)notification;

- (void)didStartGame;
- (void)didRollInitialDie:(NSInteger)die forColor:(CheckerColor)color;
- (void)willRerollInitialDice;
- (void)didRollMoveDice:(NSArray *)dice;
- (void)didFinishTurn;
- (void)didRunOutOfMoves;

- (NSString *)nameForColor:(CheckerColor)color;
@end

@implementation DashboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    self.infoLabel.numberOfLines = 0;
    [self.view addSubview:self.infoLabel];

    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    NSArray *notificationNames = @[DidStartGame,
                                   DidRollInitialDiceForRed,
                                   DidRollInitialDiceForBlack,
                                   WillRerollInitialDice,
                                   DidRollDice,
                                   DidFinishTurn,
                                   DidRunOutOfMoves];

    for (NSString *notificationName in notificationNames) {

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveNotification:)
                                                     name:notificationName
                                                   object:nil];
    }
}

- (void)didReceiveNotification:(NSNotification *)notification
{
    if (notification.name == DidStartGame) {

        [self didStartGame];
    }
    else if (notification.name == DidRollInitialDiceForRed) {

        NSInteger die = [notification.object integerValue];
        [self didRollInitialDie:die forColor:CheckerColorRed];

    }
    else if (notification.name == DidRollInitialDiceForBlack) {

        NSInteger die = [notification.object integerValue];
        [self didRollInitialDie:die forColor:CheckerColorBlack];

    }
    else if (notification.name == WillRerollInitialDice) {

        [self willRerollInitialDice];
    }
    else if (notification.name == DidRollDice) {

        NSArray *dice = notification.object;
        [self didRollMoveDice:dice];
    }
    else if (notification.name == DidFinishTurn) {

        [self didFinishTurn];
    }
    else if (notification.name == DidRunOutOfMoves) {

        [self didRunOutOfMoves];
    }
}

- (void)didStartGame
{
    self.infoLabel.text = NSLocalizedString(@"Initial Roll", nil);
}

- (void)didRollInitialDie:(NSInteger)die forColor:(CheckerColor)color
{
    NSString *colorName = [self nameForColor:color];
    NSMutableString *stringToAppend = [NSMutableString stringWithFormat:@"\n%@: %ld", colorName, (long)die];
    NSMutableString *info = [self.infoLabel.text mutableCopy];
    [info appendString:stringToAppend];

    self.infoLabel.text = [info copy];
}

- (void)willRerollInitialDice
{
    self.infoLabel.text = NSLocalizedString(@"Deuce!\nRoll Again", nil);
}

- (void)didRollMoveDice:(NSArray *)dice
{
    NSString *color = [self nameForColor:[GameEngine sharedEngine].movingColor];
    NSMutableString *info = [NSMutableString
                             stringWithFormat:NSLocalizedString(@"%@ to move", nil), color];
    [info appendString:@"\n"];
    [info appendString:NSLocalizedString(@"Dice", nil)];
    [info appendString:@": "];

    for (NSUInteger i = 0; i < 2; ++i) {
        [info appendFormat:@"%ld ", (long)[dice[i] integerValue]];
    }

    self.infoLabel.text = [info copy];
}

- (void)didFinishTurn
{
    NSString *color = [self nameForColor:[GameEngine sharedEngine].movingColor];
    NSMutableString *info = [NSMutableString
                             stringWithFormat:NSLocalizedString(@"%@ to roll", nil), color];
    self.infoLabel.text = [info copy];
}

- (void)didRunOutOfMoves
{
    self.infoLabel.text = NSLocalizedString(@"No Moves :(", nil);
}

- (NSString *)nameForColor:(CheckerColor)color
{
    switch (color) {
        case CheckerColorRed:
            return NSLocalizedString(@"Red", nil);
        case CheckerColorBlack:
            return NSLocalizedString(@"Black", nil);
            break;
    }
}

@end
