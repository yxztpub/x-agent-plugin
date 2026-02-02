# x-agent-plugin

## 🚀 快速安装

### 方法一：本地安装(推荐 适用于X线不同项目之间定开)
```bash
git clone https://git.zhonganinfo.com/za-wangjiahao/x-agent-plugin.git
/plugin marketplace add ~/x-agent-plugin
/plugin install x-agent-plugin@x-agent-plugin
```

### 方法二：从市场安装
```bash
/plugin marketplace add https://git.zhonganinfo.com/za-wangjiahao/x-agent-plugin.git
/plugin install x-agent-plugin@x-agent-plugin
```
# 使用方法
1. /x-agent-plugin:code-plan	根据开发任务生成计划
2. /x-agent-plugin:write-plan	写入计划到指定文件夹

# 常见问题
1. 当插件更新后新功能/优化不生效时需主动清除插件缓存
   rm -rf ~/.claude/plugins/cache/
2. 已知有问题的claude版本
   2.1.12 Error: Failed to clone marketplace repository: HTTPS authentication failed.
   2.1.23 "error": {"message": "invalid beta flag"}
3. 开发者使用版本 2.1.22
