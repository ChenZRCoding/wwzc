//
//  BaseViewController.m
//  RoadBird
//
//  Created by tang on 15/5/25.
//  Copyright (c) 2015年 tang. All rights reserved.
//

#import "BaseViewController.h"
#import "MBProgressHUD.h"
#import "CCFramework.h"
//#import "uii"

@interface BaseViewController ()

@property(nonatomic,strong)NSString *telphone ;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    
    [self.navigationController.navigationBar setHidden:NO];
    
    [self initNavBar];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    
    tip = [[TipTool alloc] init];
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    [self.view endEditing:YES];
}

/**
 * 方法名
 * @param
 */
-(void)initNavBar
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    [backButton setTitle:@"返回" forState:UIControlStateNormal];
//    backButton.backgroundColor = [UIColor redColor];
    [backButton setImage:GET_IMAGE(@"public_back") forState:UIControlStateNormal];
    [backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    //[backButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
 
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   
}
/**
 * 方法名
 * @param
 */
-(void)backButtonClicked:(UIButton *)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)OpenAddrBook
{
    int __block tip=0;
    //声明一个通讯簿的引用
    ABAddressBookRef addBook =nil;
    //创建通讯簿的引用
    addBook=ABAddressBookCreateWithOptions(NULL,NULL);
    //创建一个出事信号量为0的信号
    dispatch_semaphore_t sema=dispatch_semaphore_create(0);
    //申请访问权限
    ABAddressBookRequestAccessWithCompletion(addBook, ^(bool greanted,CFErrorRef error)        {
        //greanted为YES是表示用户允许，否则为不允许
        if (!greanted) {
            tip=1;
        }
        //发送一次信号
        dispatch_semaphore_signal(sema);
    });
    
    //等待信号触发
    dispatch_semaphore_wait(sema,DISPATCH_TIME_FOREVER);
    
    
    if (tip) {
        
        [TipTool showMRYAlertView: @"没有权限访问您的联系人。您可以在'设置'->'隐私'->'通讯录 中启用访问权限" ];
        
    }else{
        ABPeoplePickerNavigationController* _peoplePicker= [[ABPeoplePickerNavigationController alloc] init];
        _peoplePicker.peoplePickerDelegate =self;
        NSArray *displayItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty],nil];
        _peoplePicker.displayedProperties=displayItems;
        [self presentViewController:_peoplePicker animated:YES completion:nil];
    }
    
    
    
}


-(void)telephone:(NSString *)phone
{
    _telphone = phone ;
//    NSString *str=[ NSString  stringWithFormat:@"tel:%@" ,phone ];
//    
//    UIWebView * callWebview = [[UIWebView alloc] init];
//    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
//    [self.view addSubview:callWebview];
    
//    NSLog(@"%@",[SysModel getCurrentDeviceModel]);
//    if ([[SysModel getCurrentDeviceModel] isEqualToString:@"iPhone6"]){
    
        NSString *p =  [NSString stringWithFormat:@"tel://%@",phone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:p]];
//    }else{
//        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:phone message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
//        alertView.alertViewStyle = UIAlertViewStyleDefault;
//        [alertView show];
//    }



}

#pragma mark - <UIAlertViewDelegate>
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
    }else{
        NSString *p =  [NSString stringWithFormat:@"tel://%@",_telphone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:p]];
    }
}
 
 
 
//-(void)dealloc
//{
//    NSLog(@"%s" ,__func__);
//    
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 @end
