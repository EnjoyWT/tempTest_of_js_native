//
//  JSOCDemoVC.h
//  webkit
//
//  Created by msbaby on 2019/1/16.
//  Copyright © 2019 msbaby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSOCDemoVC : UIViewController
- (void)getNativeInfo:(NSDictionary *)params :(void(^)(id response))successCallBack :(void(^)(id response))failureCallBack;
@end

NS_ASSUME_NONNULL_END
