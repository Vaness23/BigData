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

## Запуск Hadoop и Hive

Запускаем сервисы Hadoop с помощью следующей команды:
```
$HADOOP_HOME/sbin/start-all.sh
```

При возникновении ошибки *localhost: ssh: connect to host localhost port 22: Connection refused*
необходимо перезапустить *ssh* с помощью команды:
```
sudo service ssh restart
```
После чего повторить команду запуска Hadoop.

Проверить успешность запуска сервисов можно с помощью команды *jps*. В случае успеха в выводе консоли отобразятся 6 запущенных процессов:
```
2226 Jps
514 ResourceManager
1595 SecondaryNameNode
1292 DataNode
1102 NameNode
1998 NodeManager
```

Теперь запускаем сервисы Hive с помощью выполнения двух последовательных команд:
```
$HIVE_HOME/bin/hive --service metastore &
$HIVE_HOME/bin/hive --service hiveserver2 &
```
