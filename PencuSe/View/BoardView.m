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
#import "BarView.h"
#import "HomeView.h"

// A point is the slot a checker can move to
static const NSInteger kNumberOfPoints = 24;

// 12 points plus middle bar and side paddings equal to 2 point widths in total
static const CGFloat kPointWidthToTotalWidthRatio = 1 / 15.0;

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

@property (nonatomic) BarView *bar;
@property (nonatomic) HomeView *home;

@property (nonatomic) NSMutableArray *redCheckersOnBar;
@property (nonatomic) NSMutableArray *blackCheckersOnBar;
@property (nonatomic) NSMutableArray *redCheckersBearedOff;
@property (nonatomic) NSMutableArray *blackCheckersBearedOff;

- (PointView *)pointViewAtIndex:(NSInteger)index;
- (void)willHighlightIndex:(NSInteger)index;

- (void)hitBlot:(CheckerView *)checker;
- (void)bearOffChecker:(CheckerView *)checker;

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

        PointDirection d = i / (kNumberOfPoints / 2.0) < 1 ? PointDirectionUp : PointDirectionDown;
        PointColor c = (i % 2 == 0) ? PointColorRed : PointColorWhite;
        PointView *pointView = [[PointView alloc]
                                initWithPointDirection:d
                                pointColor:c
                                pointIndex:i + 1];
        [points addObject:pointView];
        [self addSubview:pointView];


        CGFloat leftPaddingMultiplier = kPointWidthToTotalWidthRatio;
        CGFloat leftEdgeMultiplier;
        if (i < kNumberOfPoints / 2) {

            leftEdgeMultiplier = leftPaddingMultiplier + (i * kPointWidthToTotalWidthRatio);
        }
        else {
            leftEdgeMultiplier = leftPaddingMultiplier + ((kNumberOfPoints - i - 1) * kPointWidthToTotalWidthRatio);
        }

        if (i >= kNumberOfPoints / 4 &&
            i < kNumberOfPoints - (kNumberOfPoints / 4)) {

            leftEdgeMultiplier += leftPaddingMultiplier;
        }

        CGFloat topPaddingMultiplier = (1 - 2 * kPointHeightToTotalHeightRatio) / 2.0;
        CGFloat topEdgeMultiplier = topPaddingMultiplier + i / (kNumberOfPoints / 2) * kPointHeightToTotalHeightRatio;

        [pointView mas_makeConstraints:^(MASConstraintMaker *make) {

            make.right.equalTo(self.mas_right).multipliedBy(1 - leftEdgeMultiplier);
            make.bottom.equalTo(self.mas_bottom).multipliedBy(1 - topEdgeMultiplier);
            make.width.equalTo(self.mas_width).multipliedBy(kPointWidthToTotalWidthRatio);
            make.height.equalTo(self.mas_height).multipliedBy(kPointHeightToTotalHeightRatio);
        }];

        // put index labels above or below points
        UILabel *indexLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        indexLabel.textColor = [UIColor whiteColor];
        indexLabel.text = @(pointView.index).stringValue;

        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {

            indexLabel.font = [UIFont boldSystemFontOfSize:10];
        }
        else {

            indexLabel.font = [UIFont boldSystemFontOfSize:14];
        }

        [self addSubview:indexLabel];

        [indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {

            make.centerX.equalTo(pointView);

            if (i + 1 > (kNumberOfPoints / 2)) {

                make.bottom.equalTo(pointView.mas_top).with.offset(-2);
            }
            else {
                make.top.equalTo(pointView.mas_bottom).with.offset(2);
            }
        }];
    }

    _pointViews = [NSArray arrayWithArray:points];
    _checkerViews = [NSArray array];

    _bar = [[BarView alloc] initWithFrame:CGRectZero];
//    _bar.backgroundColor = [UIColor yellowColor];
    [self addSubview:_bar];

    [_bar mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.bottom.equalTo(self);
        make.left.equalTo([self pointViewAtIndex:7].mas_right);
        make.right.equalTo([self pointViewAtIndex:6].mas_left);
    }];

    _home = [[HomeView alloc] initWithFrame:CGRectZero];
//    _home.backgroundColor = [UIColor blueColor];
    [self addSubview:_home];

    [_home mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self);
        make.left.equalTo([self pointViewAtIndex:1].mas_right);

    }];

    _redCheckersOnBar = [NSMutableArray array];
    _blackCheckersOnBar = [NSMutableArray array];
    _redCheckersBearedOff = [NSMutableArray array];
    _blackCheckersBearedOff = [NSMutableArray array];

    return self;
}

