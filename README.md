# YMutations

DNAChron's Y related database, include mutation info from [ybrowse.org](https://ybrowse.org/). Based on T2T reference.

## README.md

- en [English](README.md)
- zh_CN [简体中文](README.zh_CN.md)

## This project is also hosted at

- [GitHub](https://github.com/dnachron/ymutations)
- [Gitee](https://gitee.com/dnachron/ymutations)

## Why we create this project

To provide a offline, standard, batch process tools for conversion and search on mutation names and positions.

- Download only the delta, don't need to download whole hundreds of megabytes data every time.
- Exceed the max 1048576 row limitation of Excel, can search on all mutation info at one time.
- Using database index, search mutation names and positions efficiently.
- Standardize indel mutation, left alignment, and unify REF and ALT formats.
- Add additional mutation naming date. For mutations with repeated name, the earliest name can be selected according to the naming date.
- Using the database format, you can use program to batch process mutation names and position conversion. Please check the processing tools we provide. [dnachronYdb-putils](https://github.com/dnachron/dnachronYdb-putils)*(github)*  [dnachronYdb-putils](https://gitee.com/dnachron/dnachronYdb-putils)*(gitee)*

## Data sources

Original information from [ybrowse.org](https://ybrowse.org/), processed and standardized by the DNAChron website, and lift over to T2T reference.  
The direct data source is the database used by the DNAChron website. For data standardize and clean, and for website use, a little adjustment is made to the data. See the [difference with ybrowse](#difference-with-ybrowse) section for details

Welcome to visit our website.

- <https://www.dnachron.com> DNAChron International
- <https://www.dnachron.cn> DNAChron China

## Data structure

The data in repo is the raw data we collated in CSV format. You can generate sqlite3 database file through the script provided by us. If you have your own database, you can also import data directly from CSV files into your own database.

## How to download data

You can download the raw [csv file](/ymutation/) directly，or download prebuild database file from [release](../../releases/). The csv file has been splited, each one can be wholy opened by Excel.

We strongly recommend using git for real-time, incremental updates. To use git, please continue to refer to the following instructions:

### Prepare the environment

*ubuntu*

```
sudo apt-get install git sqlite3
```

*windows*

#### 1. Install [git for windows](https://github.com/git-for-windows/git/releases)

It will install git-bash in the same time. All the subsequent commands need to be executed in git-bash.

#### 2. Download windows version [sqlite3](https://www.sqlite.org/download.html)

Please download the sqlite-tools-win32-x86-* file.  
You will find sqlite3.exe after decompression. Set it's path to windows environment variable PATH, or put it to the bin folder in git, default at C:\Program Files\Git\mingw64\bin\

### Clone

*github*

```
git clone https://github.com/dnachron/ymutations.git
```

*gitee*

```
git clone https://gitee.com/dnachron/ymutations.git
```

### Update and build the database

```
cd ./ymutations
./build.sh
```

Each execution will automatically update the data to the latest version and generate the database.

## How to browse database

You can use database management tools to view, search and filter data. Such as [SQLiteStudio](https://sqlitestudio.pl/) [DBeaver](https://dbeaver.io/)

![SQLiteStudio Filter](resources/SQLiteStudio.jpg?raw=true)

## Difference with ybrowse

1. Add naming date.
    - For the mutation named before March 2020, set the naming date to January 1 of the year in the ref or comment. If the year information cannot be found, configure it to 2014-06-01.
    - If you know the specific naming date of the mutation, you are welcome to submit the issue modification.
    - For mutations named after March 2020, they are configured according to the real naming date.
2. Add a list of error mutations, ymutation_error, which is used to store the mutation that fails the verification.
3. Verify the mutation position. Position that are not within the reference will be added to the list of error mutations.
4. Verify the mutation name extension. According to the rules described in [ISOGG WIKI](https://isogg.org/tree/SNPswithExtensions.html), the name ending in .1/.2, indicating that the same mutation is found in different haplogroup, that is, parallel mutation. In ymutations, parallel mutations use the same name without distinction. Mutations in different extensions can cause mutations to appear as L49/L49.1/L49.2, which is redundant. Therefore, all the . extension name are removed from database, and added to the list of error mutations. Preserve mutation name without extension.  
If conflicts are found, try to manually select reasonable results, or select according to the mutation used in the ISOGG tree. If the conflict cannot be resolved, add it to the list of error mutations.
5. If the mutation not in ybrowse but in the ISOGG tree, added it according to the ISOGG tree information.
6. The INDEL mutations are standardized.
    - Refer to the standardized methods used in tools like [GATK](https://gatk.broadinstitute.org/hc/en-us/articles/5358887757979-LeftAlignAndTrimVariants) [bcftools](http://samtools.github.io/bcftools/bcftools.html#norm), left align the mutation, and cut off the redundant shared part.
    - There may be some mutations with different original position, ref and alt, which are found to be the same mutation after standardization.
    - Because the indel mutation description in the original data is not standard, one description may refer to different mutation. We need to check whether the mutation matches the reference sequence to verify the description. If it cannot match to the reference sequence, add it to the list of wrong mutations.
    - For indel mutations contained in the reference sequence itself, reverse check the reference sequence.
    - For MNP and complex, all are added to the error mutation list because can't be verified. We mark MNP and complex as multiple SNPs or INDELs.
7. For program compatibility of DNAChron website, a fake mutation is added: Root, 0, G, C. Just ignore it.
8. All positions are lift over to T2T reference.
9. Include mutations DNAChron named but not synced by Ybrowse. Add column ybrowse_synced to distinguish it.
