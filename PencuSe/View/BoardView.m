//
//  BoardView.m
//  PencuSe
//
//  Created by Ahmet Karalar on 29/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "BoardView.h"
#import "PointView.h"
#import "Masonry.h"
#import "CheckerView.h"
#import <BlocksKit/BlocksKit.h>

// A point is the slot a checker can move to
static const NSInteger kNumberOfPoints = 24;

// 12 points plus middle bar and side paddings equal to 2 point widths in total
static const CGFloat kPointWidthToTotalWidthRatio = 1 / 14.0;

// 0.1 of total height is board padding (0.05 on top and bottom each)
// there are 2 rows of points, (1 - 0.1) / 2 = 0.45
static const CGFloat kPointHeightToTotalHeightRatio = 0.45;

// Function to calculate distance between two points
static CGFloat DistanceBetweenPoints(CGPoint p1, CGPoint p2) {

    CGFloat xDist = p1.x - p2.x;
    CGFloat yDist = p1.y - p2.y;

    return sqrt(xDist * xDist + yDist * yDist);
}


@interface BoardView ()

@property (nonatomic, readwrite) NSArray *pointViews;
@property (nonatomic, readwrite) NSArray *checkerViews;
@property (nonatomic, readwrite) CheckerView *selectedCheckerView;

- (PointView *)pointViewAtIndex:(NSInteger)index;
- (void)willHighlightIndex:(NSInteger)index;

@end

@implementation BoardView

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

    self.backgroundColor = [UIColor boardWoodColor];

    NSMutableArray *points = [NSMutableArray array];

    // place the points
    for (NSInteger i = 0; i < kNumberOfPoints; ++i) {

        PointView *pointView = [[PointView alloc] initWithFrame:CGRectZero];
        pointView.pointColor = (i % 2 == 0) ? PointColorRed : PointColorWhite;
        pointView.pointDirection = i / (kNumberOfPoints / 2.0) < 1 ? PointDirectionDown : PointDirectionUp;
        pointView.pointIndex = i + 1;
        [points addObject:pointView];
        [self addSubview:pointView];


        CGFloat leftPaddingMultiplier = kPointWidthToTotalWidthRatio / 2;
        CGFloat leftEdgeMultiplier;
        if (i < kNumberOfPoints / 2) {

            leftEdgeMultiplier = leftPaddingMultiplier + (i * kPointWidthToTotalWidthRatio);
        }
        else {
            leftEdgeMultiplier = leftPaddingMultiplier + ((kNumberOfPoints - i - 1) * kPointWidthToTotalWidthRatio);
        }

        if (i >= kNumberOfPoints / 4 &&
            i < kNumberOfPoints - (kNumberOfPoints / 4)) {

            leftEdgeMultiplier += 2 * leftPaddingMultiplier;
        }

        CGFloat topPaddingMultiplier = (1 - 2 * kPointHeightToTotalHeightRatio) / 2.0;
        CGFloat topEdgeMultiplier = topPaddingMultiplier + i / (kNumberOfPoints / 2) * kPointHeightToTotalHeightRatio;

        [pointView mas_makeConstraints:^(MASConstraintMaker *make) {

            make.left.equalTo(self.mas_right).multipliedBy(leftEdgeMultiplier);
            make.top.equalTo(self.mas_bottom).multipliedBy(topEdgeMultiplier);
            make.width.equalTo(self.mas_width).multipliedBy(kPointWidthToTotalWidthRatio);
            make.height.equalTo(self.mas_height).multipliedBy(kPointHeightToTotalHeightRatio);
        }];

        // put index labels above or below points
        UILabel *indexLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        indexLabel.textColor = [UIColor whiteColor];
        indexLabel.text = @(pointView.pointIndex).stringValue;

        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {

            indexLabel.font = [UIFont systemFontOfSize:10];
        }

        [self addSubview:indexLabel];

        [indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {

            make.centerX.equalTo(pointView);

            if (i + 1 > (kNumberOfPoints / 2)) {

                make.top.equalTo(pointView.mas_bottom).with.offset(2);
            }
            else {
                make.bottom.equalTo(pointView.mas_top).with.offset(-2);
            }
        }];
    }

    _pointViews = [NSArray arrayWithArray:points];


    NSMutableArray *checkers = [NSMutableArray array];

    CheckerView *checker = [[CheckerView alloc] initWithFrame:CGRectZero];

    checker.color = CheckerColorRed;

    [self addSubview:checker];
    [checkers addObject:checker];

    [checker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(self.mas_width).multipliedBy(kPointWidthToTotalWidthRatio);
        make.center.equalTo([self pointViewAtIndex:1]);
    }];

    _checkerViews = [NSArray arrayWithArray:checkers];


