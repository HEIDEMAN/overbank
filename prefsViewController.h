//
//  prefsViewController.h
//  overbank
//
//  Created by Jesus Renero on 17/11/13.
//
//

#import "MASPreferencesViewController.h"
#import "Prefs.h"

@interface prefsViewController : NSViewController <MASPreferencesViewController, NSTableViewDataSource, NSWindowDelegate>
{
    // This is a reference to the "Prefs" object.
    // I obtain it dynamically, by getting the MASPreferencesViewController
    // reference from this object window->delegate, and the accessing the
    // private property "_selectedViewController" within it.
    // Check it out at "setPrefsObjectReference".
    Prefs *_prefsObjectReference;
    
    IBOutlet NSButtonCell *restoreDefaultsButtonOutlet;
}

@property (retain) Prefs *_prefsObjectReference;
@property (retain) IBOutlet NSTableView *tableView;

@property (strong, nonatomic) IBOutlet NSButtonCell *restoreDefaultsButtonOutlet;

- (id) initWithPrefsReference:(Prefs *)prefsReference;
- (void) setPrefsObjectReference;

// Methods to comply with NSTableProtocol
- (NSInteger) numberOfRowsInTableView:(NSTableView *)table;
- (id)tableView:(NSTableView *)table objectValueForTableColumn:(NSTableColumn *)column
            row:(NSInteger)rowIndex;
- (void)tableView:(NSTableView *)thisTableView setObjectValue:(id)value
   forTableColumn:(NSTableColumn *)column row:(NSInteger)row;


// Methods to comply with MASPreferences Protocol
- (NSString *)identifier;
- (NSImage *)toolbarItemImage;
- (NSString *)toolbarItemLabel;

@end
