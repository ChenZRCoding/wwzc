//
//  RegisterViewController.m
//  RoadBird
//
//  Created by tang on 15/5/25.
//  Copyright (c) 2015年 tang. All rights reserved.
//

#import "RegisterViewController.h"
#import "CCFramework.h"
#import "TNTextTooBar.h"

@interface RegisterViewController () <UITextFieldDelegate,AMapLocationManagerDelegate> {
    NSTimer * _timer;
    BOOL _capthaDown;
    NSInteger _countDown;
    NSString *_serverCode;
    
    IBOutlet UITextField *_phoneTextField;
    IBOutlet UITextField *_codeTextField;
    __weak IBOutlet UITextField *_pwdTextField;
    
    __weak IBOutlet UITextField *_recomTextField;
    __weak IBOutlet UIButton *_captchaBtn;
  
    
}
@property(weak,nonatomic)TNTextTooBar *toobar ;
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property(nonatomic,strong)TipTool *tip;

@end

@implementation RegisterViewController

- (TipTool *)tip
{
    if (!_tip) {
        _tip = [TipTool new] ;
    }
    return _tip ;
}
- (TNTextTooBar *)toobar
{
    if (!_toobar) {
        TNTextTooBar *toobar = [TNTextTooBar czr_viewFromNib] ;
        _toobar  = toobar ;
    }
    return  _toobar ;
}

- (AMapLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[AMapLocationManager alloc] init];
    }
    return _locationManager ;
}


-(void)viewWillAppear:(BOOL)animated { 
    
     [super viewWillAppear:animated];
      self.navigationController.navigationBar.hidden = NO;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO ;
    
    self.title = @"新用户注册";
    
//    [self locate];
    
    _countDown = 60;
 
    _phoneTextField.delegate = self;
    _pwdTextField.delegate = self;
    _recomTextField.delegate = self;
    

    _phoneTextField.inputAccessoryView = self.toobar ;
    [_phoneTextField becomeFirstResponder];
    _codeTextField.inputAccessoryView = self.toobar ;
    _pwdTextField.inputAccessoryView = self.toobar ;

    _recomTextField.inputAccessoryView = self.toobar ;
    
    self.toobar.rightBtnClock = ^{
        [self.view endEditing:YES];
    };


}

- (IBAction)showPassword:(UIButton *)btn {
    btn.selected = !btn.selected;
    _pwdTextField.secureTextEntry =!btn.selected;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 1100) {
        NSCharacterSet *cs;
        cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBER_ONLY] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""]; //按cs分离出数组,数组按@""分离出字符串
        BOOL canChange = [string isEqualToString:filtered];
        
        return canChange;
    }
    return YES;
}




-(NSString *) trimSpace:(NSString *)str
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [str stringByTrimmingCharactersInSet:whitespace];
}



- (IBAction)nextButtonClicked:(UIButton *)sender {
   

  
    NSString *phone=_phoneTextField.text;
    NSString *pwd= [self trimSpace:_pwdTextField.text];

    if (![SysModel checkPhone:phone]) {
        [self.tip showFailTip:@"请填写正确手机号"];
        return;
    }
 
    
    
    if (![SysModel checkPwd:pwd]) {
        [self.tip showFailTip:@"密码格式不正确(请输入6-16数字或英文)"];
        return;
    }
    
    if (_codeTextField.text.length ==0 || _codeTextField.text.length >4 ||_codeTextField.text.length <4) {
        [self.tip showFailTip:@"请填写正确验证码格式"];
        return;
    }

    
    [self registerAction];
    

}

