# YMutations

基因志(DNAChron) Y数据库。包含[ybrowse.org](https://ybrowse.org/)的突变信息。基于T2T参考序列。

## README.md

- en [English](README.md)
- zh_CN [简体中文](README.zh_CN.md)

## 该项目同时托管于

- [GitHub](https://github.com/dnachron/ymutations)
- [Gitee](https://gitee.com/dnachron/ymutations)

## 为什么创建该项目

为祖源爱好者们提供一个离线可用的、标准化的、可批量处理的突变名、坐标转换、查询工具

- 实现突变列表文件的增量更新，仅下载少量变化部分。不需每次下载全部几百兆数据。
- 突破Excel最大处理1048576行的限制，可以同时访问全部突变信息。
- 利用数据库索引，高效查询突变名和坐标。
- 规范INDEL突变，左对齐，并统一REF和ALT格式。
- 额外增加突变命名日期。重复命名的突变，可根据命名日期选取最早的命名。
- 使用数据库格式，可利用程序批量处理突变名、坐标互相转换。请查看我们同步提供的处理工具。[dnachronYdb-putils](https://github.com/dnachron/dnachronYdb-putils)*(github)*  [dnachronYdb-putils](https://gitee.com/dnachron/dnachronYdb-putils)*(gitee)*

## 数据来源

原始信息从[ybrowse.org](https://ybrowse.org/)采集，由基因志网站处理、标准化，并转换为T2T参考序列。  
直接数据来源是基因志网站使用的数据库。为了数据标准化、整洁以及为了网站使用，对数据有少许调整，具体见[与ybrowse差异](#与ybrowse差异)。

欢迎访问我们的网站

- <https://www.dnachron.com> 基因志国际站
- <https://www.dnachron.cn> 基因志中国站

## 数据格式

仓库中存储的是我们整理好的csv格式的突变原始数据。可以通过我们提供的脚本生成sqlite3数据库文件。您如果有自己设计的数据库，也可以直接从csv文件导入数据到自己数据库中。

## 如何下载数据

您可以直接下载原始的[csv文件](/ymutation/)，或者从[release](../../releases/)下载生成好的数据库文件。其中csv文件已经做了拆分，单独每个文件均可以用Excel完全打开。

我们强烈建议使用git，以实现实时、增量更新。使用git请继续参考后续说明：

### 环境准备

*ubuntu*

```
sudo apt-get install git sqlite3
```

*windows*

#### 1. 下载安装[git for windows](https://github.com/git-for-windows/git/releases)

会同步安装git-bash。后续命令，均需在git-bash中执行。

#### 2. 下载windows版[sqlite3](https://www.sqlite.org/download.html)

请下载sqlite-tools-win32-x86-*文件。  
解压后，得到sqlite3.exe。把其所在路径加到系统环境变量PATH中，或者直接拷贝到git安装目录下的执行文件目录，一般在C:\Program Files\Git\mingw64\bin\

### 克隆

*github*

```
git clone https://github.com/dnachron/ymutations.git
```

*gitee*

```
git clone https://gitee.com/dnachron/ymutations.git
```

### 更新及生成数据库

```
cd ./ymutations
./build.sh
```

每次执行，会自动更新数据到最新版，并生成数据库。

## 如何浏览数据库

可以使用数据库管理工具查看、搜索、筛选数据。如 [SQLiteStudio](https://sqlitestudio.pl/) [DBeaver](https://dbeaver.io/)

![SQLiteStudio Filter](resources/SQLiteStudio.jpg?raw=true)

## 与ybrowse差异

1. 增加了命名日期。  
    - 对于2020年3月份以前命名的突变，根据ref字段或者comment字段中的年份信息，设置突变的年份为当年的1月1号。如果找不到年份信息，统一按2014-06-01配置。  
    - 如果您知道突变具体的命名日期，欢迎提交issue修改。  
    - 对于2020年3月份以后命名的突变，按照具体命名日期配置。
2. 增加了错误突变列表，ymutation_error，用于存储校验不通过的突变。
3. 校验突变坐标。不在参考系范围内的坐标，会被加入错误突变列表。
4. 校验突变扩展名。按照[ISOGG WIKI](https://isogg.org/tree/SNPswithExtensions.html)的规则，命名中含有类似.1 .2扩展名的突变，表示同一个突变发现在不同分支，也即平行突变。ymutations中，平行突变使用同一个名字，不做区分。不同扩展名突变会导致突变显示为如L49/L49.1/L49.2，冗余。因此去掉了数据库中所有的.扩展名突变，并加入错误突变列表。 保留无扩展名的突变名。
这个过程中，如果发现有冲突，尽量手工选取合理结果，或者按照ISOGG树上使用的突变选取。如果冲突无法解决，加入错误突变列表中。
5. ybrowse中没有，ISOGG树上有的突变，按照ISOGG树信息添加。
6. 对INDEL突变进行了标准化处理。
    - 参考[GATK](https://gatk.broadinstitute.org/hc/en-us/articles/5358887757979-LeftAlignAndTrimVariants) [bcftools](http://samtools.github.io/bcftools/bcftools.html#norm)等工具标准化方式，对突变左对齐,并裁剪掉多余共享部分。
    - 有可能有部分原本坐标、REF、ALT不同的突变，标准化后发现是同一个突变。
    - 因为原始信息中INDEL突变的不标准，同一个描述有可能有多种突变可能。我们需要校验突变是否符合参考序列。如果无法与参考序列对应上，加入到错误突变列表中。
    - 对于参考序列本身包含的INDEL突变，反向校验参考序列。
    - 对于MNP和complex，因为无法校验，加入错误突变列表。我们把MNP和complex标记为多个SNP或INDEL。
7. 为了基因志网站程序兼容性，添加了一个假突变：Root, 0, G, C。忽略即可。
8. 所有坐标均转换为T2T参考序列。
9. 增加了基因志命名，但未被YBrowse收录的突变，并添加ybrowse_synced字段以示区分
