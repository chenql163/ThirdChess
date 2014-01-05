//
//  BgNode.m
//  ThirdChess
//
//  Created by apple on 14-1-5.
//  Copyright (c) 2014年 Gemstar. All rights reserved.
//

#import "BgNode.h"

@interface BgNode (){
    CCArray *linePoints;
    NSMutableDictionary *positionRects;
    float _width;
}


@end

@implementation BgNode
+(BgNode *)node{
    BgNode *node = [[BgNode alloc] init];
    [node autorelease];
    return node;
}
-(id)init{
    if (self = [super init]) {
        linePoints = [[CCArray arrayWithCapacity:16] retain];
        positionRects = [[NSMutableDictionary alloc] init];
        
        //计算内容大小
        CGSize winSize = [CCDirector sharedDirector].winSize;
        float width = winSize.width;
        float height = winSize.height;
        
        width = MIN(width, height);
        _contentSize = CGSizeMake(width, width);
        _anchorPointInPoints = _anchorPoint = ccp(0.5, 0.5);
    }
    return self;
}
-(void)calcPoints{
    //计算划线的顶点
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float width = winSize.width;
    float height = winSize.height;
    
    float min = MIN(width, height);
    NSInteger pointsPerLine = 7;
    float positionWidth = 36;
    float distance = (min - positionWidth * pointsPerLine ) / (pointsPerLine - 1);
    distance += positionWidth;
    
    NSArray *positionDistance = @[
                                  @[@0,@0,@-1,@-1],@[@1,@0,@-2,@-2],@[@2,@0,@-3,@-3],
                                  @[@0,@1,@0 ,@-1],@[@1,@1,@0 ,@-2],@[@2,@1,@0 ,@-3],
                                  @[@0,@2,@1 ,@-1],@[@1,@2,@2 ,@-2],@[@2,@2,@3 ,@-3],
                                  @[@0,@3,@1 ,@0 ],@[@1,@3,@2 ,@0 ],@[@2,@3,@3, @0 ],
                                  @[@0,@4,@1 ,@1 ],@[@1,@4,@2 ,@2 ],@[@2,@4,@3 ,@3 ],
                                  @[@0,@5,@0 ,@1 ],@[@1,@5,@0 ,@2 ],@[@2,@5,@0 ,@3 ],
                                  @[@0,@6,@-1,@1 ],@[@1,@6,@-2,@2 ],@[@2,@6,@-3,@3],
                                  @[@0,@7,@-1,@0 ],@[@1,@7,@-2,@0 ],@[@2,@7,@-3,@0]
                                  ];
    CCDirector *director = [CCDirector sharedDirector];
    for (NSArray *pos in positionDistance) {
        float p1 = [[pos objectAtIndex:0] floatValue];
        float p2 = [[pos objectAtIndex:1] floatValue];
        
        float n1 = [[pos objectAtIndex:2] floatValue];
        float n2 = [[pos objectAtIndex:3] floatValue];
        CGPoint point = ccp(p1, p2);
        CGPoint center = ccpAdd(_position, ccp(distance*n1, distance*n2));
        center = [director convertToGL:center];
        CGRect rect = CGRectMake(center.x-positionWidth*0.5, center.y-positionWidth*0.5, positionWidth, positionWidth);
        [positionRects setObject:[NSValue valueWithCGRect:rect] forKey:[NSValue valueWithCGPoint:point]];
    }

    NSArray *lineDistance = @[
                             @[@-3,@-3,@3,@-3],
                             @[@-2,@-2,@2,@-2],
                             @[@-1,@-1,@1,@-1],
                             @[@-1,@1,@1,@1],
                             @[@-2,@2,@2,@2],
                             @[@-3,@3,@3,@3],
                             @[@-3,@-3,@-3,@3],
                             @[@-2,@-2,@-2,@2],
                             @[@-1,@-1,@-1,@1],
                             @[@1,@-1,@1,@1],
                             @[@2,@-2,@2,@2],
                             @[@3,@-3,@3,@3],
                             @[@0,@-3,@0,@-1],
                             @[@0,@1,@0,@3],
                             @[@-3,@0,@-1,@0],
                             @[@1,@0,@3,@0],
                             @[@-3,@-3,@-1,@-1],
                             @[@1,@-1,@3,@-3],
                             @[@-1,@1,@-3,@3],
                             @[@1,@1,@3,@3]
                             ];
    for (NSArray *points in lineDistance) {
        float n1 = [[points objectAtIndex:0] floatValue];
        float n2 = [[points objectAtIndex:1] floatValue];
        float n3 = [[points objectAtIndex:2] floatValue];
        float n4 = [[points objectAtIndex:3] floatValue];
        CGPoint p1 = ccpAdd(_position, ccp(distance*n1, distance*n2));
        CGPoint p2 = ccpAdd(_position, ccp(distance*n3, distance*n4));
        
        NSArray *line1 = @[[NSValue valueWithCGPoint:p1],[NSValue valueWithCGPoint:p2]];
        [linePoints addObject:line1];
    }
    
}
-(void)draw{
    glLineWidth( 5.0f );
	ccDrawColor4B(255,0,0,255);
    
    CCDirector *director = [CCDirector sharedDirector];
    NSArray *line;
    CCARRAY_FOREACH(linePoints, line){
        CGPoint p1 = [[line objectAtIndex:0] CGPointValue];
        CGPoint p2 = [[line objectAtIndex:1] CGPointValue];
        p1 = [director convertToGL:p1];
        p2 = [director convertToGL:p2];
        ccDrawLine(p1, p2);
    }
}
-(NSDictionary *)positionDic{
    return positionRects;
}
-(void)dealloc{
    [linePoints release];
    [positionRects release];
    [super dealloc];
}
@end