-(void)registerAction
{
    NSDictionary * params = @{
                              @"phone":_phoneTextField.text,
                              @"client":USER.client_type,
                              @"device":USER.device_type,
                              @"version":STRING(APP_VERSION),
                              @"password":_pwdTextField.text,
                              @"code":_codeTextField.text,
                              @"os":STRING( PHONE_OS),
                              @"lat": @(USER.locationPosLat),
                              @"lng": @(USER.locationPosLng),
                              @"location": STRING(USER.locationCity),
                              @"city_code": STRING( USER.locationAdcode),
                              @"inviter_id": STRING( _recomTextField.text),
                              @"device_code": STRING(USER.clientId),
                              @"device_name": STRING(PHONE_MODEL)
                              };
    
    [HttpManager postWithPath:[UrlConfig getRegister] params:params success:^(id JSON) {
        NSDictionary *dict  = (NSDictionary *)JSON ;
        NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"注册信息%@",str);
        [self.tip removeHUD];
        
        if ( RESP_SUCCESS(JSON) ){// 1自动登陆 2 返回登陆界面
            [self.tip showSuccessTip:@"恭喜,注册成功！"];
            
            [self autoLogin:dict];
            
            
        } else if ( RESP_FAIL(JSON)) {
            [self.tip showFailTip:RESP_ERROR_MESSAGE(JSON)];
        }
        
    } failure:^(NSError *error) {
        [self.tip removeHUD];
        [self.tip showFailTip:@"网络连接失败"];
        
    }];
}
-(void)autoLogin:(NSDictionary*)d
{
    NSDictionary *dic = d[@"data"];
    USER.token=dic[@"token"];
    USER.phone=dic[@"phone"];
    USER.user_id=dic[@"uid"] ;
    USER.im_token = [NSString stringWithFormat:@"%@",dic[@"im_token"]];
    
    USER.verify_card = 2;
    USER.verify_company = 2;
    
    //判断身份状态
    USER.userType = [SysModel JudgmentOfIdentityByType:[dic[@"type"] intValue]];
    USER.bLogin = YES;
    USER.locationAdcode=nil;//置空城市

    USER.face = dic[@"face"];
    USER.name = dic[@"nick_name"] ? dic[@"nick_name"]:@"未设置昵称";
    
    //设置手机号 补足定位信息
    [USER.locationDict setObject:STRING(USER.phone)  forKey:@"phone"];
    
    [USER WriteInfo];
    
    [self CreateMain];

}

-(void)CreateMain
{
    SYS.home  = [[HomeViewController alloc]init];
    SYS.homeNav = [[RootNavigationController alloc] initWithRootViewController: SYS.home];
    //切换跟控制器
    [UIApplication sharedApplication].keyWindow.rootViewController = SYS.homeNav ;
    //添加转场动画
    CATransition *anim = [CATransition animation];
    anim.type = @"rippleEffect";
    anim.duration = 1 ;
    //把动画添加到 窗口上
    [[UIApplication sharedApplication].keyWindow.layer addAnimation:anim forKey:nil];
    
    
}


- (IBAction)getCodeButtonClicked:(UIButton *)sender {
    
  
    if (![SysModel checkPhone:_phoneTextField.text]) {
        [self.tip showFailTip:@"请填正确的手机号"];
        return;
    }

    NSDictionary *parameter = @{@"phone":_phoneTextField.text,
                                @"type":@"1"
                                };
    [self.tip showLoadingView:@"正在发送验证码"];

    //18271314767
    [HttpManager postWithPath:[UrlConfig getMessage] params:parameter success:^(id JSON) {
        [self.tip hide];
        
         NSLog(@"%@", JSON);
        
        if (RESP_SUCCESS(JSON))
        {
            
            [self.tip showSuccessTip:@"验证码已发送至手机，请注意查收"];
            USER.phone = _phoneTextField.text;
            _capthaDown = YES;
            
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(registerGoToCountTimeAction) userInfo:nil repeats:YES];
            
            _captchaBtn.enabled = false;
            
        } else {

             NSLog(@"%@", JSON);
            [self.tip showFailTip:RESP_ERROR_MESSAGE(JSON)];

        }
    } failure:^(NSError *error) {
        [self.tip hide];
        [self.tip showFailTip:@"网络连接失败"];
    }];


    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{

}


- (void)registerGoToCountTimeAction {
    if (_capthaDown) {
        NSString * str = [NSString stringWithFormat:@"重新获取(%li)",(long)_countDown];
        [_captchaBtn setTitle:str forState:UIControlStateNormal];
        _countDown --;
        if (_countDown == 0) {
            _capthaDown = NO;
            [_captchaBtn setTitle:@"重新发送" forState:UIControlStateNormal];
            _captchaBtn.enabled = true;
            [_timer invalidate];
            _countDown = 60;
        }
    }
}



- (IBAction)agreeClick:(id)sender {
    
    WebViewController *vc = [[WebViewController alloc] init];
    vc.strURL= @"https://tuniao.oss-cn-hangzhou.aliyuncs.com/html/agreement/index.html";
    vc.strTitle = @"服务协议";
    [self.navigationController pushViewController:vc animated:YES];

    
}

@end
