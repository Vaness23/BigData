# Lab 6

Практика по генерации таблиц с данными из csv-файлов с помощью сервисов Hadoop и Hive.

## Предварительная настройка

Необходимо прописать в файле *$HADOOP_HOME/etc/hadoop/mapred-site.xml* следующую конфигурацию:
```
<property>
  <name>mapreduce.jobhistory.address</name>
  <value>localhost:10020</value>
</property>
```
