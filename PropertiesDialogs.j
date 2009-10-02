@implementation ColorDialog : CPWindow
{
    -(DrawingArea)area
    -(id)selectedFigure;
    -(CPButton)borderColor;
    -(CPButton)fillColor;
}

-(ColorDialog)initWithin:(DrawingArea)aView
{
    area = aView;
    bounds = [aView bounds];
    var height = 100;
    var width = 200;

    [super initWithContentRect: CGRectMake(CGRectGetWidth(bounds)-(width+10), 64,
                                           width, height)
                     styleMask: CPTitledWindowMask | CPMiniaturizableWindowMask | CPResizableWindowMask];
    [self setTitle: 'Change colors'];
    [self orderFront: self];
    selectedFigure = nil;

    borderColor = [[ColorPreview alloc] initWithFrame: CGRectMake(0, 0, 200, 50)
                                                label: 'Border color'
                                               getter: function (f) { return f.getBorderColour(); }
    area: area];

    fillColor = [[ColorPreview alloc] initWithFrame: CGRectMake(0, 50, 200, 50)
                                                label: 'Fill color'
                                             getter: function (f) { if (f.getFillColour) { return f.getFillColour(); } else { return null; } }
    area: area];

    var v = [self contentView];
    
    [v addSubview: borderColor];
    [v addSubview: fillColor];

    return self;
}

-(void)selectedFigureChanged:(id)figure
{
    selectedFigure = figure;
    [borderColor selectedFigureChanged: figure];
    [fillColor selectedFigureChanged: figure];
}

@end

@implementation ColorPreview : CPView
{
    -(id)selectedFigure;
    -(DrawingArea)area;
    -(id)getter;
    -(CPButton) btn;
}

-(ColorPreview)initWithFrame:(id)frame label:(id)label getter:(id)g area:(DrawingArea)a
{
    [super initWithFrame: frame];

    area = a;
    getter =  g;
    selectedFigure = nil;

    var lbl = [[CPTextField alloc] initWithFrame: CGRectMake(0, 10, 150 , 32)];
    [lbl setPlaceholderString: label];
    [lbl setEditable: NO];
    [self addSubview: lbl];

    btn = [[CPButton alloc] initWithFrame: CGRectMake(100, 10, 64, 16)];
    [btn setBackgroundColor: [CPColor whiteColor]];
    [btn setTarget: self];
    [btn setAction: @selector(openDialog:)];
    [btn setBordered: NO];
    [self addSubview: btn];

    return self;
}

-(void)openDialog:(CPEvent)e
{
    var panel = [CPColorPanel sharedColorPanel];
    [panel setTarget: self];
    [panel setAction: @selector(colorDidChange:)];
    [panel setColor: [btn backgroundColor]];
    [panel orderFront: self];
}

-(void)colorDidChange:(CPEvent)e
{
    if (selectedFigure) {
        var panel = [CPColorPanel sharedColorPanel];
        var color = [panel color];
        var c = getter(selectedFigure);
        if (c) {
            c.fromCSS('#'+[color hexString]);
            c.getOpacity().setVal([color alphaComponent]);
        }
        [self resetColor];
        [area display];
    }
}

-(void)resetColor
{
    if (selectedFigure) {
        var c = getter(selectedFigure);
        if (c) {
            var color = [CPColor colorWithCSSString: c.toCSS()];
            [btn setBackgroundColor: [color colorWithAlphaComponent: c.getOpacity().getVal()]];
        }
    }
}

-(void)selectedFigureChanged:(id)figure
{
    selectedFigure = figure;
    [self resetColor];
}
@end
