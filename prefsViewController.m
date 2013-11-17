//
//  prefsViewController.m
//  overbank
//
//  Created by Jesus Renero on 17/11/13.
//
//

#import "prefsViewController.h"

@implementation prefsViewController

- (id)init
{
    return [super initWithNibName:@"prefsViewController" bundle:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"General", @"Toolbar item name for the General preference pane");
}


@end
