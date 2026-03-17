# 配置提供者

## 功能介绍

该库负责提供罗布乐思相关配置,包括:

1. 限定配置目录为  `./config`
2. 音效资源配置定义
3. configmanager代码


## 安装
`npm install wdm.config-provider`
   
## 使用

安装后, 本库将自动在 `package.json` 的脚本中,添加如下指令:

```
"scripts": {
    "config:build": "config_build",
    "config:watch": "config_code_build",
  },
```

它们的含义如下:

* `config:build` - 生成配置
* `config:watch` - 监听配置文件变化,并生成配置


配置生成目录为 `./_genConfigs`
