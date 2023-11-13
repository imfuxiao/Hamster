# 「仓」输入法

一款基于「[中州韻輸入法引擎／Rime Input Method Engine](https://github.com/rime/librime)」的 iOS 版本输入法.

# 如何编译运行

在 1.0 版本，很多伙伴 `clone` 项目后都无法直接运行，多数问题是被被卡在 `librime` 的编译下了，于是新版本将这步省略了。

目前 [LibrimeKit](https://github.com/imfuxiao/LibrimeKit) 项目，只用来作为 [librime](https://github.com/rime/librime)  的编译项目，并使用 `Github Action` 将依赖的 Framework 编译并发布 Release。大家可以下载编译好的 Framework 使用，无需在为了编译环境而困扰。

> 感谢 @amorphobia 为 LibrimeKit 提交的 Github Action 配置

1. 下载编译后的 Framework.

```sh
make framework
```

2. XCode 打开项目并运行（我个人使用的开发环境 Intel X86，MacOS 14，XCode 15）

```sh
xed .
```

# 第三方库

仓输入法的功能的开发离不开这些开源项目：

* [librime](https://github.com/rime/librime) (BSD License)
* [KeyboardKit](https://github.com/KeyboardKit/KeyboardKit.git) (MIT License)
* [Squirrel](https://github.com/rime/squirrel) (GPL-3.0 license)
* [Runestone](https://github.com/simonbs/Runestone.git) (MIT License)
* [TreeSitterLanguages](https://github.com/simonbs/TreeSitterLanguages.git) (MIT License)
* [Vapor](https://github.com/vapor/vapor) (MIT License)
* [Leaf](https://github.com/vapor/leaf) (MIT License)
* [ProgressHUD](https://github.com/relatedcode/ProgressHUD) (MIT License)
* [ZIPFoundation](https://github.com/weichsel/ZIPFoundation) (MIT License)
* [Yams](https://github.com/jpsim/Yams) (MIT License)
* [ZippyJSON](https://github.com/michaeleisel/ZippyJSON)

# 致谢

感谢 TF 版本交流群中的 @一梦浮生，@CZ36P9z9 等等伙伴对测试版本的反馈与帮助，也感谢 @王牌饼干 为输入法制作的工具。

# 捐赠

如果「仓」对您有帮助，可以请我吃份「煎饼馃子」，感激不尽~

<img src="https://ihsiao.com/images/aliPay.jpeg" width="207" height="281" />
<img src="https://ihsiao.com/images/wechatPay.jpeg"  width="207" height="281" />


### AppStore

<a href="https://apps.apple.com/cn/app/%E4%BB%93%E8%BE%93%E5%85%A5%E6%B3%95/id6446617683?itscg=30200&amp;itsct=apps_box_appicon" style="width: 170px; height: 170px; border-radius: 22%; overflow: hidden; display: inline-block; vertical-align: middle;"><img src="https://is4-ssl.mzstatic.com/image/thumb/Purple126/v4/16/b3/b8/16b3b836-12aa-206a-f849-79e37bf6528c/AppIcon-0-1x_U007emarketing-0-10-0-85-220.png/540x540bb.jpg" alt="仓输入法" style="width: 170px; height: 170px; border-radius: 22%; overflow: hidden; display: inline-block; vertical-align: middle;"></a>

<a href="https://apps.apple.com/cn/app/%E4%BB%93%E8%BE%93%E5%85%A5%E6%B3%95/id6446617683?itsct=apps_box_badge&amp;itscg=30200" style="display: inline-block; overflow: hidden; border-radius: 13px; width: 250px; height: 83px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83&amp;releaseDate=1680912000" alt="Download on the App Store" style="border-radius: 13px; width: 250px; height: 83px;"></a>
