//
//  TNTextTooBar.h
//  RoadBird
//
//  Created by tooniao on 16/11/4.
//  Copyright © 2016年 tang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNTextTooBar : UIToolbar

@property(nonatomic,strong)void (^rightBtnClock)();
@property(nonatomic,strong)NSString *str ;
@end
