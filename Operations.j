/*
 * Drawing operations
 */

@implementation Operation : CPResponder
{
    -(DrawingArea)_area;
}

-(void)initWithDrawingArea:(DrawingArea)area
{
    _area = area;

    return self;
}

-(DrawingArea)area 
{ 
    return _area;
}

-(CGPoint)relativeLocation:(CPEvent)e
{
    return [_area convertPoint: [e locationInWindow]
                      fromView: nil];

}

-(void)installOperation:(CPEvent)e
{
    [_area setNextResponder: self];
}
@end

@implementation BoundedDrawOperation : Operation
{
    -(id)currentObject;
    -(id)createObject;
}

-(BoundedDrawOperation)initWithDrawingArea:(DrawingArea)area objectBuilder:(id)builder
{
    [super initWithDrawingArea: area];
    createObject = builder;

    return self;
}

-(void)mouseDown:(CPEvent)e
{
    var pt = [self relativeLocation: e];
    currentObject = createObject();
    var fs = [[self area] figureSet];
    fs.add(currentObject);
    currentObject.getBounds().setStart(new Point(pt.x, pt.y));
}

-(void)mouseDragged:(CPEvent)e
{
    if (currentObject) {
        var pt = [self relativeLocation: e];
        currentObject.getBounds().setEnd(new Point(pt.x, pt.y));
        [[self area] display];
    }
}

-(void)mouseUp:(CPEvent)e
{
    [self mouseDragged: e];
    currentObject = nil;
}
@end

@implementation SelectOperation : Operation
{
    -(id)selectedFigure;
    -(CGPoint)lastPoint;
}

-(SelectOperation)initWithDrawingArea:(DrawingArea)area
{
    [super initWithDrawingArea: area];
    selectedFigure = nil;
    lastPoint = CGPointMakeZero();
    return self;
}

-(void)mouseDown:(CPEvent)e
{
    if (selectedFigure) {
        selectedFigure.setSelection(false);
        selectedFigure = nil;
    }
    lastPoint = [self relativeLocation: e];
    var fs = [[self area] figureSet];
    var selected = fs.selectFigure(new Point(lastPoint.x, lastPoint.y));
    if (selected) {
        selected.setSelection(true);
        selectedFigure = selected;
    }

    [[self area] display];
}

-(void)mouseDragged:(CPEvent)e
{
    if (selectedFigure) {
        var pt = [self relativeLocation: e];
        var dx = pt.x - lastPoint.x;
        var dy = pt.y - lastPoint.y;
        lastPoint = pt;
        selectedFigure.getBounds().move(dx, dy);

        [[self area] display];
    }
}

@end
