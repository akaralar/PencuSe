//
//  Game.m
//  PencuSe
//
//  Created by Ahmet Karalar on 3/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "Game.h"
#import "BlocksKit.h"
#import "Checker.h"
#import "Move.h"

@interface Game ()

@property (nonatomic) NSMutableArray *checkers_;

- (NSArray *)checkersAtPointIndex:(NSInteger)index forColor:(CheckerColor)color;
- (NSArray *)checkersWithPipsToBearOffLargerThan:(NSInteger)pips forColor:(CheckerColor)color;

- (NSArray *)checkersOnBarForColor:(CheckerColor)color;
- (NSArray *)checkersBearedOffForColor:(CheckerColor)color;
- (NSArray *)checkersBeforeHomeBoardForColor:(CheckerColor)color;
- (NSArray *)checkersOnBoardForColor:(CheckerColor)color;

- (BOOL)entersCheckerIfOnBarWithMove:(Move *)move;
- (BOOL)allCheckersInHomeBoardIfBearingOffWithMove:(Move *)move;
- (BOOL)bearsOffFromHighestPointIfBearingOffWithMove:(Move *)move;
- (BOOL)isPointOpenForMove:(Move *)move;

@end

@implementation Game

#pragma mark - Public

+ (instancetype)newGame
{
    NSArray *checkerIndexes = @[@24, @13, @8, @6];
    NSArray *checkerCounts = @[@2, @5, @3, @5];

    NSMutableArray *checkers = [NSMutableArray array];
    [checkerCounts enumerateObjectsUsingBlock:^(NSNumber *checkerCount,
                                                NSUInteger idx,
                                                BOOL *stop) {

        for (CheckerColor color = CheckerColorRed; color <= CheckerColorBlack; ++color){

            NSInteger idxForColor = [checkerIndexes[idx] integerValue];

            if (color == CheckerColorBlack) {

                idxForColor = 25 - idxForColor;
            }

            for (NSInteger i = 0; i < checkerCount.integerValue; ++i) {

                Checker *checker = [[Checker alloc] init];
                checker.color = color;
                checker.index = idxForColor;
                [checkers addObject:checker];
            }
        }
    }];

    return [[self alloc] initWithCheckers:[checkers copy]];
}

- (instancetype)initWithCheckers:(NSArray *)checkers
{
    self = [super init];

    if (!self) {
        return nil;
    }

    _checkers_ = [[NSMutableArray alloc] initWithArray:checkers copyItems:YES];

    return self;
}

- (NSArray *)checkers
{
    return [_checkers_ copy];
}

- (Checker *)makeMove:(Move *)move
{
    CheckerColor opponent = (move.checker.color == CheckerColorRed ?
                             CheckerColorBlack :
                             CheckerColorRed);

    Checker *blot;
    if (move.indexAfterMove != kBearedOffIndex) {

        NSArray *opponentCheckers = [self checkersAtPointIndex:move.indexAfterMove
                                                      forColor:opponent];
        blot = [opponentCheckers firstObject];

        if (blot) {

            Checker *checker = [[Checker alloc] init];
            checker.color = blot.color;
            checker.index = kBarIndex;

            [_checkers_ removeObjectAtIndex:[_checkers_ indexOfObject:blot]];
            [_checkers_ addObject:checker];
        }

    }

    Checker *checker = [[Checker alloc] init];
    checker.color = move.checker.color;
    checker.index = move.indexAfterMove;

    [_checkers_ removeObjectAtIndex:[_checkers_ indexOfObject:move.checker]];
    [_checkers_ addObject:checker];

    return blot;
}

- (BOOL)isMoveLegal:(Move *)move
{
    return ([self entersCheckerIfOnBarWithMove:move] &&
            [self allCheckersInHomeBoardIfBearingOffWithMove:move] &&
            [self bearsOffFromHighestPointIfBearingOffWithMove:move] &&
            [self isPointOpenForMove:move]);
}

#pragma mark - Query

- (NSArray *)checkersAtPointIndex:(NSInteger)index forColor:(CheckerColor)color
{
    return [self.checkers bk_select:^BOOL(Checker *checker) {
        return index == checker.index && checker.color == color;
    }];
}

- (NSArray *)checkersWithPipsToBearOffLargerThan:(NSInteger)pips forColor:(CheckerColor)color
{
    return [self.checkers bk_select:^BOOL(Checker *checker) {
        return checker.color == color && checker.pipsToBearOff > pips;
    }];
}

#pragma mark - Convenience

- (NSArray *)checkersOnBarForColor:(CheckerColor)color
{
    return [self checkersAtPointIndex:kBarIndex forColor:color];
}

- (NSArray *)checkersBearedOffForColor:(CheckerColor)color
{
    return [self checkersAtPointIndex:kBearedOffIndex forColor:color];
}

- (NSArray *)checkersBeforeHomeBoardForColor:(CheckerColor)color
{
    return [self checkersWithPipsToBearOffLargerThan:6 forColor:color];
}

- (NSArray *)checkersOnBoardForColor:(CheckerColor)color
{
    return [self checkersWithPipsToBearOffLargerThan:kBearedOffIndex forColor:color];
}

#pragma mark - Move Legality

- (BOOL)entersCheckerIfOnBarWithMove:(Move *)move
{
    NSArray *checkersOnBar = [self checkersOnBarForColor:move.checker.color];
    return move.checker.index == kBarIndex || checkersOnBar.count == 0;
}

- (BOOL)allCheckersInHomeBoardIfBearingOffWithMove:(Move *)move
{
    NSArray *checkersBeforeHome = [self checkersBeforeHomeBoardForColor:move.checker.color];
    return move.pips < move.checker.pipsToBearOff || checkersBeforeHome.count == 0;
}

- (BOOL)bearsOffFromHighestPointIfBearingOffWithMove:(Move *)move
{
    NSArray *checkersBeforePoint = [self checkersWithPipsToBearOffLargerThan:move.pips
                                                                    forColor:move.checker.color];
    return move.pips <= move.checker.pipsToBearOff || checkersBeforePoint.count == 0;
}

- (BOOL)isPointOpenForMove:(Move *)move
{
    if (move.indexAfterMove == kBearedOffIndex) {
        return YES;
    }
    CheckerColor opponentColor;

    switch (move.checker.color) {
        case CheckerColorRed:
            opponentColor = CheckerColorBlack;
            break;
        case CheckerColorBlack:
            opponentColor = CheckerColorRed;
            break;
    }
    NSArray *checkersAtTarget = [self checkersAtPointIndex:move.indexAfterMove
                                                  forColor:opponentColor];
    return  checkersAtTarget.count < 2;
}

@end
