//
//  GameEngine.m
//  PencuSe
//
//  Created by Ahmet Karalar on 4/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "GameEngine.h"
#import "Move.h"
#import "BlocksKit.h"
#import "Game.h"

NSString * const DidStartGame = @"DidStartGame";
NSString * const DidRollInitialDiceForRed = @"DidRollInitialDiceForRed";
NSString * const DidRollInitialDiceForBlack = @"DidRollInitialDiceForBlack";
NSString * const WillRerollInitialDice = @"WillRollInitialDice";
NSString * const DidRollDice = @"DidRollDice";
NSString * const DidMakeMove = @"DidMakeMove";
NSString * const DidHitBlot = @"DidHitBlot";
NSString * const DidFinishTurn = @"DidFinishTurn";
NSString * const DidRunOutOfMoves = @"DidRunOutOfMoves";

static const NSInteger kDisplayDelay = 1;

static NSInteger RollDie() {

    return (NSInteger)(arc4random_uniform(6) + 1);
}

@interface GameEngine ()

@property (nonatomic, readwrite) NSArray *dice;
@property (nonatomic) NSMutableArray *remainingDice;
@property (nonatomic, getter = isDoubleRoll) BOOL doubleRoll;

@property (nonatomic, readwrite) Game *game;
@property (nonatomic, readwrite) CheckerColor movingColor;

@property (nonatomic, readwrite, getter = isWaitingForRoll) BOOL waitingForRoll;

@property (nonatomic) NSDictionary *moveGraph;
@property (nonatomic) NSArray *legalMoves;



- (void)rollForGameStart;
- (void)determineStartingColorForRolls:(NSArray *)rolls;
- (void)rollForMove;

- (void)processLegalMovesOrMoveGraph;

- (BOOL)isDistance:(NSInteger)distance possibleWithDice:(NSArray *)dice;

- (id)legalMovesForGame:(Game *)game andDice:(NSArray *)dice;

- (void)finishTurn;

@end

@implementation GameEngine

+ (instancetype)sharedEngine
{
    static dispatch_once_t onceToken = 0;
    __strong static GameEngine *_sharedObject = nil;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[GameEngine alloc] init];
    });
    return _sharedObject;
}

- (void)newGame
{
    Game *game = [Game newGame];
    self.game = game;

    self.movingColor = 0; // no one is moving at the start

    self.remainingDice = [NSMutableArray array];

    self.waitingForRoll = YES;

    [[NSNotificationCenter defaultCenter] postNotificationName:DidStartGame
                                                        object:self.game];
}

- (void)roll
{
    if (!self.waitingForRoll) {
        return;
    }

    if (self.movingColor != CheckerColorRed &&
        self.movingColor != CheckerColorBlack) {

        [self rollForGameStart];
    }
    else {

        [self rollForMove];
    }
}

- (void)rollForGameStart
{
    if (self.remainingDice.count > 1) {
        return;
    }

    NSInteger die = RollDie();
    [self.remainingDice addObject:@(die)];

    if (self.remainingDice.count == 2) {

        [[NSNotificationCenter defaultCenter] postNotificationName:DidRollInitialDiceForBlack
                                                            object:@(die)];
        [self determineStartingColorForRolls:self.remainingDice];

    }
    else {

        [[NSNotificationCenter defaultCenter] postNotificationName:DidRollInitialDiceForRed
                                                            object:@(die)];
    }

}

- (void)determineStartingColorForRolls:(NSArray *)rolls
{
    NSInteger redsRoll = [[rolls firstObject] integerValue];
    NSInteger blacksRoll = [[rolls lastObject] integerValue];

    if (redsRoll == blacksRoll) { // start over

        [self.remainingDice removeAllObjects];
        self.waitingForRoll = NO;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(kDisplayDelay * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{

                           self.waitingForRoll = YES;
                           [[NSNotificationCenter defaultCenter]
                            postNotificationName:WillRerollInitialDice
                            object:nil];
                       });
        return;
    }

    if (redsRoll > blacksRoll) {

        self.movingColor = CheckerColorRed;
    }
    else {

        self.movingColor = CheckerColorBlack;
    }

    self.dice = @[@(redsRoll), @(blacksRoll)];

    // sort in descending order
    self.dice = [self.dice sortedArrayUsingSelector:@selector(compare:)];
    self.dice = [[self.dice reverseObjectEnumerator] allObjects];
    self.doubleRoll = NO;
    self.waitingForRoll = NO;

    [self processLegalMovesOrMoveGraph];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [[NSNotificationCenter defaultCenter] postNotificationName:DidRollDice
                                                            object:self.dice];
    });
}

