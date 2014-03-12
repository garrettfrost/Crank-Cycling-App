//
//  CandlestickChartSeries.h
//  SChart
//
//  Copyright 2011 Scott Logic Ltd. All rights reserved.
//

#import "SChartGLCommon.h"

@interface SChartGLView (CandlestickChartSeries)

- (void)drawCandlesticks:(float *)series
               forSeries:(SChartSeries *)s
           forLinesIndex:(int *)linesIndex
       forTrianglesIndex:(int *)trianglesIndex
                withSize:(NSInteger)size
              withColors:(NSMutableArray *)colors
      withGradientColors:(NSMutableArray *)gradientColors
        withOutlineColor:(UIColor *)outlineColor
          withStickColor:(UIColor *)stickColor
         withCandleWidth:(float)candleWidth
        withOutlineWidth:(float)outlineWidth
          withStickWidth:(float)stickWidth
         withOrientation:(NSInteger)orientation
          andTranslation:(const SChartGLTranslation *)transform;

@end
