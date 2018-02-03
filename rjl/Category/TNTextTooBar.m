//
//  TNTextTooBar.m
//  RoadBird
//
//  Created by tooniao on 16/11/4.
//  Copyright © 2016年 tang. All rights reserved.
//

#import "TNTextTooBar.h"

@interface TNTextTooBar ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btn;

@end
@implementation TNTextTooBar
- (IBAction)wcClick:(id)sender {
    if (_rightBtnClock) {
        _rightBtnClock();
    }
}

- (void)setStr:(NSString *)str
{
    [_btn setTitle:str];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
