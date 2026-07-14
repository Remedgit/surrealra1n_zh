# surrealra1n 

A12-A13 设备不完美降级工具 + A7-A11 设备降级工具 汉化

支持macOS（A12-A13、A7-A11）与Linux（A7-A11）

surrealra1n discord 官方频道, [surrealra1n](https://discord.gg/kDXVHhTQs2) （请勿在此频道内反应此非官方分支出现的问题）

[原项目地址](https://github.com/pwnerblu/surrealra1n)

iPhoneXR测试通过，可以降级iOS14、15

部分界面汉化不完全（）请谅解

# 支持的设备和版本:

[点击此处查看](https://github.com/pwnerblu/surrealra1n/wiki/Supported-Devices)

# 使用教程:

下载此项目 :
```
git clone -b development https://github.com/Remedgit/surrealra1n_zh && cd surrealra1n_zh
```
运行 ```./surrealra1n.sh```

注：可以通过运行 ```./download_from_mirror.sh```从Github加速站下载依赖文件

# A12设备降级教程

目前仅支持XR

## 1.准备工作

下载本项目、[iOS 14.0 beta4(18A5342E)](https://updates.cdn-apple.com/2020SummerSeed/fullrestores/001-32635/423F68EA-D37F-11EA-BB8E-D1AE39EBB63D/iPhone11,8,iPhone12,1_14.0_18A5342e_Restore.ipsw)固件、最新版本固件(目前最新版本为18.7.9)，以及你想要降级的版本固件

## 2.降级14.0 b4以激活设备

运行./surrealra1n.sh，根据工具内指示，选择最新固件和14.4 beta4固件，降级至iOS14.0 beta4并激活设备

## 3.升级至你想要的版本

运行./surrealra1n.sh，根据工具内指示，选择最新固件和你想要降级的固件，不出意外的话，开机后会提示您已升级到指定版本，即降级成功

# 致谢:

libimobiledevice team, tihmstar, LukeeGD/LukeZGD, xerub, plooshi, etc! (for the tools it has to download)

Mineek - iPhone X restored patcher, used for ipx restores 14.3-15.6.1 (my fork of the patcher is used for seprmvr64 restores on A8+), openra1n, and seprmvr64

Nathan (verygenericname) - SSHRD_Script

pwnerblu - surrealra1n
