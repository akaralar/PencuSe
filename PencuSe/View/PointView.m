//
//  PointView.m
//  PencuSe
//
//  Created by Ahmet Karalar on 29/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "PointView.h"

@interface PointView ()

@property (nonatomic) CALayer *overlayLayer;
@property (nonatomic, readonly) CAShapeLayer *layer;

- (UIBezierPath *)pathForPointDirection:(PointDirection)pointDirection;

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

    self.layer.backgroundColor = [UIColor boardInteriorColor].CGColor;
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

- (void)highlightColor:(PointHighlightColor)highlightColor
{
    self.overlayLayer.opacity = 0.2;
    self.overlayLayer.backgroundColor = [UIColor colorForPointHighlightColor:highlightColor].CGColor;
}

- (void)unhighlight
{
    self.overlayLayer.opacity = 0;
    self.overlayLayer.backgroundColor = [UIColor clearColor].CGColor;
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

- (void)setHightlightColor:(PointHighlightColor)hightlightColor
{
    _hightlightColor = hightlightColor;


    switch (hightlightColor) {
        case PointHighlightColorNone:

            self.overlayLayer.opacity = 0;
            self.overlayLayer.backgroundColor = [UIColor clearColor].CGColor;
            break;

        case PointHighlightColorAllowed:
        case PointHighlightColorForbidden:
        case PointHighlightColorSelected:
            self.overlayLayer.opacity = 0.2;
            self.overlayLayer.backgroundColor = [UIColor
                                                 colorForPointHighlightColor:hightlightColor].CGColor;
            break;
        default:
            break;
    }
}

- (CALayer *)overlayLayer
{
    if (!_overlayLayer) {
        _overlayLayer = [CALayer layer];
        [self.layer addSublayer:_overlayLayer];
        _overlayLayer.frame = self.layer.bounds;
    }

    return _overlayLayer;
}

#pragma mark - CALayerDelegate

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    self.layer.fillColor = [UIColor colorForPointColor:self.pointColor].CGColor;
    self.layer.path = [self pathForPointDirection:self.pointDirection].CGPath;
    self.overlayLayer.frame = self.layer.bounds;
}

@end
