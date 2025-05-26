# dcm-sort-anon Docker Container

A Docker container for the dcm-sort-anon DICOM sorting and anonymization tool.

## Overview

This Docker container provides a ready-to-use environment for running dcm-sort-anon, which sorts and anonymizes DICOM files. The tool organizes DICOM files by series and removes patient identifying information.

## Features

- Built on Ubuntu 22.04
- Pre-installed Python dependencies (pydicom, gdcm, numpy)
- Ready-to-use dcm-sort-anon script
- Containerized environment for consistent execution
- Non-root user execution for security
- Automatic data organization with original data preservation

## Building the Container

```bash
docker build -t kytk/dcm-sort-anon:latest .
```

**Note**: This container is built for x86_64 (Intel/AMD) architecture. If you're using Apple Silicon Mac, you'll need to specify the platform when running (see usage section below).

## Usage

### Basic Usage

To see the help message:
```bash
docker run --rm --platform linux/amd64 kytk/dcm-sort-anon:latest
```

### Processing DICOM Files

#### Method 1: Recommended (with proper user permissions)
```bash
docker run --rm --platform linux/amd64 --user $(id -u):$(id -g) \
  -v ${PWD}:/data \
  kytk/dcm-sort-anon:latest patient1
```

#### Method 2: Simple (may create files as root)
```bash
docker run --rm --platform linux/amd64 \
  -v /path/to/your/dicom/data:/data \
  kytk/dcm-sort-anon:latest patient1
```

### Setting up an Alias for Easy Use

Add this to your `~/.bashrc` or `~/.zshrc`:
```bash
alias dcm-sort-anon='docker run --rm --platform linux/amd64 --user $(id -u):$(id -g) -v ${PWD}:/data kytk/dcm-sort-anon:latest'
```

After setting up the alias, you can use it simply:
```bash
dcm-sort-anon patient1
dcm-sort-anon patient1 patient2 patient3
```

### Example with Multiple Directories

```bash
# Using the recommended method
docker run --rm --platform linux/amd64 --user $(id -u):$(id -g) \
  -v ${PWD}:/data \
  kytk/dcm-sort-anon:latest patient1 patient2 patient3

# Or with alias
dcm-sort-anon patient1 patient2 patient3
```

## Directory Structure

### Before Running

Your data directory should contain patient directories:

```
/your/dicom/data/
├── patient1/
│   ├── file1.dcm
│   ├── file2.dcm
│   └── ...
├── patient2/
│   ├── file1.dcm
│   ├── file2.dcm
│   └── ...
└── patient3/
    ├── file1.dcm
    └── file2.dcm
```

### After Running

The container automatically organizes your data:

```
/your/dicom/data/
├── original/              # Original data moved here
│   ├── patient1/
│   │   ├── file1.dcm
│   │   └── file2.dcm
│   └── patient2/
│       ├── file1.dcm
│       └── file2.dcm
└── anonymized_sorted/     # Processed data created here
    ├── patient1/
    │   ├── 01_Series1/
    │   │   ├── file1.dcm
    │   │   └── file2.dcm
    │   └── 02_Series2/
    │       └── file3.dcm
    └── patient2/
        └── 01_Series1/
            ├── file1.dcm
            └── file2.dcm
```

## What the Container Does

1. **Automatic Organization**: 
   - Creates an `original/` directory and moves your patient directories there
   - Runs dcm-sort-anon from the `original/` directory
   - Creates `anonymized_sorted/` directory with processed files

2. **Anonymization**: 
   - Sets PatientName and PatientID to the directory name
   - Removes PatientBirthDate
   - Keeps other DICOM metadata intact

3. **Sorting**: 
   - Organizes files by series (SeriesNumber_SeriesDescription)
   - Creates numbered directories for each series
   - Maintains original file names

4. **Filtering**: 
   - Only processes DICOM files with imaging data
   - Skips non-imaging DICOM files

## Logging

The tool generates a log file `dcm-sort-anon.log` in the `original/` directory. Since the data directory is mounted, you can access the log file directly from your host system at `/your/data/original/dcm-sort-anon.log`.

## Requirements

- Docker
- DICOM data organized in patient directories
- Sufficient disk space for both original and processed data (approximately 2x the original data size)

## Notes

- The container automatically moves your original data to `original/` subdirectory for safety
- **Recommended**: Use `--user $(id -u):$(id -g)` to avoid permission issues with created files
- Use `${PWD}` to work with the current directory
- Set up an alias for convenient usage
- The PatientID is derived from the directory name
- Only imaging DICOM files are processed (files with pixel_array)
- Both original and processed data remain accessible after processing

## Platform Support

This container is built for x86_64 (Intel/AMD) architecture. It works on:
- **Intel/AMD Linux systems**: Native performance
- **Apple Silicon Mac**: Works with `--platform linux/amd64` flag (uses emulation)
- **Intel Mac**: Native performance

**Important for Apple Silicon users**: Always include `--platform linux/amd64` in your docker run commands or in your alias setup.

## License

This Docker container uses the dcm-sort-anon tool, which is licensed under the MIT License.

---

# dcm-sort-anon Docker コンテナ

DICOM分類・匿名化ツール dcm-sort-anon 用のDockerコンテナです。

## 概要

このDockerコンテナは、DICOMファイルの分類と匿名化を行うdcm-sort-anonツールをすぐに使用できる環境を提供します。DICOMファイルをシリーズごとに整理し、患者識別情報を削除します。

## 特徴

