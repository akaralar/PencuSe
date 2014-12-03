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

@interface Game ()

- (NSInteger)rollDie;
- (NSArray *)checkersAtPointIndex:(NSInteger)index;

@end

@implementation Game

#pragma mark - Public

- (void)newGame
{

}

- (void)roll
{
    NSInteger die1 = [self rollDie];
    NSInteger die2 = [self rollDie];

    if (die1 == die2)   _dice = @[@(die1), @(die1), @(die1), @(die1)];
    else                _dice = @[@(die1), @(die2)];

    
}

- (void)makeMove:(Move *)move
{

}

- (BOOL)isLegal:(Move *)move
{

    return YES;
}

#pragma mark - Private

- (NSInteger)rollDie
{
    return (NSInteger)(arc4random_uniform(6) + 1);
}

- (NSArray *)checkersAtPointIndex:(NSInteger)index
{
    return [self.checkers bk_select:^BOOL(Checker *checker) {
        return index == checker.index;
    }];
}



@end
