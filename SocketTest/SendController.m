//
//  SendController.m
//  SocketTest
//
//  Created by 董一飞 on 2022/8/3.
//

#import "SendController.h"

@interface SendController ()

@property (nonatomic, weak) YYTextView *tv;

@end

@implementation SendController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.backgroundColor = [UIColor systemBlueColor];
    sendButton.layer.cornerRadius = 8;
    sendButton.layer.masksToBounds = true;
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [sendButton addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendButton];
    [sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(88);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(120, 48));
    }];
    
    YYTextView *tv = [[YYTextView alloc] init];
    self.tv = tv;
    tv.layer.cornerRadius = 8;
    tv.layer.masksToBounds = true;
    tv.layer.borderWidth = 2;
    tv.layer.borderColor = [UIColor colorWithRed:63/255.f green:209/255.f blue:167/255.f alpha:1.f].CGColor;
    tv.placeholderText = @"输入要发送的socket消息，json字符串格式";
    tv.placeholderFont = [UIFont systemFontOfSize:16];
    tv.font = [UIFont systemFontOfSize:16];
    tv.textColor = [UIColor blackColor];
    [self.view addSubview:tv];
    [tv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(sendButton.mas_bottom).offset(24);
        make.left.mas_equalTo(self.view.mas_left).offset(12);
        make.right.mas_equalTo(self.view.mas_right).offset(-12);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-100);
    }];
    
    
}

- (void)send:(UIButton *)sender{
    
    if (NULLString(self.tv.text)) {
        return;
    }
    
    [[SocketControl sharedInstance] sendMessageJson:self.tv.text];
    self.tv.text = @"";
    [self.tv endEditing:true];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:true];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
