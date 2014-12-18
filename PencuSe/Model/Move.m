//
//  Move.m
//  PencuSe
//
//  Created by Ahmet Karalar on 3/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "Move.h"
#import "Checker.h"

@implementation Move

- (instancetype)initWithChecker:(Checker *)checker pips:(NSInteger)pips
{
    self = [super init];

    if (!self) {
        return nil;
    }

    _checker = checker;
    _pips = pips;

    return self;
}

- (NSInteger)indexAfterMove
{
    NSInteger index;

    switch (self.checker.color) {
        case CheckerColorRed:

            if (self.checker.index == kBarIndex) {

                index = 25 - self.pips;
            }
            else if (self.checker.pipsToBearOff > self.pips) {

                index = self.checker.index - self.pips;
            }
            else {

                index = kBearedOffIndex;
            }

            break;

        case CheckerColorBlack:

            if (self.checker.index == kBarIndex) {

                index = 0 + self.pips;
            }
            else if (self.checker.pipsToBearOff > self.pips) {

                index = self.checker.index + self.pips;
            }
            else {

                index = kBearedOffIndex;
            }

            break;
    }

    return index;
}

@end