//    for (NSInteger i = 0; i < 30; ++i) {
//
//        CheckerView *view = [[CheckerView alloc] initWithFrame:CGRectZero];
//
//        view.color = CheckerColorRed : CheckerColorBlack;
//
//        [self addSubview:view];
//
//        [_checkers addObject:view];
//
//    }

    
    return self;
}

#pragma mark - Highlighting

- (void)willHighlightIndex:(NSInteger)index
{
    [[self.pointViews bk_reject:^BOOL(PointView *pointView) {

        return pointView.pointIndex == index || pointView.hightlightColor == PointHighlightColorSelected;

    }] bk_each:^(PointView *pointView) {

        pointView.hightlightColor = PointHighlightColorNone;
    }];
}

- (void)highlightIndex:(NSInteger)index withColor:(PointHighlightColor)highlightColor
{

    // TODO: Handle selection color change bug here
    switch (highlightColor) {
        case PointHighlightColorNone:

            break;
        case PointHighlightColorSelected:
            [self unhighlightAll];
            break;
        case PointHighlightColorAllowed:
        case PointHighlightColorForbidden:
            [self willHighlightIndex:index];
            break;
    }

    [self pointViewAtIndex:index].hightlightColor = highlightColor;
}

- (void)unhighlightAll
{
    [self.pointViews bk_each:^(PointView *pointView) {

        pointView.hightlightColor = PointHighlightColorNone;
    }];
}

#pragma mark - Convenience

- (NSInteger)pointViewIndexForTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    PointView *pointView = [self.pointViews bk_match:^BOOL(PointView *point) {

        return [point pointInside:[touch locationInView:point]
                        withEvent:event];
    }];

    // if the touch is not inside any point, find the closest point
    if (!pointView) {

        // we start with all pointviews and reduce one by one to the closest pointview
        pointView = [self.pointViews
                     bk_reduce:[self.pointViews mutableCopy]
                     withBlock:^id(NSMutableArray *remaining, PointView *point) {

                         // pick the first pointview of remaining pointviews for comparison
                         PointView *other = [remaining firstObject];

                         // if only one object is remaining, it's the closest one
                         if (remaining.count == 1) {
                             return other;
                         }

                         // if pointviews are same, select another object to compare
                         if (other == point) {
                             other = [remaining lastObject];
                         }

                         CGPoint p1 = [touch locationInView:self];
                         CGPoint p2 = point.center;
                         CGFloat pointDistance = DistanceBetweenPoints(p1, p2);

                         p2 = other.center;
                         CGFloat otherDistance = DistanceBetweenPoints(p1, p2);

                         // remove the farther pointview from remaining pointviews
                         if (pointDistance > otherDistance) {

                             [remaining removeObject:point];
                         }
                         else {
                             [remaining removeObject:other];
                         }
                         
                         return remaining;
                     }];
    }

    return pointView.pointIndex;
}

- (PointView *)pointViewAtIndex:(NSInteger)index
{
    NSParameterAssert(index > 0 && index < 25);

    return [self.pointViews bk_match:^BOOL(PointView *pointView) {
        return pointView.pointIndex == index;
    }];
}

- (void)selectTopCheckerAtIndex:(NSInteger)index
{
    self.selectedCheckerView = [[self.checkerViews bk_select:^BOOL(CheckerView *checkerView) {

        PointView *pointView = [self pointViewAtIndex:index];

        CGPoint checkerCenter = [pointView convertPoint:checkerView.center
                                               fromView:self];

        return [pointView pointInside:checkerCenter withEvent:nil];
    }] lastObject];
}

- (void)deselectChecker
{
    self.selectedCheckerView = nil;
}

- (void)placeChecker:(CheckerView *)checker atIndex:(NSInteger)index animated:(BOOL)animated
{
    PointView *pointView = [self pointViewAtIndex:index];

    [checker mas_remakeConstraints:^(MASConstraintMaker *make) {

        make.width.and.height.equalTo(self.mas_width).multipliedBy(kPointWidthToTotalWidthRatio);
        make.center.equalTo(pointView);
    }];

    if (animated) {

        [UIView animateWithDuration:0.2 animations:^{
            [self layoutIfNeeded];
        }];
    }
    else {
        [self layoutIfNeeded];
    }
}

@end
