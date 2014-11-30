//
//  PointView.m
//  PencuSe
//
//  Created by Ahmet Karalar on 29/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "PointView.h"

@interface PointView ()

@property (nonatomic, readonly) CAShapeLayer *layer;

- (UIBezierPath *)pathForPointDirection:(PointDirection)pointDirection;
- (UIColor *)colorForPointColor:(PointColor)pointColor;

@end

@implementation PointView

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

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

    self.layer.backgroundColor = [UIColor colorWithRed:0.222
                                                 green:0.212
                                                  blue:0.197
                                                 alpha:1].CGColor;
    self.layer.delegate = self;
    return self;
}

#pragma mark - Convenience

- (UIBezierPath *)pathForPointDirection:(PointDirection)direction
{
    CGPoint vertice1, vertice2, vertice3;

    switch (direction) {

        case PointDirectionUp:

            vertice1 = CGPointMake(0, self.bounds.size.height);
            vertice2 = CGPointMake(self.bounds.size.width / 2, 0);
            vertice3 = CGPointMake(self.bounds.size.width, self.bounds.size.height);

            break;

        case PointDirectionDown:

            vertice1 = CGPointZero;
            vertice2 = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height);
            vertice3 = CGPointMake(self.bounds.size.width, 0);

            break;
    }

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:vertice1];
    [path addLineToPoint:vertice2];
    [path addLineToPoint:vertice3];
    [path closePath];

    return path;
}

- (UIColor *)colorForPointColor:(PointColor)pointColor
{
    UIColor *color;
    switch (pointColor) {
        case PointColorRed:
            color = [UIColor colorWithRed:0.863 green:0.131 blue:0.052 alpha:1];
            break;
        case PointColorWhite:
            color = [UIColor colorWithRed:0.999 green:1 blue:1 alpha:1];
            break;
    }

    return color;
}

#pragma mark - Accessors

- (void)setPointDirection:(PointDirection)pointDirection
{
    _pointDirection = pointDirection;
}

- (void)setPointColor:(PointColor)pointColor
{
    _pointColor = pointColor;
}

#pragma mark - CALayerDelegate

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    self.layer.fillColor = [self colorForPointColor:self.pointColor].CGColor;
    self.layer.path = [self pathForPointDirection:self.pointDirection].CGPath;
}

@end