- (void)rollForMove
{
    NSInteger die1 = RollDie();
    NSInteger die2 = RollDie();

    if (die1 == die2) {

        self.dice = @[@(die1), @(die1), @(die1), @(die1)];
        self.doubleRoll = YES;
    }
    else {

        self.dice = @[@(die1), @(die2)];
        self.doubleRoll = NO;
    }

    // sort in descending order
    self.dice = [self.dice sortedArrayUsingSelector:@selector(compare:)];
    self.dice = [[self.dice reverseObjectEnumerator] allObjects];
    self.remainingDice = [self.dice mutableCopy];
    [[NSNotificationCenter defaultCenter] postNotificationName:DidRollDice object:self.dice];


    [self processLegalMovesOrMoveGraph];
}

- (BOOL)canMoveCheckerAtIndex:(NSInteger)fromIdx toIndex:(NSInteger)toIdx
{
    NSInteger pips = toIdx - fromIdx;

    if ((fromIdx == kBarIndex || toIdx == kBearedOffIndex) &&
        self.movingColor == CheckerColorBlack) {
        pips += kBarIndex;
    }

    // moving backwards is not allowed
    if ((pips > 0 && self.movingColor == CheckerColorRed) ||
        (pips < 0 && self.movingColor == CheckerColorBlack && fromIdx != kBarIndex)) {

        return NO;
    }


    pips = ABS(pips);
    Checker *checker = [[self.game.checkers bk_select:^BOOL(Checker *aChecker) {

        return aChecker.index == fromIdx && aChecker.color == self.movingColor;
    }] lastObject];

    // TODO: can be more than 1 Move (total of 2 or more dice), so check all points beforehand
    // TODO: create multiple moves..

    Move *move = [[Move alloc] initWithChecker:checker pips:pips];

    // move is illegal if pips do not equal rolled dice (except when bearing off with a larger die
    if (![self isDistance:pips possibleWithDice:self.remainingDice] &&
        move.indexAfterMove != kBearedOffIndex) {

        return NO;
    }

    BOOL canMove;
    if (self.doubleRoll || self.remainingDice.count == 1) {

        canMove = self.legalMoves.count > 0;
    }
    else {

        BOOL canPlayAllDice = [self.moveGraph bk_any:^BOOL(Move *moveAsDictKey,
                                                      NSArray *movesAsValue) {

            return movesAsValue.count > 0;
        }];

        self.legalMoves = [self.moveGraph bk_match:^BOOL(Move *moveAsDictKey,
                                                         NSArray *movesAsValue) {

            return (move.checker.color == moveAsDictKey.checker.color &&
                    move.checker.index == moveAsDictKey.checker.index &&
                    move.indexAfterMove == moveAsDictKey.indexAfterMove);
            
        }];

        if (canPlayAllDice) {
            canMove = self.legalMoves.count > 0;
        }
        else {

            BOOL canPlayBiggerDie = [self.moveGraph bk_any:^BOOL(Move *moveAsDictKey,
                                                                 NSArray *movesAsValue) {

                return moveAsDictKey.pips == [[self.dice firstObject] integerValue];
            }];

            if (canPlayBiggerDie) {

                canMove = (pips == [[self.dice firstObject] integerValue] ||
                           self.legalMoves != nil);
            }
            else {

                canMove = (pips == [[self.dice lastObject] integerValue] ||
                            self.legalMoves != nil);
            }
        }
    }

    return canMove && [self.game isMoveLegal:move];
}

#pragma mark - Helpers

- (id)legalMovesForGame:(Game *)game andDice:(NSArray *)dice
{
    if (dice.count == 1) {

        NSInteger die = [[dice firstObject] integerValue];

        NSMutableArray *legalMoves = [NSMutableArray array];
        for (Checker *checker in game.checkers) {

            if (checker.color != self.movingColor) {
                continue;
            }

            Move *move = [[Move alloc] initWithChecker:checker pips:die];

            if ([game isMoveLegal:move]) {
                [legalMoves addObject:move];
            }
        }

        return [legalMoves copy];
    }
    else {

        NSMutableDictionary *moveGraph = [NSMutableDictionary dictionary];

        for (NSUInteger i = 0; i < dice.count; ++i) {

            NSInteger die = [dice[i] integerValue];

            NSData *dataRepr = [NSKeyedArchiver archivedDataWithRootObject:dice];
            NSMutableArray *diceAfterMove = [[NSKeyedUnarchiver
                                              unarchiveObjectWithData:dataRepr] mutableCopy];
            [diceAfterMove removeObjectAtIndex:i];

            @autoreleasepool {

                for (Checker *checker in game.checkers) {

                    if (checker.color != self.movingColor) {
                        continue;
                    }

                    dataRepr = [NSKeyedArchiver archivedDataWithRootObject:game.checkers];
                    NSArray *checkers = [[NSKeyedUnarchiver
                                          unarchiveObjectWithData:dataRepr] mutableCopy];
                    Move *move = [[Move alloc] initWithChecker:checker pips:die];

                    if ([game isMoveLegal:move]) {

                        Game *gameAfterMove = [[Game alloc] initWithCheckers:checkers];
                        [gameAfterMove makeMove:move];

                        [moveGraph setObject:[self legalMovesForGame:gameAfterMove
                                                             andDice:diceAfterMove]
                                      forKey:move];
                    }
                }
            }
        }

        return [moveGraph copy];
    }
}

