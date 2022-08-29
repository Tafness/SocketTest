//
//  ReceiveController.m
//  SocketTest
//
//  Created by 董一飞 on 2022/8/3.
//

#import "ReceiveController.h"

@interface ReceiveController ()

@property (nonatomic, weak) YYTextView *tv;

@end

@implementation ReceiveController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_receiveConnectMessage:) name:@"kSocketReceiveMessage" object:nil];
    
    YYTextView *tv = [[YYTextView alloc] init];
    self.tv = tv;
    tv.editable = false;
    tv.font = [UIFont systemFontOfSize:16];
    tv.textColor = [UIColor blackColor];
    [self.view addSubview:tv];
    [tv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(88, 10, 50, 10));
        make.height.mas_greaterThanOrEqualTo(50);
    }];
}

- (void)notification_receiveConnectMessage:(NSNotification *)noti{
    NSDictionary *dic = noti.userInfo;
    
    NSString *string = [NSString stringWithFormat:@"%@\n -------- \n", [JsonAndDictionary convertToJsonData:dic]];
    self.tv.text = [string stringByAppendingString:self.tv.text];
    [self.tv scrollsToTop];
    
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
