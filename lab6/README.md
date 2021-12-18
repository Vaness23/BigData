# Lab 6

Практика по генерации таблиц с данными из csv-файлов с помощью сервисов Hadoop и Hive. Выполняется с помощью *WSL Ubuntu*.

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

В случае успеха Hadoop будет доступен по адресу *localhost:9870*, Hive -- по адресу *localhost: 10002*:

![Hadoop](https://user-images.githubusercontent.com/25685633/146636226-564a2348-8ed9-44d1-ba90-fd9b3854e17b.png)
![Hive](https://user-images.githubusercontent.com/25685633/146636235-22e04236-6062-46cb-aed9-44b31d8da720.png)

## Предварительная настройка БД

Для выполнения работы была использована встроенная СУБД Derby. Выполним подключение к Derby следующей командой:
```
$HIVE_HOME/bin/beeline -n {username} -u jdbc:hive2://localhost:10000
```
{username} -- ваше имя пользователя. Например, для пользователя john_doe команда будет выглядеть следующим образом:
*$HIVE_HOME/bin/beeline -n john_doe -u jdbc:hive2://localhost:10000*

Создаем новую базу данных, например lab6:
```
create database lab6;
```
![databases](https://user-images.githubusercontent.com/25685633/146636348-89ad61e2-8eaa-49ad-a56b-f6f7589fdc99.png)

Используем созданную базу данных с помощью команды:
```
use lab6;
```

Создаем таблицу userlog для будущего хранения данных из csv-файлов с разделениями по UserId и HValue в формате parquet:
```
create table userlog(Day int, TickTime double, Speed double) partitioned by (UserId int, HValue int) stored as parquet;
```
