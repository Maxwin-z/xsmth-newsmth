//////////////
// Settings //
//////////////

// UIColor
#define kDCIntrospectFlashOnRedrawColor [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.4f]
// NSTimeInterval
#define kDCIntrospectFlashOnRedrawFlashLength 0.03f
// UIColor
#define kDCIntrospectOpaqueColor [UIColor redColor]
// Seconds
#define kDCIntrospectTemporaryDisableDuration 10. 
//////////////////
// Key Bindings //
//////////////////

// '' is equivalent to page up (copy and paste this character to use)
// '' is equivalent to page down (copy and paste this character to use)

// Global //
// starts introspector
#define kDCIntrospectKeysInvoke	@" "
// shows outlines for all views
#define kDCIntrospectKeysToggleViewOutlines	@"o"
// changes all non-opaque view background colours to red (destructive)
#define kDCIntrospectKeysToggleNonOpaqueViews	@"O"
// shows help
#define kDCIntrospectKeysToggleHelp	@"?"
// toggle flashing on redraw for all views that implement [[DCIntrospect sharedIntrospector] flashRect:inView:] in drawRect:
#define kDCIntrospectKeysToggleFlashViewRedraws	@"f"
// toggles the coordinates display
#define kDCIntrospectKeysToggleShowCoordinates @"c"
// enters block action mode
#define kDCIntrospectKeysEnterBlockMode	@"b"

// When introspector is invoked and a view is selected //

// nudges the selected view in given direction
#define kDCIntrospectKeysNudgeViewLeft      @"4"
#define kDCIntrospectKeysNudgeViewRight     @"6"
#define kDCIntrospectKeysNudgeViewUp        @"8"
#define kDCIntrospectKeysNudgeViewDown			@"2"
// centers the selected view in it's superview
#define kDCIntrospectKeysCenterInSuperview	@"5"
// increases/decreases the width/height of selected view
#define kDCIntrospectKeysIncreaseWidth			@"9"
#define kDCIntrospectKeysDecreaseWidth			@"7"
#define kDCIntrospectKeysIncreaseHeight			@"3"
#define kDCIntrospectKeysDecreaseHeight			@"1"
// prints code to the console of the changes to the current view.  If the view has not been changed nothing will be printed.  For example, if you nudge a view or change it's rect with the nudge keys, this will log '<#view#>.frame = CGRectMake(50.0, ..etc);'.  Or if you set it's name using setName:forObject:accessedWithSelf: it will use the name provided, for example 'myView.frame = CGRectMake(...);'.  Setting accessedWithSelf to YES would output 'self.myView.frame = CGRectMake(...);'.
#define kDCIntrospectKeysLogCodeForCurrentViewChanges	@"0"

// increases/decreases the selected views alpha value
#define kDCIntrospectKeysIncreaseViewAlpha @"+"
#define kDCIntrospectKeysDecreaseViewAlpha @"-"

// calls setNeedsDisplay on selected view
#define kDCIntrospectKeysSetNeedsDisplay @"d"
// calls setNeedsLayout on selected view
#define kDCIntrospectKeysSetNeedsLayout	@"l"
// calls reloadData on selected view if it's a UITableView
#define kDCIntrospectKeysReloadData	@"r"
// logs all properties of the selected view
#define kDCIntrospectKeysLogProperties	@"p"
// logs accessibility info (useful for automated view tests - thanks to @samsoffes for the idea)
#define kDCIntrospectKeysLogAccessibilityProperties	@"a"
// calls private method recursiveDescription which logs selected view heirachy
#define kDCIntrospectKeysLogViewRecursive	@"v"

// changes the selected view to it's superview
#define kDCIntrospectKeysMoveUpInViewHierarchy			@"y"
// changes the selected view back to the previous view selected (after using the above command)
#define kDCIntrospectKeysMoveBackInViewHierarchy		@"t"
#define kDCIntrospectKeysMoveDownToFirstSubview			@"h"
#define kDCIntrospectKeysMoveToNextSiblingView			@"j"
#define kDCIntrospectKeysMoveToPrevSiblingView			@"g"

// enters GDB
#define kDCIntrospectKeysEnterGDB	@"`"
// disables DCIntrospect for a given period (see kDCIntrospectTemporaryDisableDuration)
#define kDCIntrospectKeysDisableForPeriod		@"~"
