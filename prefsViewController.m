//
//  prefsViewController.m
//  overbank
//
//  Created by Jesus Renero on 17/11/13.
//
//

#import "prefsViewController.h"
#import "MASPreferencesWindowController.h"

@implementation prefsViewController
@synthesize _prefsObjectReference, tableView;

- (id)init
{
    return [super initWithNibName:@"prefsViewController" bundle:nil];
}

- (id) initWithPrefsReference:(Prefs *)prefsReference
{
    self = [super initWithNibName:@"prefsViewController" bundle:nil];
	if (self != nil) {
		self._prefsObjectReference = prefsReference;
	}
	return self;
}

/**
 Dynamically obtain the reference to the "Prefs" object by accessing the 
 object View->Window->Delegate, which is a MASPreferencesWindowController
 and then, from there, getting the "_selectedViewController" to get actual
 pointer to the "Prefs".
 I couldn't make it programatically as I'm extending NSViewController and
 when I set the pointer to prefs in AppDelegate, it get lost when accessing
 this code.
 */
- (void) setPrefsObjectReference
{
    MASPreferencesWindowController *parent;
    parent = (MASPreferencesWindowController *)self.view.window.delegate;
    prefsViewController *ptr = (prefsViewController *)parent.selectedViewController;
    self._prefsObjectReference = ptr._prefsObjectReference;
}

#pragma mark NSTableProtocol methods

- (NSInteger) numberOfRowsInTableView:(NSTableView *)table
{
    if (_prefsObjectReference == nil)
        [self setPrefsObjectReference];
    
    return [_prefsObjectReference numCategories];
}

- (id)tableView:(NSTableView *)table objectValueForTableColumn:(NSTableColumn *)column
            row:(NSInteger)rowIndex
{
    if (_prefsObjectReference == nil)
        [self setPrefsObjectReference];

    // TO-DO: remove the hardwired constant here!
    if ([column.identifier caseInsensitiveCompare:@"category"] == NSOrderedSame)
        return [_prefsObjectReference categoryAtRow:rowIndex];
    else
        return [_prefsObjectReference tagsAtRow:rowIndex];
}


#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameAdvanced];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"General", @"Toolbar item name for the General preference pane");
}


@end
