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

![empty_userlog](https://user-images.githubusercontent.com/25685633/146636415-1a2540ed-c771-4b13-8496-83f5c19fc3ae.png)

## Копирование данных в директорию Hive

Необходимо предварительно выдать права на чтение файлов с данными. Для этого нужно перейти в папку с данными и выполнить следующие команды:
```
sudo chown vaness {folder_name}
sudo chmod a+rw {folder_name}
sudo chown vaness {folder_name}/*
sudo chmod a+r {folder_name}/*
```

Теперь можно начать копирование csv-файлов в директорию Hive:
```
hdfs dfs -mkdir /user/lab6
hdfs dfs -put /home/{username}/{folder_name}/* /user/lab6
```

## Копирование данных из csv-файлов в БД

Объявляем внешнюю таблицу ext_userlog, которая ссылается на csv-файлы в директории Hive:
```
CREATE EXTERNAL TABLE ext_userlog (Day int, TimeTick double, Speed double) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' LOCATION '/user/lab6';
```

Выполняем предварительную настройку перед копированием данных:
```
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.compress.output=true;
set hive.exec.parallel=true;
set mapred.output.compression.codec=org.apache.hadoop.io.compress.SnappyCodec;
```

Из названия файла формата *userlog.h1.u1.csv* вытащить числовые значения. h1: HValue = 1; u1: UserId = 1. Для этого можно испольовать функцию *split* разбиения на подстроки по символу. Тогда имя файла будет разбиваться по символу "." (точка). Чтобы разбить имя файла, необходимо предварительно его вытащить из пути к файлу. Для этого путь к файлу сначала разбивается по символу "/". В итоге получается следующая команда для UserId:
```
cast(substr(split(split(INPUT__FILE__NAME, "/")[5], "[.]")[2], 2) as int) as userid
```

И следующая команда для HValue:
```
cast(substr(split(split(INPUT__FILE__NAME, "/")[5], "[.]")[1], 2) as int) as hvalue
```

Чтобы не ждать несколько десятков минут, пока скопируются все данные, выполним предварительное копирование 5 строчек данных. Ограничим кол-во данных с помощью команды *limit 5*. Тогда запрос будет выглядеть следующим образом:
```
insert overwrite table userlog
partition (userid, hvalue)
select *,
    cast(substr(split(split(INPUT__FILE__NAME, "/")[5], "[.]")[2], 2) as int) as userid,
    cast(substr(split(split(INPUT__FILE__NAME, "/")[5], "[.]")[1], 2) as int) as hvalue
from ext_userlog
limit 5;
```

В случае успеха в таблице userlog будут доступны следующие данные:
![userlog_5_rows](https://user-images.githubusercontent.com/25685633/146636793-0528129b-a28e-4104-ad40-ba497d64a1a0.png)

Для копирования всех данных из csv-файлов не обходимо убрать лимит на строки. Получится следующее:
```
insert overwrite table userlog
partition (userid, hvalue)
select *,
    cast(substr(split(split(INPUT__FILE__NAME, "/")[5], "[.]")[2], 2) as int) as userid,
    cast(substr(split(split(INPUT__FILE__NAME, "/")[5], "[.]")[1], 2) as int) as hvalue
from ext_userlog;
```

После выполнения команды можно оценить размер получившейся таблицы с помощью команды:
```
hdfs dfs -du -s -h /user/hive/warehouse/lab6.db/userlog
```

В моем случае получился вывод:
```
1.7 G  1.7 G  /user/hive/warehouse/lab6.db/userlog
```

То есть, таблица занимает 1,7 Гб дискового пространства. При том, что исходные csv-файлы занимали 4,3 Гб. Таким образом, мы оптимизировали хранение данных примерно в 2,5 раза.

Оценить объем данных можно так же в веб-интерфейсе Hadoop с помощью utilities --> browse the file system.
![users](https://user-images.githubusercontent.com/25685633/146636869-9a4e0317-cefc-4e24-b73b-08677642d477.png)
![values](https://user-images.githubusercontent.com/25685633/146636875-39980176-598c-4317-8fa2-be51ffb14d40.png)
Видим, что разбиение на users и hvalues прошло успешно.

Вот, к примеру, сколько весит пул данных по 1 юзеру и 1 hvalue -- 21,36 Мб:
![image](https://user-images.githubusercontent.com/25685633/146636907-68025616-b458-43af-9906-64fc3c9c1c02.png)
