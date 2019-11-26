# 乐马推送

[![CI Status](https://img.shields.io/travis/adam/LMPush.svg?style=flat)](https://travis-ci.org/adam/LMPush)
[![Version](https://img.shields.io/cocoapods/v/LMPush.svg?style=flat)](https://cocoapods.org/pods/LMPush)
[![License](https://img.shields.io/cocoapods/l/LMPush.svg?style=flat)](https://cocoapods.org/pods/LMPush)
[![Platform](https://img.shields.io/cocoapods/p/LMPush.svg?style=flat)](https://cocoapods.org/pods/LMPush)

## 一：“乐马推送SDK”使用入门

开发者的应用“乐马推送SDK”、“乐马IM Api SDK”或“乐马 IM UI SDK”服务，需要经过如下几个简单的步骤：

### 第 1 步：取得乐马注册后台帐号

登录乐马云控制台。如果没有账号，请取系客服。

### 第 2 步：创建应用

进入控制台，输入应用包名等信息，生成AppId（应用唯一标识）, Secret（应用安全码）等信息。

### 第 3 步：开发环境要求

Xcode 10 及以上
iOS 8.0 及以上






##  二：集成说明

### CocoaPods 集成（推荐）

支持 CocoaPods 方式和手动集成两种方式。我们推荐使用 CocoaPods 方式集成，以便随时更新至最新版本。

在 Podfile 中增加以下内容。
```
 pod 'LMPush'
```
执行以下命令，安装 LMPush。
```
 pod install
```
如果无法安装 SDK 最新版本，执行以下命令更新本地的 CocoaPods 仓库列表。
```
 pod repo update
```
 
### 手动集成（不推荐）

在 Framework Search Path 中加上 LMPush 的文件路径，手动地将 LMPush 目录添加到您的工程。
LMPush用swift语言进行原生开发，关于Objective-C桥接的相关操作，请自己Baidu查找。




## 三：在代码中引入

### 1.在 AppDelegate.m 文件中引入 LMPush，并初始化（以Swift项目为例）。
```
import LMPush

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    LMPManager.getInstance().initSdk(appkey: "申请时生成的AppId", secret: "申请时生成的Secret") //控制台中获取
    self.registeNotifications(application: application, didFinishLaunchingWithOptions:launchOptions)
    return true
}
```

### 2.在APNS回调代理方法中加入APNS回调处理代码：
```
//MARK:- 初始化推送
func registeNotifications(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)  {
    if #available(iOS 10, *) { //ios10 以上系统
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let options: UNAuthorizationOptions = [UNAuthorizationOptions.alert, .badge, .sound]
        center.requestAuthorization(options: options) { (granted: Bool, error: Error?) in
            if granted == true {
                print("注册消息推送成功")
            }else {
                print(error ?? "注册消息推送失败")
            }
        }
    }
    //获取device token
    application.registerForRemoteNotifications()
}

//MARK:- deviceToken申请结果回调
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let device: NSData = NSData(data: deviceToken)
    var token = String()
    if #available(iOS 13.0, *) {
        let bytes = [UInt8](device)
        for item in bytes {
            token += String(format:"%02x", item&0x000000FF)
        }
    }else{
        token = device.description.trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
        token = token.replacingOccurrences(of: " ", with: "")
    }
    print("apns推送证书 -- \(token)")
    //可以在这里进行postToken的调用
    LMPManager.getInstance().postToken(token: token) { (resopnse:LMResponse<Bool>) in
        if resopnse.isSuccess == true{
            // 提交成功
        }else{
            // 提交失败
        }
    }
}

@available(iOS 10.0, *)
func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
    print("前台收到推送 willPresent : \(notification.request.content.userInfo)")
    LIMManager.getInstance().onReceiveNotification(notifiation: notification)               //im api 处理推送消息的接收
}

@available(iOS 10.0, *)
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void){
    print("点击收到的apns消息推送 => \(response.notification.request.content.userInfo)")
    LIMManager.getInstance().onReceiveNotification(notifiation: response.notification)      //im api 处理推送消息的接收
}

//app在收到带content-available字段的时候 回调调用
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    LIMManager.getInstance().onReceiveNotification(notifiation: response.notification)      //im api 处理推送消息的接收
    completionHandler(UIBackgroundFetchResult.newData)
}

```

### 3. 提交APNS返回的推送token
在合适的位置进行推送token的提交，如“ didRegisterForRemoteNotificationsWithDeviceToken ” 方法回调推送token成功的方法中。
```
/**
 *  type: 1 生产证书， 2 测试证书
 */
LMPManager.getInstance().postToken(token: “String”, type: 1) { (response:LMResponse<Bool>) in
    if response.isSuccess == true{
        //  提交成功
    }ese{
        //  提交失败
    }
}
```

### 4. 设置推送监听器，并实现回调方法

#### 4.1 设置推送监听器
把一个类的实例作为推送监听器的监听处理器，并把引用赋值给LMPManager.getInstance().linstener
```
LMPManager.getInstance().linstener = self
```

#### 4.2 实现LMPNotificationLinstner方法
在监听处理器中实现 LMPNotificationLinstner 中的回调方法
```
func onNotificationReceive(item: LMNotification) {
    //接收到推送消息
}
```

 LMNotification的数据结构如下：
 ```
    "type": 1,// int
    "data": {}, //JSON Object 
    "title":"",  //string  针对推送消息 appid=1 时可能有值
    "content":"" ,//string 针对推送消息 appid=1 时可能有值
 ```

### 5. 开启推送服务
startSDK 方法调用成功后，开启推送服务成功
```
LMPManager.getInstance().startSDK { (response:LMResponse<Bool>) in
    if response.isSuccess == true{
        //开启推送服务
    }else{
        //开启推送服务失败, 一般由于网络原因造成
    }
}

```
