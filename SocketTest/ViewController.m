//
//  ViewController.m
//  SocketTest
//
//  Created by 董一飞 on 2022/8/3.
//

#import "ViewController.h"
#import "SendController.h"
#import "ReceiveController.h"
@interface ViewController ()

@property (nonatomic, weak) YYTextView *tv1;

@property (nonatomic, weak) YYTextView *tv2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_receiveConnectSuccess:) name:@"kSocketConnectSuccess" object:nil];
    
    UIView *backview1 = [[UIView alloc] init];
    backview1.layer.cornerRadius = 8;
    backview1.layer.masksToBounds = true;
    backview1.layer.borderWidth = 2;
    backview1.layer.borderColor = [UIColor colorWithRed:63/255.f green:209/255.f blue:167/255.f alpha:1.f].CGColor;
    [self.view addSubview:backview1];
    [backview1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(160);
        make.left.mas_equalTo(self.view.mas_left).offset(24);
        make.right.mas_equalTo(self.view.mas_right).offset(-24);
        make.height.mas_greaterThanOrEqualTo(40);
    }];
    
    YYTextView *tv1 = [[YYTextView alloc] init];
    self.tv1 = tv1;
    tv1.placeholderText = @"输入socket路径";
    tv1.placeholderFont = [UIFont systemFontOfSize:16];
    tv1.font = [UIFont systemFontOfSize:16];
    tv1.textColor = [UIColor colorWithRed:63/255.f green:209/255.f blue:167/255.f alpha:1.f];
    [backview1 addSubview:tv1];
    [tv1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(backview1).insets(UIEdgeInsetsMake(10, 12, 10, 12));
        make.height.mas_greaterThanOrEqualTo(36);
    }];
    if (!NULLString([defaluts valueForKey:@"socketUrl"])) {
        tv1.text = [defaluts valueForKey:@"socketUrl"];
    }
    
    UIView *backview2 = [[UIView alloc] init];
    backview2.layer.cornerRadius = 8;
    backview2.layer.masksToBounds = true;
    backview2.layer.borderWidth = 2;
    backview2.layer.borderColor = [UIColor colorWithRed:63/255.f green:209/255.f blue:167/255.f alpha:1.f].CGColor;
    [self.view addSubview:backview2];
    [backview2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tv1.mas_bottom).offset(40);
        make.left.mas_equalTo(self.view.mas_left).offset(24);
        make.right.mas_equalTo(self.view.mas_right).offset(-24);
        make.height.mas_greaterThanOrEqualTo(40);
    }];
    
    YYTextView *tv2 = [[YYTextView alloc] init];
    self.tv2 = tv2;
    tv2.placeholderText = @"输入端口";
    tv2.placeholderFont = [UIFont systemFontOfSize:16];
    tv2.font = [UIFont systemFontOfSize:16];
    tv2.textColor = [UIColor colorWithRed:63/255.f green:209/255.f blue:167/255.f alpha:1.f];
    tv2.keyboardType = UIKeyboardTypeNumberPad;
    [backview2 addSubview:tv2];
    [tv2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(backview2).insets(UIEdgeInsetsMake(10, 12, 10, 12));
        make.height.mas_greaterThanOrEqualTo(36);
    }];
    if ([defaluts integerForKey:@"socketPort"] != 0) {
        tv2.text = [NSString stringWithFormat:@"%ld", [defaluts integerForKey:@"socketPort"]];
    }
    
    UIButton *connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    connectBtn.backgroundColor = [UIColor systemBlueColor];
    connectBtn.layer.cornerRadius = 8;
    connectBtn.layer.masksToBounds = true;
    [connectBtn setTitle:@"Connect" forState:UIControlStateNormal];
    [connectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    connectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [connectBtn addTarget:self action:@selector(connect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:connectBtn];
    [connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(backview2.mas_bottom).offset(50);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(120, 48));
    }];
    NSLog(@"");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:true];
}

- (void)connect:(UIButton *)sender{
    
    if (NULLString(self.tv1.text)) {
        [self showAlert:@"请先输入socket路径"];
        return;
    }
    
    if (NULLString(self.tv2.text)) {
        [self showAlert:@"请先输入socket端口"];
        return;
    }
    
    [SocketControl sharedInstance].socketUrl = self.tv1.text;
    [SocketControl sharedInstance].port = [self.tv2.text integerValue];
    
    [[SocketControl sharedInstance] connectSocket];
}

- (void)notification_receiveConnectSuccess:(NSNotification *)noti{
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    [defaluts setValue:[SocketControl sharedInstance].socketUrl forKey:@"socketUrl"];
    [defaluts setInteger:[SocketControl sharedInstance].port forKey:@"socketPort"];

    [self pushToSocketController];
}

- (void)pushToSocketController{
    
    SendController *sc = [[SendController alloc] init];
    sc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"发送" image:[[UIImage imageNamed:@"send"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"send"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    ReceiveController *rc = [[ReceiveController alloc] init];
    rc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"接收" image:[[UIImage imageNamed:@"receive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"receive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UITabBarController *tbc = [[UITabBarController alloc] init];
    tbc.viewControllers = @[rc, sc];
    [self.navigationController pushViewController:tbc animated:YES];
    
}

- (void)showAlert:(NSString *)title{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"提示" message:title preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        
    [ac addAction:action];
    
    [self presentViewController:ac animated:true completion:nil];
}

@end
