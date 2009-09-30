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
    -(id)setter;
}

-(SelectOperation)initWithDrawingArea:(DrawingArea)area
{
    [super initWithDrawingArea: area];
    selectedFigure = nil;
    setter = nil;
    lastPoint = CGPointMakeZero();
    return self;
}

-(void)_selectSetterFor:(id)figure at:(id)pt
{
    setter = nil;

    var onPoint = function (p) {
        return p.dist(pt) < 10;
    };
    // choose the right function to call when a control point is moved
    // or null if no point was selected
    if (onPoint(figure.getBounds().start())) {
        setter = function (newPt) {
            figure.getBounds().setStart(newPt);
        };
    }
    else {
        if (onPoint(figure.getBounds().end())) {
            setter = function (newPt) {
                figure.getBounds().setEnd(newPt);
            };
        }
        else {
            if (figure instanceof FreeLine) {
                // look if one point along the FreeLine was clicked
                var pts = figure.getPoints();
                var found = null;
                pts.each(function (p) {
                        if (onPoint(p)) {
                            found = p;
                        }
                    });
                if (found) {
                    setter = function (newPt) {
                        figure.move(found, newPt);
                        found = newPt;
                    };
                }
            }
        }
    }
}

-(void)mouseDown:(CPEvent)e
{
    lastPoint = [self relativeLocation: e];
    var pt = new Point(lastPoint.x, lastPoint.y);
    var fs = [[self area] figureSet];
    var selected = fs.selectFigure(pt);
    [self _selectSetterFor: selected || selectedFigure at: pt];
    if (selectedFigure) {
        selectedFigure.setSelection(false);
        selectedFigure = nil;
    }
    if (selected) {
        selected.setSelection(true);
        selectedFigure = selected;
    }

    [[self area] display];
}

-(void)mouseDragged:(CPEvent)e
{
    var pt = [self relativeLocation: e];
    if (setter) {
        setter(new Point(pt.x, pt.y));
        [[self area] display];
    } else {
        if (selectedFigure) {
            var dx = pt.x - lastPoint.x;
            var dy = pt.y - lastPoint.y;
            lastPoint = pt;
            selectedFigure.getBounds().move(dx, dy);
            
            [[self area] display];
        }
    }
}

@end

@implementation FreeLineOperation : Operation
{
    -(id)line;
    -(id)lastPoint;
}

-(FreeLineOperation)initWithDrawingArea:(DrawingArea)area
{
    [super initWithDrawingArea: area];
    line = nil;
    lastPoint = nil;
    return self;
}

-(void)mouseDown:(CPEvent)e
{
    var pt = [self relativeLocation: e];
    line = new FreeLine();
    line.extend(new Point(pt.x, pt.y));
    lastPoint = pt;
    var fs = [[self area] figureSet];
    fs.add(line);
    [[self area] display];
}

-(void)mouseDragged:(CPEvent)e
{
    var pt = [self relativeLocation: e];
    var dx = lastPoint.x - pt.x;
    var dy = lastPoint.y - pt.y;
    if (Math.sqrt(dx*dx + dy*dy) > 10) { // minimum distance
        line.extend(new Point(pt.x, pt.y));
        lastPoint = pt;
    }
    [[self area] display];
}

@end
