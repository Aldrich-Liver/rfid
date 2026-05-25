//
//  MultiTagTableViewCell.m
//  RFIDDemoApp
//
//  Created by Symbol on 23/09/21.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "MultiTagTableViewCell.h"
#import "ui_config.h"
#import "config.h"
#import "UIColor+DarkModeExtension.h"
@implementation MultiTagTableViewCell


/// Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [[progressView layer] setCornerRadius:ZT_UI_LOCATE_MULTITAG_INDICATOR_CORNER_RADIUS];
    [[progressBackgroundView layer] setCornerRadius:ZT_UI_LOCATE_MULTITAG_INDICATOR_CORNER_RADIUS];
}


/// Initializes a table cell with a style and a reuse identifier and returns it to the caller.
/// @param style A constant indicating a cell style.
/// @param reuseIdentifier A string used to identify the cell object if it is to be reused for drawing multiple rows of a table view.
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self darkModeCheck:self.traitCollection];
    if (self)
    {
        // Initialization code
    }
    return self;
}


/// Set tag id
/// @param tagId The tag id
- (void)setTagId:(NSString*)tagId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [tagIdLabel setText:tagId];
    });

}


/// Set precetage value in to label
/// @param precentage The precentage value
- (void)setPrecentage:(NSString*)precentage
{
    [distanceLabel setText:precentage];
    float progressValue = ((float)([precentage floatValue]))/((float) 100);
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressBar setProgress:progressValue animated:true];
    });

}


/// Set tag seen count
/// @param tagSeenCount The tag seen count
- (void)setTagSeenCount:(NSString*)tagSeenCount
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [tagCountLabel setText:tagSeenCount];
    });
 
}

/// Get tag id
- (NSString*)getTagId
{
    return tagIdLabel.text;
}

/// Deallocates the memory occupied by the receiver.
- (void)dealloc
{
    if (nil != tagIdLabel)
    {
        [tagIdLabel release];
    }
    if (nil != tagCountLabel)
    {
        [tagCountLabel release];
    }
    if (nil != distanceLabel)
    {
        [distanceLabel release];
    }
    if (nil != progressBackgroundView)
    {
        [progressBackgroundView release];
    }
    if (nil != progressView)
    {
        [progressView release];
    }
    [super dealloc];
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    distanceLabel.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    tagCountLabel.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}
/// Set tag id for ASCII mode
/// @param tagId The tag id
- (void)setTagIdForASCIIMode:(NSString*)tagId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [tagIdLabel setText:tagId];
        [self setTagDataTextColorForASCIIMode];
    });

}
/// Color empty spaces in tag data for ASCII mode
-(void) setTagDataTextColorForASCIIMode
{
    int tagDataTextIndex = 0;
    if(tagIdLabel.text != nil && tagIdLabel.text.length >0 ){
        while (tagDataTextIndex<(tagIdLabel.text.length-ZT_TAG_DATA_EMPTY_SPACE.length)) {
            
            NSRange tagDataTextRange = NSMakeRange(tagDataTextIndex, ZT_TAG_DATA_EMPTY_SPACE.length);
                if ([[tagIdLabel.text substringWithRange:tagDataTextRange] isEqualToString:ZT_TAG_DATA_EMPTY_SPACE]) {
                    
                    NSMutableAttributedString *tempAttributeText = [[NSMutableAttributedString alloc] initWithAttributedString:tagIdLabel.attributedText];
                    [tempAttributeText addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:tagDataTextRange];
                    tagIdLabel.attributedText = tempAttributeText;
                    tagDataTextIndex += ZT_TAG_DATA_EMPTY_SPACE.length;
                } else
                {
                    tagDataTextIndex++;
                }
        }
    }
}
@end
