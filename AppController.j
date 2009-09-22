/*
 * AppController.j
 */

@import <Foundation/CPObject.j>

@implementation AppController : CPObject
{
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] 
                        initWithContentRect:CGRectMakeZero()
                                  styleMask:CPBorderlessBridgeWindowMask];
    contentView = [theWindow contentView];
	
    [theWindow orderFront:self];
    
    [CPMenu setMenuBarVisible:YES];
}

@end
