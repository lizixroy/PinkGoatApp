//
//  PGJointTableViewCell.h
//  PinkGoatApp
//
//  Created by Roy Li on 12/31/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGJointTableViewCell : NSTableCellView

@property (weak) IBOutlet NSTextField *jointNameLabel;
@property (weak) IBOutlet NSView *colorView;
@property (weak) IBOutlet NSSlider *slider;
@property (weak) IBOutlet NSTextField *desiredJointAngleTextField;


@end

NS_ASSUME_NONNULL_END