#pragma mark - Highlighting

- (void)willHighlightIndex:(NSInteger)index
{
    [[self.pointViews bk_reject:^BOOL(PointView *pointView) {

        return pointView.index == index || pointView.hightlightColor == PointHighlightColorSelected;

    }] bk_each:^(PointView *pointView) {

        pointView.hightlightColor = PointHighlightColorNone;
    }];

    if (index != kBearedOffIndex) {

        self.home.hightlightColor = PointHighlightColorNone;
    }
}

- (void)highlightIndex:(NSInteger)index withColor:(PointHighlightColor)highlightColor
{
    BoardSlotView *slotView;
    if (index > kBearedOffIndex && index < kBarIndex) {
        slotView = [self pointViewAtIndex:index];
    }
    else if (index == kBarIndex) {

        slotView = self.bar;
    }
    else {

        slotView = self.home;
    }

    if (slotView.hightlightColor == PointHighlightColorSelected) {
        [self willHighlightIndex:index];
        return;
    }
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

    slotView.hightlightColor = highlightColor;
}

- (void)unhighlightAll
{
    [self.pointViews bk_each:^(PointView *pointView) {

        pointView.hightlightColor = PointHighlightColorNone;
    }];

    self.bar.hightlightColor = PointHighlightColorNone;
    self.home.hightlightColor = PointHighlightColorNone;
}

#pragma mark - Convenience

- (NSInteger)pointViewIndexForTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    PointView *pointView = [self.pointViews bk_match:^BOOL(PointView *point) {

        return [point pointInside:[touch locationInView:point]
                        withEvent:event];
    }];

    if (pointView) {
        return pointView.index;
    }

    if (!self.selectedCheckerView) {

        if ([self.bar pointInside:[touch locationInView:self.bar]
                        withEvent:event]) {

            return kBarIndex;
        }
    }
    else {

        if ([self.home pointInside:[touch locationInView:self.home]
                         withEvent:event]) {

            return kBearedOffIndex;
        }

        // if the touch is not inside any point, find the closest point
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

                         // if pointviews are same, select another pointview to compare distances
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

        return pointView.index;
    }


    return pointView.index;
}

- (PointView *)pointViewAtIndex:(NSInteger)index
{
    NSParameterAssert(index > 0 && index < 25);

    return [self.pointViews bk_match:^BOOL(PointView *pointView) {
        return pointView.index == index;
    }];
}

- (void)selectTopCheckerForTouch:(UITouch *)touch
                       withEvent:(UIEvent *)event
                        forColor:(CheckerColor)color
{
    NSInteger index = [self pointViewIndexForTouch:touch withEvent:event];
    self.selectedCheckerView = [self topCheckerAtIndex:index forColor:color];

    CGPoint touchPoint = [touch locationInView:self];

    if (self.selectedCheckerView) {

        [self addSubview:self.selectedCheckerView];

        if (index > kBearedOffIndex && index < kBarIndex) {
            PointView *pointView = [self pointViewAtIndex:index];
            [pointView removeCheckerView:self.selectedCheckerView];
        }
        else if (index == kBarIndex) {
            switch (color) {
                case CheckerColorRed:
                    [self.redCheckersOnBar removeObject:self.selectedCheckerView];
                case CheckerColorBlack:
                    [self.blackCheckersOnBar removeObject:self.selectedCheckerView];
            }
        }

        self.selectedCheckerView.transform = CGAffineTransformMakeScale(1.5, 1.5);
        [self.selectedCheckerView.superview layoutIfNeeded];
        self.selectedCheckerView.center = touchPoint;
        _selectedCheckerIndex = index;
    }
}

- (CheckerView *)topCheckerAtIndex:(NSInteger)index forColor:(CheckerColor)color
{
    if (index > kBearedOffIndex && index < kBarIndex) {
        CheckerView *checker = [[self pointViewAtIndex:index] topCheckerView];

        return checker.color == color ? checker : nil;
    }
    else if (index == kBarIndex) {

        switch (color) {
            case CheckerColorRed:
                return [self.redCheckersOnBar lastObject];
            case CheckerColorBlack:
                return [self.blackCheckersOnBar lastObject];
        }
    }
    else {

        switch (color) {
            case CheckerColorRed:
                return [self.redCheckersBearedOff lastObject];
            case CheckerColorBlack:
                return [self.blackCheckersBearedOff lastObject];
        }
    }
}

