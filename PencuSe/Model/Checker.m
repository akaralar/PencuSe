//
//  Checker.m
//  PencuSe
//
//  Created by Ahmet Karalar on 3/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "Checker.h"

const NSInteger kBarIndex = 25;
const NSInteger kBearedOffIndex = 0;

@implementation Checker

- (NSInteger)pipsToBearOff
{
    NSInteger pips;

    switch (self.index) {
        case kBarIndex:
        case kBearedOffIndex:
            pips = self.index;
            break;

        default:
            switch (self.color) {
                case CheckerColorRed:
                    pips = self.index;
                    break;
                case CheckerColorBlack:
                    pips = 25 - self.index;
                    break;
            }
            break;
    }

    return pips;
}
@end
