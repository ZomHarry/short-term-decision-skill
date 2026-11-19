# 更新日志

本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.1.1] - 2026-11-19

### 变更
- 许可证由 MIT 更换为 **CC BY-NC-SA 4.0**（署名—非商业性使用—相同方式共享）。
- `LICENSE` 附中文摘要与适用范围说明，官方英文法律文本为有效版本。
- `README.md` 许可证章节改为"你可以／但必须"对照表，并给出建议署名格式。
- `SKILL.md` frontmatter 的 `license` 字段同步更新。

### 仓库与发布
- 新增 `.github/workflows/release.yml`：推送 `v*` tag 时自动自检、打包并创建 Release，zip 作为附件发布。
- 新增 `.github/workflows/ci.yml` 与 `scripts/check-repo.ps1`：校验必需文件、`SKILL.md` frontmatter、索引引用与本地链接。
- 新增 `.github/ISSUE_TEMPLATE/`：公式口径纠错与场景建议两个表单，空 Issue 关闭。
- 新增 `CONTRIBUTING.md`：口径差异的处理原则（并列登记而非二选一）与提交前自检命令。
- 新增 `scripts/make-social-preview.py` 与 `docs/assets/social-preview.png`（1280×640）。
- `scripts/build-skill-zip.ps1` 兼容 PowerShell 7 / Linux：仅在 5.1 下加载压缩程序集。

## [1.1.0] - 2026-11-19

### 新增
- `prompts/system-prompt.md`：可直接投喂的完整系统提示词（角色、数据契约、工作协议、输出规范、质量红线、自检）。
- `prompts/few-shot.md`：两个完整示例——特殊订货全流程（七段输出）与信息缺失时的追问示范。
- `prompts/output-template.md`：七段输出模板、填写说明与 8 条自检清单。
- `docs/教材来源与页码对照.md`：每个公式与规则的页码溯源。
- `SKILL.md` frontmatter 增补 `triggers` 关键词（7 条），便于按题型自动命中。
- `SKILL.md` 增设"输出前自检（五问）"与"反模式（五条）"两节。

### 变更
- 目录重构为 GitHub 仓库布局，交付说明与合并版移入 `docs/`。
- 许可证定为 MIT，并在 README 增加第三方素材声明与免责声明。

## [1.0.0] - 2026-11-19

### 新增
- `SKILL.md`：角色定义、适用边界、五步方法路由决策树、六场景公式与判断规则、七段输出格式、行为约束。
- `knowledge/formulas.md`：12 节公式与符号说明，含口径差异清单。
- `knowledge/method-decision-tree.md`：决策树展开为 6 步主路由表、7 出口方法表、7 场景执行表、5 条边界拦截表。
- `knowledge/common-errors.md`：12 条易错点，每条含表现、错因、纠正、依据。
- `tests/test-cases.md`：6 道覆盖全场景的测试题。
