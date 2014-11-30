//
//  CheckerView.m
//  PencuSe
//
//  Created by Ahmet Karalar on 29/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "CheckerView.h"

@interface CheckerView ()

@end

@implementation CheckerView

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (!self) {
        return nil;
    }

    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 2;
    self.layer.delegate = self;
    return self;
}

#pragma mark - Accessors

- (void)setColor:(CheckerColor)color
{
    _color = color;

    self.layer.backgroundColor = [UIColor colorForCheckerColor:color].CGColor;
}

#pragma mark - CALayerDelegate

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    self.layer.cornerRadius = self.bounds.size.width / 2;
}

@end
