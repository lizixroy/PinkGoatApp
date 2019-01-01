//
//  PGTimeSeriesViewController.m
//  PinkGoatApp
//
//  Created by Roy Li on 12/31/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGTimeSeriesViewController.h"
#import "PGTimeSeriesView.h"
#import "PGJointTableViewCell.h"

@interface PGTimeSeriesViewController ()

@property (weak) IBOutlet PGTimeSeriesView *timeSeriesView;
@property (weak) IBOutlet NSTableView *variablesTableView;
@property (nonatomic, assign) NSUInteger jointCount;
@property (nonatomic, strong) NSArray<NSColor *> *lineColors;

@end

@implementation PGTimeSeriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.variablesTableView.delegate = self;
    self.variablesTableView.dataSource = self;
    self.variablesTableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
    NSArray *colors = [self makeColorsForNumberOfLines:self.jointCount];
    self.lineColors = colors;
    [self.timeSeriesView setupWithJointCount:self.jointCount lineColors:colors];
    NSNib *nib = [[NSNib alloc] initWithNibNamed:@"PGJointTableViewCell" bundle:[NSBundle mainBundle]];
    [self.variablesTableView registerNib:nib  forIdentifier:@"PGJointTableViewCell"];
}

- (void)setupWithJointCount:(NSUInteger)jointCount
                      robot:(PGRobot *)robot
{
    self.jointCount = jointCount;
    self.robot = robot;
}

- (void)updateWithJointVariables:(NSArray<NSNumber *> *)jointVariables {
    [self.timeSeriesView updateWithJointVariables:jointVariables];
    [self.timeSeriesView setNeedsDisplay:YES];
}

- (NSArray<NSColor *> *)makeColorsForNumberOfLines:(NSUInteger)numerOfLines
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[NSColor colorWithDeviceRed:0.7412 green:0.2118 blue:0.1569 alpha:1.0]]; // red
    [array addObject:[NSColor colorWithDeviceRed:0.8353 green:0.5373 blue:0.2353 alpha:1.0]]; // orange
    [array addObject:[NSColor colorWithDeviceRed:0.9529 green:1.0000 blue:0.3686 alpha:1.0]]; // yellow
    [array addObject:[NSColor colorWithDeviceRed:0.6275 green:0.9059 blue:0.6784 alpha:1.0]]; // green
    [array addObject:[NSColor colorWithDeviceRed:0.3412 green:0.5725 blue:0.8706 alpha:1.0]]; // blue
    [array addObject:[NSColor colorWithDeviceRed:0.3725 green:0.0824 blue:0.8980 alpha:1.0]]; // indigo
    [array addObject:[NSColor colorWithDeviceRed:0.4706 green:0.1804 blue:0.9020 alpha:1.0]]; // purple
    // Generate random colors for the remaining.
    
    if (numerOfLines > array.count) {
        NSUInteger n = numerOfLines - array.count;
        for (int i = 0; i < n; i++) {
            [array addObject:[self generateRandomColor]];
        }
    }
    return [NSArray arrayWithArray:array];
}

- (NSColor *)generateRandomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    NSColor *color = [NSColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}

#pragma mark - NSTableViewDelegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.jointCount;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    PGJointTableViewCell *cell = [tableView makeViewWithIdentifier:@"PGJointTableViewCell" owner:self];
    // TODO: joint name should come from URDF.
    NSString *jointName = [NSString stringWithFormat:@"Joint %ld", (long)row];
    cell.jointNameLabel.stringValue = jointName;
    cell.colorView.wantsLayer = YES;
    cell.colorView.layer.backgroundColor = self.lineColors[row].CGColor;
    cell.slider.minValue = -M_PI;
    cell.slider.maxValue = M_PI;
    cell.slider.floatValue = self.robot.desiredJointVariables[row].floatValue;
    __weak PGTimeSeriesViewController *weakSelf = self;
    cell.sliderDidChangeValue = ^(float value) {
        weakSelf.robot.desiredJointVariables[row] = [NSNumber numberWithFloat:value];
    };
    return cell;
}

@end