- (void)deselectChecker
{
    self.selectedCheckerView.transform = CGAffineTransformIdentity;
    
    self.selectedCheckerView = nil;
    _selectedCheckerIndex = -1;
}

- (void)createCheckerWithColor:(CheckerColor)color atIndex:(NSInteger)index
{
    NSMutableArray *checkers = [self.checkerViews mutableCopy];

    CheckerView *checker = [[CheckerView alloc] initWithFrame:CGRectZero];
    checker.color = color;
    checker.index = index;
    [checkers addObject:checker];
    [self addSubview:checker];
    [self placeChecker:checker atIndex:index animated:NO];

    self.checkerViews = [NSArray arrayWithArray:checkers];
}

- (void)placeChecker:(CheckerView *)checker atIndex:(NSInteger)index animated:(BOOL)animated
{
    if (checker == self.selectedCheckerView) {

        [self deselectChecker];
    }

    if (index == kBarIndex) {

        [self hitBlot:checker];
    }
    else if (index == kBearedOffIndex) {

        [self bearOffChecker:checker];
    }
    else {

        if (checker.index == kBarIndex) {
            checker.countLabel.text = @"";
        }

        PointView *pointView = [self pointViewAtIndex:index];
        [pointView insertCheckerView:checker animated:animated];
    }

    [self unhighlightAll];
}

- (void)hitBlot:(CheckerView *)checker
{
    if (checker.index != kBarIndex) {
        PointView *pointView = [self pointViewAtIndex:checker.index];
        [pointView removeCheckerView:checker];
    }

    NSMutableArray *arrayToAdd = (checker.color == CheckerColorRed ?
                                  self.redCheckersOnBar :
                                  self.blackCheckersOnBar);

    if (arrayToAdd.count == 0) {

        [checker mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);

            if (checker.color == CheckerColorRed) {

                make.bottom.equalTo(self.mas_centerY);
            }
            else {

                make.top.equalTo(self.mas_centerY);
            }

            make.width.and.height.equalTo(self.mas_height).multipliedBy((1/5.5) * kPointHeightToTotalHeightRatio);
        }];
    }
    else {

        // make sure checker is on top
        [self bringSubviewToFront:checker];

        CheckerView *checkerOnBar = [arrayToAdd firstObject];

        [checker mas_remakeConstraints:^(MASConstraintMaker *make) {

            make.center.equalTo(checkerOnBar);

            make.width.and.height.equalTo(self.mas_height).multipliedBy((1/5.5) * kPointHeightToTotalHeightRatio);
        }];

        checker.countLabel.text = [@([arrayToAdd count] + 1) stringValue];

    }

    [UIView animateWithDuration:0.2
                     animations:^{
                         [checker layoutIfNeeded];
                     }];


    checker.index = kBarIndex;
    [arrayToAdd addObject:checker];
}

- (void)bearOffChecker:(CheckerView *)checker
{
    PointView *pointView = [self pointViewAtIndex:checker.index];
    [pointView removeCheckerView:checker];

    NSMutableArray *arrayToAdd = (checker.color == CheckerColorRed ?
                                  self.redCheckersBearedOff :
                                  self.blackCheckersBearedOff);

    if (arrayToAdd.count == 0) {

        [checker mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.home);

            if (checker.color == CheckerColorRed) {

                make.bottom.equalTo(self.home);
            }
            else {

                make.top.equalTo(self.home);
            }

            make.width.and.height.equalTo(self.mas_height).multipliedBy((1/5.5) * kPointHeightToTotalHeightRatio);
        }];
    }
    else {

        // make sure checker is on top
        [self bringSubviewToFront:checker];

        CheckerView *checkerHome = [arrayToAdd firstObject];

        [checker mas_remakeConstraints:^(MASConstraintMaker *make) {

            make.center.equalTo(checkerHome);

            make.width.and.height.equalTo(self.mas_height).multipliedBy((1/5.5) * kPointHeightToTotalHeightRatio);
        }];

        checker.countLabel.text = [@([arrayToAdd count] + 1) stringValue];

    }

    [UIView animateWithDuration:0.2
                     animations:^{
                         [checker layoutIfNeeded];
                     }];
    
    
    checker.index = kBearedOffIndex;
    [arrayToAdd addObject:checker];

}


@end
