//
//  BaseViewController.h
//  RoadBird
//
//  Created by tang on 15/5/25.
//  Copyright (c) 2015年 tang. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "TipTool.h"
#import "VoiceConverter.h"



 

@interface BaseViewController : UIViewController
{
  TipTool *tip ; 
    
}

-(void)OpenAddrBook;
-(void)telephone:(NSString *)phone;
-(void)backButtonClicked:(UIButton *)sender;

-(void)keyboardHide:(UITapGestureRecognizer*)tap;

@end