- Ubuntu 22.04ベース
- Python依存関係（pydicom, gdcm, numpy）がプリインストール済み
- dcm-sort-anonスクリプトが使用可能
- 一貫した実行環境を提供するコンテナ化
- セキュリティのための非rootユーザー実行
- オリジナルデータ保護機能付きの自動データ整理

## コンテナのビルド

```bash
docker build -t kytk/dcm-sort-anon:latest .
```

**注意**: このコンテナはx86_64（Intel/AMD）アーキテクチャ用にビルドされています。Apple Silicon Macをお使いの場合は、実行時にプラットフォームを指定する必要があります（使用方法の項目を参照）。

## 使用方法

### 基本的な使用方法

ヘルプメッセージを表示：
```bash
docker run --rm --platform linux/amd64 kytk/dcm-sort-anon:latest
```

### DICOMファイルの処理

#### 方法1: 推奨 (適切なユーザー権限で実行)
```bash
docker run --rm --platform linux/amd64 --user $(id -u):$(id -g) \
  -v ${PWD}:/data \
  kytk/dcm-sort-anon:latest patient1
```

#### 方法2: シンプル (rootでファイルが作成される可能性)
```bash
docker run --rm --platform linux/amd64 \
  -v /path/to/your/dicom/data:/data \
  kytk/dcm-sort-anon:latest patient1
```

### 簡単に使うためのエイリアス設定

`~/.bashrc` または `~/.zshrc` に以下を追加：
```bash
alias dcm-sort-anon='docker run --rm --platform linux/amd64 --user $(id -u):$(id -g) -v ${PWD}:/data kytk/dcm-sort-anon:latest'
```

エイリアス設定後はシンプルに使用できます：
```bash
dcm-sort-anon patient1
dcm-sort-anon patient1 patient2 patient3
```

### 複数ディレクトリの例

```bash
# 推奨方法を使用
docker run --rm --platform linux/amd64 --user $(id -u):$(id -g) \
  -v ${PWD}:/data \
  kytk/dcm-sort-anon:latest patient1 patient2 patient3

# エイリアスを使用
dcm-sort-anon patient1 patient2 patient3
```

## ディレクトリ構造

### 実行前

データディレクトリには患者ディレクトリが含まれている必要があります：

```
/your/dicom/data/
├── patient1/
│   ├── file1.dcm
│   ├── file2.dcm
│   └── ...
├── patient2/
│   ├── file1.dcm
│   ├── file2.dcm
│   └── ...
└── patient3/
    ├── file1.dcm
    └── file2.dcm
```

### 実行後

コンテナが自動的にデータを整理します：

```
/your/dicom/data/
├── original/              # オリジナルデータがここに移動
│   ├── patient1/
│   │   ├── file1.dcm
│   │   └── file2.dcm
│   └── patient2/
│       ├── file1.dcm
│       └── file2.dcm
└── anonymized_sorted/     # 処理済みデータがここに作成
    ├── patient1/
    │   ├── 01_Series1/
    │   │   ├── file1.dcm
    │   │   └── file2.dcm
    │   └── 02_Series2/
    │       └── file3.dcm
    └── patient2/
        └── 01_Series1/
            ├── file1.dcm
            └── file2.dcm
```

## コンテナの動作

1. **自動整理**: 
   - `original/` ディレクトリを作成し、患者ディレクトリをそこに移動
   - `original/` ディレクトリからdcm-sort-anonを実行
   - 処理済みファイルで `anonymized_sorted/` ディレクトリを作成

2. **匿名化**: 
   - PatientNameとPatientIDをディレクトリ名に設定
   - PatientBirthDateを削除
   - その他のDICOMメタデータは保持

3. **分類**: 
   - シリーズごとにファイルを整理（SeriesNumber_SeriesDescription）
   - 各シリーズに番号付きディレクトリを作成
   - 元のファイル名を維持

4. **フィルタリング**: 
   - 画像データを含むDICOMファイルのみを処理
   - 非画像DICOMファイルはスキップ

## ログ出力

ツールは `original/` ディレクトリに `dcm-sort-anon.log` ログファイルを生成します。データディレクトリがマウントされているため、ホストシステムから `/your/data/original/dcm-sort-anon.log` で直接ログファイルにアクセスできます。

## 必要条件

- Docker
- 患者ディレクトリに整理されたDICOMデータ
- オリジナルと処理済みデータ両方のための十分なディスク容量（元データの約2倍）

## 注意事項

- コンテナは安全のためにオリジナルデータを自動的に `original/` サブディレクトリに移動します
- **推奨**: 作成されるファイルの権限問題を避けるため `--user $(id -u):$(id -g)` を使用してください
- 現在のディレクトリで作業するには `${PWD}` を使用してください
- 便利な使用のためにエイリアスを設定してください
- PatientIDはディレクトリ名から取得されます
- 画像DICOMファイル（pixel_arrayを持つファイル）のみが処理されます
- 処理後もオリジナルと処理済みデータ両方にアクセス可能です

## プラットフォームサポート

このコンテナはx86_64（Intel/AMD）アーキテクチャ用にビルドされています。以下の環境で動作します：
- **Intel/AMD Linuxシステム**: ネイティブパフォーマンス
- **Apple Silicon Mac**: `--platform linux/amd64` フラグ付きで動作（エミュレーション使用）
- **Intel Mac**: ネイティブパフォーマンス

**Apple Siliconユーザーへの重要な注意**: docker runコマンドやエイリアス設定では、必ず `--platform linux/amd64` を含めてください。

## ライセンス

このDockerコンテナは、MITライセンスの下でライセンスされているdcm-sort-anonツールを使用しています。

