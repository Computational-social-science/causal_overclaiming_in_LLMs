# LEAN4 工具链安装

本项目使用 **Lean 4.31.0** 和 Lean 自带的 `Int` / `Fin` 核心库，不依赖 Mathlib。
以下步骤已在 macOS arm64 上验证。

## 1. 安装 elan

```bash
brew install elan-init
elan --version
```

`elan-init` 会提供 `elan`、`lean`、`lake` 命令入口。

## 2. 安装 Lean 4.31.0

GitHub 直连限速时，可用上海交大镜像下载 macOS arm64 分发包：

```bash
curl -L -o /tmp/lean-4.31.0-darwin_aarch64.tar.zst \
  "https://s3.jcloud.sjtu.edu.cn/899a892efef34b1b944a19981040f55b-oss01/elan/leanprover/lean4/releases/download/v4.31.0/lean-4.31.0-darwin_aarch64.tar.zst"
```

校验并手动安装到 elan 工具链目录：

```bash
zstd -t /tmp/lean-4.31.0-darwin_aarch64.tar.zst
mkdir -p ~/.elan/toolchains/leanprover--lean4---v4.31.0
tar --strip-components=1 -C ~/.elan/toolchains/leanprover--lean4---v4.31.0 \
  -xf /tmp/lean-4.31.0-darwin_aarch64.tar.zst
elan default leanprover/lean4:v4.31.0
```

若网络可直连 GitHub，也可用：

```bash
elan toolchain install leanprover/lean4:v4.31.0
elan default leanprover/lean4:v4.31.0
```

## 3. 验证形式化工程

```bash
lean --version    # Lean (version 4.31.0)
cd docs/02_theory/formal/
lake build        # 编译 GoldenRule + Witness_GR + Instance + Witness_ModelScale 四个模块
```

`lake build` 不拉取 Mathlib，只需要已安装的 Lean 发行版自带核心库。

## 备注

- elan 工具链目录为 `~/.elan/toolchains/`，每个版本一个子目录。
- 若 `lean --version` 挂起，通常是 elan 在等待下载，检查 `~/.elan/toolchains/*.lock`。
- 证明中的准确率与反思频次统一使用 `Int` 表示“百分数 × 100”，因此不引入浮点误差，也不需要 Mathlib 的有理数层。