- (void)processLegalMovesOrMoveGraph
{
    self.moveGraph = nil;
    self.legalMoves = nil;
    NSData *dataRepr = [NSKeyedArchiver archivedDataWithRootObject:self.game.checkers];
    NSArray *checkers = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepr];

    // if we rolled a double, the legality of moves are independent of each other
    if (self.isDoubleRoll || self.remainingDice.count == 1) {

        dataRepr = [NSKeyedArchiver archivedDataWithRootObject:@[[self.remainingDice lastObject]]];
        NSArray *dice = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepr];

        Game *game = [[Game alloc] initWithCheckers:checkers];

        self.legalMoves = [self legalMovesForGame:game andDice:dice];

    }
    else {

        // if we didn't roll a double, legality of a move depends on previous move
        // so we make a graph
        dataRepr = [NSKeyedArchiver archivedDataWithRootObject:self.dice];
        NSArray *dice = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepr];


        Game *game = [[Game alloc] initWithCheckers:checkers];

        self.moveGraph = [self legalMovesForGame:game andDice:dice];

    }

    if ((self.moveGraph && self.moveGraph.count == 0) ||
        (self.legalMoves && self.legalMoves.count == 0)) {

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDisplayDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            [[NSNotificationCenter defaultCenter] postNotificationName:DidRunOutOfMoves
                                                                object:nil];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDisplayDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self finishTurn];
            });
        });
    }

    if (self.remainingDice.count > 0) {
        self.waitingForRoll = NO;
    }
}

- (BOOL)isDistance:(NSInteger)distance possibleWithDice:(NSArray *)dice
{
    BOOL distanceEqualsADie = [dice containsObject:@(distance)];

    if (distanceEqualsADie) {

        return YES;
    }

    return NO;
}

- (void)moveCheckerAtIndex:(NSInteger)fromIdx toIndex:(NSInteger)toIdx
{
    if (toIdx == fromIdx) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DidMakeMove
                                                            object:@[@(fromIdx), @(toIdx)]];
        return;
    }

    if (![self canMoveCheckerAtIndex:fromIdx toIndex:toIdx]) {

        return;
    }


    NSInteger pips = toIdx - fromIdx;

    if ((fromIdx == kBarIndex || toIdx == kBearedOffIndex) &&
        self.movingColor == CheckerColorBlack) {

        pips += kBarIndex;
    }

    pips = ABS(pips);
    Checker *checker = [[self.game.checkers bk_select:^BOOL(Checker *aChecker) {
        return aChecker.index == fromIdx;
    }] lastObject];
    Move *move = [[Move alloc] initWithChecker:checker pips:pips];
    Checker *blotToHit = [self.game makeMove:move];
    if (blotToHit) {

        [[NSNotificationCenter defaultCenter] postNotificationName:DidHitBlot
                                                            object:@[@(toIdx), @(kBarIndex)]];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:DidMakeMove
                                                        object:@[@(fromIdx), @(toIdx)]];

    if (toIdx == kBearedOffIndex) {

        NSUInteger index = [self.remainingDice indexOfObject:@(pips)];

        if (index == NSNotFound) {

            [self.remainingDice removeObjectAtIndex:0];
        }
        else {
            [self.remainingDice removeObjectAtIndex:index];
        }

    } else {

        [self.remainingDice removeObjectAtIndex:[self.remainingDice indexOfObject:@(pips)]];
    }


    if (self.remainingDice.count == 0) {

        [self finishTurn];
    }
    else {

        [self processLegalMovesOrMoveGraph];
    }
}

- (void)finishTurn
{
    self.waitingForRoll = YES;
    self.movingColor = (self.movingColor == CheckerColorRed ?
                        CheckerColorBlack :
                        CheckerColorRed);

    [[NSNotificationCenter defaultCenter] postNotificationName:DidFinishTurn
                                                        object:nil];

}

- (CheckerColor)opponentColor
{
    switch (self.movingColor) {
        case CheckerColorRed:
            return CheckerColorBlack;
        case CheckerColorBlack:
            return CheckerColorRed;
        default:
            return 0;
    }
}

@end
