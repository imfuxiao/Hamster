# 仓输入法

一款基于「[中州韻輸入法引擎／Rime Input Method Engine](https://github.com/rime/librime)」的iOS版本输入法.

### 诞生缘由

20年机缘下，我学习了小鹤双拼和小鹤音形。但在MacOS上，只有小鹤双拼原生输入法支持，音形则无法使用。为了不影响使用，我尝试使用"Squirrel鼠须管"和"落格输入法"，但在iOS系统上，只能依赖落格输入法。

虽然落格输入法已经十分好用，但需要订阅，而其中大部分功能对我来说都是用不到的。因此，我开始尝试寻找一款免费开源的、类似"Squirrel鼠鬚管"的iOS平台输入法。

在检索了一番之后，我发现了基于RIME的第三方方案"iRIME"，但是它的开源代码基本已经不再更新。因此，我决定自己来动手开发，并在这个过程中学习iOS开发。

开发这个输入法项目并不容易，因为我以前没有在iOS上开发过任何项目。在整个开发过程中，我遇到了很多问题和困惑，但也因此学到了很多新知识和开发技能。

现在这个输入法项目已经基本完成，但我深知这个项目还有很多不足和改进之处。因为我的水平有限，可能并没有完善地考虑一些细节问题，而一些更高级的功能难以实现。但是，我会尽我所能不断优化这个项目，并及时修复大家反馈的问题。当然，也欢迎大家提交PR共同开发这个项目。

总的来说，开发这个输入法项目是一项充实的工作，也让我更加了解了iOS开发。无论最终这个项目能否被广泛使用，这个过程都是一次宝贵的经验。

### 第三方库

仓输入法的功能的完成离不开这些开源项目.

* [librime](https://github.com/rime/librime) (BSD License)
* [Squirrel](https://github.com/rime/squirrel) (GPL-3.0 license)
* [KeyboardKit](https://github.com/KeyboardKit/KeyboardKit.git) (MIT License)
* [SwiftyBeaver](https://github.com/SwiftyBeaver/SwiftyBeaver.git) (MIT License)
* [Runestone](https://github.com/simonbs/Runestone.git) (MIT License)
* [TreeSitterLanguages](https://github.com/simonbs/TreeSitterLanguages.git) (MIT License)
* [🍀️四叶草拼音输入方案](https://github.com/fkxxyz/rime-cloverpinyin)(LGPL-3.0 license)

### AppStore

<a href="https://apps.apple.com/cn/app/%E4%BB%93%E8%BE%93%E5%85%A5%E6%B3%95/id6446617683?itscg=30200&amp;itsct=apps_box_appicon" style="width: 170px; height: 170px; border-radius: 22%; overflow: hidden; display: inline-block; vertical-align: middle;"><img src="https://is4-ssl.mzstatic.com/image/thumb/Purple126/v4/16/b3/b8/16b3b836-12aa-206a-f849-79e37bf6528c/AppIcon-0-1x_U007emarketing-0-10-0-85-220.png/540x540bb.jpg" alt="仓输入法" style="width: 170px; height: 170px; border-radius: 22%; overflow: hidden; display: inline-block; vertical-align: middle;"></a>

<a href="https://apps.apple.com/cn/app/%E4%BB%93%E8%BE%93%E5%85%A5%E6%B3%95/id6446617683?itsct=apps_box_badge&amp;itscg=30200" style="display: inline-block; overflow: hidden; border-radius: 13px; width: 250px; height: 83px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83&amp;releaseDate=1680912000" alt="Download on the App Store" style="border-radius: 13px; width: 250px; height: 83px;"></a>