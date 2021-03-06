# HDFS EOS script

In order to use the EOS HDFS data to generate data popularity data, we create an intermediate data source in parquet format. This script generates that intermediate dataset and allow us to query it to generate the report by application/dataset and by file/dataset. 

## How to run it

You can run any command with the --help option to get a description of subcomands/parameters. 

### To append a new day to the data source:

We can run the update command to add one specific date:

```bash
 bin/run_hdfs_eos.sh run_update "2019/09/19"
```

or we can use glob expressions to add more than one day at the time: 

```bash
bin/run_hdfs_eos.sh run_update "2019/09/1[0-9]"
```

If there are some changes in the data for a given date, we can override the partition: 

```bash
bin/run_hdfs_eos.sh run_update --mode overwrite "2019/09/1[0-9]"
```

### To create a report for a given period

Image and summary of totals by dataset:

```bash
bin/run_hdfs_eos.sh run_report_totals 20180101 20190101
```

This will create two files:

- `dataset_totals.csv`:  CSV file with the totals for the given period. [d_dataset, application, nevents, total_rb, total_wb, total_rt, total_wt, data_tier]
- `top_total_rb_<start>_<end>.png`: png image with the top 10 datasets by read bytes. 

Summary by file by day:

```bash
bin/run_hdfs_eos.sh get_filenames_per_day 20190101 20190103
```

- This will create a full report at filename/day granularity, it should only be use with short periods as it will result in a big file. [d_dataset, file_lfn,application, nevents, total_rb, total_wb, total_rt, total_wt, data_tier]

## Defaults

The default location for the parquet intermediate file will be: `hdfs:///cms/eos/full.parquet` and the default mode will be append, so it can add new partitions to the existing data without affecting it.

 *The override mode will use dynamic override mode*, affecting only the matched partitions. 

## Intermediate dataset

The generated intermediate parquet dataset will be partitioned by day and will have the following fields:

```reStructuredText
 |-- raw: string (nullable = true)
 |-- timestamp: long (nullable = true)
 |-- rb_max: long (nullable = true)
 |-- session: string (nullable = true)
 |-- file_lfn: string (nullable = true)
 |-- application: string (nullable = true)
 |-- rt: long (nullable = true)
 |-- wt: long (nullable = true)
 |-- rb: long (nullable = true)
 |-- wb: long (nullable = true)
 |-- cts: long (nullable = true)
 |-- csize: long (nullable = true)
 |-- user: string (nullable = true)
 |-- user_dn: string (nullable = true)
 |-- day: integer (nullable = true)
```



## Requirements

This script uses EOS reports data from the ``analytix` cluster. They should be available at `hdfs:///project/monitoring/archive/eos/logs/reports/cms`

### How to run the script without LCG release environment

This instructions are not necessary in a lxplus-like environment.

All python packages are already available at the [LCG release]( http://lcginfo.cern.ch/release/96python3/ ). If you want to run it without an LCG environment, you will need this python 3 and this packages:

- pandas
- pyspark (2.4.x)
- matplotlib
- seaborn
- click

And you will need to setup the [environment for hadoop]( https://cern.service-now.com/service-portal/article.do?n=KB0004426 ). 

