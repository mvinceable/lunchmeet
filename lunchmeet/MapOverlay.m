#import "MapOverlay.h"
#import "BuildingMap.h"

@implementation MapOverlay

@synthesize coordinate;
@synthesize boundingMapRect;

- (instancetype)initWithBuildingMap:(BuildingMap *)buildingMap{
    self = [super init];
    if (self) {
        boundingMapRect = buildingMap.overlayBoundingMapRect;
        coordinate = buildingMap.midCoordinate;
        
    }
    
    return self;
}

//-(BOOL)canReplaceMapContent{
//    return NO;
//}
@end