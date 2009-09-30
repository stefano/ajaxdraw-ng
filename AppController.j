/*
 * AppController.j
 */

@import <Foundation/CPObject.j>

@import "Utils.j"
@import "Figures.j"
@import "Operations.j"

@implementation DrawingArea : CPView
{
    -(FigureSet)fs;
}

-(void)initWithFrame:(CGRect)aRect
{
    [super initWithFrame: aRect];
    fs = new FigureSet();

    return self;
}

-(void)drawRect:(CPRect)aRect
{
    var ctx = [[CPGraphicsContext currentContext] graphicsPort];
    fs.each(function (f) {
            f.draw(ctx);
            f.drawSelection(ctx);
            });
}

-(void)figureSet
{
    return fs;
}
@end

@implementation DrawTools : CPObject
{
    - (CPDictionary)_tools;
    - (DrawingArea)_area;
}

-(void)itemActivated:(id)sender
{
    [_area setNextResponder: [Resp1 alloc]];
}

-(void)addItem:(CPString)name withImage:(CPString)image withOperation:(Operation)operation
{
    var size = CPSizeMake(32, 32);
    var itm = [[CPToolbarItem alloc] initWithItemIdentifier: name];
    var image = [[CPImage alloc] initWithContentsOfFile: image size: size];

    [image setDelegate: self];
    [itm setImage: image];    
    [itm setLabel: name];
    [itm setTarget: operation];
    [itm setAction: @selector(installOperation:)];
    [itm setMinSize: size];
    [itm setMaxSize: size];

    [_tools setObject: itm forKey: name];
}

-(DrawTools)initWithDrawingArea:(DrawingArea)area
{
    _tools = [CPDictionary alloc];
    _area = area;

    [self addItem: 'Select' withImage: 'Resources/selectDraw.png'
          withOperation: [[SelectOperation alloc]
                             initWithDrawingArea: _area]];
    [self addItem: 'Line' withImage: 'Resources/lineDraw.png'
          withOperation: [[BoundedDrawOperation alloc]
                             initWithDrawingArea: _area
                                   objectBuilder: function () { return new StraightLine(); }]];
    [self addItem: 'Rectangle' withImage: 'Resources/squareDraw.png'
          withOperation: [[BoundedDrawOperation alloc]
                             initWithDrawingArea: _area
                                   objectBuilder: function () { return new Rectangle(); }]];
    [self addItem: 'Circle' withImage: 'Resources/circleDraw.png'
          withOperation: [[BoundedDrawOperation alloc]
                             initWithDrawingArea: _area
                                   objectBuilder: function () { return new Circle(); }]];

    return self;
}

-(CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)toolbar
{
    return [_tools allKeys];
}

-(CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)toolbar
{
    return [self toolbarDefaultItemIdentifiers: toolbar];
}

- (CPToolbarItem)toolbar:(CPToolbar)toolbar itemForItemIdentifier:(CPString)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    return [_tools valueForKey: itemIdentifier];
}

@end

@implementation AppController : CPObject
{
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    CPLogRegister(CPLogPopup);

    var theWindow = [[CPWindow alloc] 
                        initWithContentRect: CGRectMakeZero()
                                  styleMask: CPBorderlessBridgeWindowMask];
    contentView = [theWindow contentView];

    [contentView setBackgroundColor: [CPColor whiteColor]];

    var bounds = [contentView bounds];

    var da = [[DrawingArea alloc] initWithFrame: CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds))];
    [da setBackgroundColor: [CPColor whiteColor]];
    [contentView addSubview: da];

    var toolbar = [[CPToolbar alloc] initWithIdentifier: 'mainTools'];
    var delegate = [[DrawTools alloc] initWithDrawingArea: da];

    [toolbar setDelegate: delegate];
    [toolbar setVisible: YES];
    [theWindow setToolbar: toolbar];

    [theWindow orderFront:self];
    
    //[CPMenu setMenuBarVisible:YES];
}

@end
