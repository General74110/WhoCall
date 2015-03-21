//
//  UIColor+Hex.h
//  KidReading
//
//  Created by telen on 15/1/1.
//  Copyright (c) 2015年 刘赞黄Telen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

//字符串转颜色
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;
//颜色转字符串
+ (NSString *) changeUIColorToRGB:(UIColor *)color;

@end
