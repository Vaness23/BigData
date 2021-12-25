# Lab 9

## Отдельный пользователь для Kafka

Создаем отдельного пользователя для Apache Kafka:
```
sudo useradd kafka -m
```

Зададим ему пароль:
```
sudo passwd kafka
```

Добавляем созданного пользователя в группу sudo:
```
sudo adduser kafka sudo
```

Переключимся на созданного пользователя:
```
su - kafka
```

## Установка Java JDK

Устанавливаем вспомогательное ПО:
```
sudo apt-get install software-properties-common
```

Добавляем репозиторий webupd8team в ОС:
```
sudo add-apt-repository ppa:webupd8team/java
```

Обновляем apt-get:
```
sudo apt-get update
```

Установка Oracle Java 9:
```
sudo apt-get install oracle-java9-installer
```

## Установка ZooKeeper

Обновляем данные в репозиториях:
```
sudo apt-get update -y
```

Установка ZooKeeper из репозитория:
```
sudo apt-get install zookeeperd -y
```

Открываем конфигурационный файл Zookeeper:
```
sudo nano /etc/zookeeper/conf/zoo.cfg
```

Меняем настройки конфигурационного файла на следующие:
```
tickTime=2000
initLimit=5
syncLimit=2
dataDir=/home/zookeeper/data
clientPort=2181
```

В папке home создаем папки zookeeper и data:
```
cd /home
sudo mkdir zookeeper
cd zookeeper
sudo mkdir data
```

Запускаем сервер:
```
sudo /usr/share/zookeeper/bin/zkServer.sh start
```

Вывод консоли:
```
ZooKeeper JMX enabled by default
Using config: /etc/zookeeper/conf/zoo.cfg
Starting zookeeper ... STARTED
```

Проверяем статус сервера:
```
/usr/share/zookeeper/bin/zkServer.sh status
```

Вывод консоли:
```
ZooKeeper JMX enabled by default
Using config: /etc/zookeeper/conf/zoo.cfg
Mode: standalone
```

Запускаем еще один сервис:
```
sudo /usr/share/zookeeper/bin/zkCli.sh
```

Вывод консоли:
```
Connecting to localhost:2181
Welcome to ZooKeeper!
JLine support is enabled

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
[zk: localhost:2181(CONNECTED) 0]
```

Проверяем работу ZooKeeper в другом консольном окне:
```
echo ruok | nc 127.0.0.1 2181
```

Вывод консоли:
```
imok
```

Проверим еще одним способом:
```
telnet localhost 2181
```

Вывод консоли:
```
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
```

Продолжаем проверку:
```
ruok
```

Вывод консоли:
```
imok
```

Установка ZooKeeper завершена.

## Установка Kafka

Переходим в папку src:
```
cd /usr/local/src
```

Загружаем последнню версию Kafka:
```
sudo wget "https://dlcdn.apache.org/kafka/3.0.0/kafka_2.13-3.0.0.tgz"
```

Распаковываем архив:
```
sudo tar xvfz kafka_2.13-3.0.0.tgz -C /usr/local/
```

Переименуем папку для удобства использования:
```
sudo mv kafka_2.13-3.0.0 kafka
```

Открываем конфигурационный файл для редактирования:
```
sudo nano /usr/local/kafka/config/server.properties
```

Добавляем строки в файл:
```
delete.topic.enable = true
port = 9092
advertised.host.name = localhost 
```

Запускаем Kafka в режиме nohup:
```
sudo nohup /usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties
```

Отправляем тестовое сообщение "Hello, man" в нового продюсера Kafka с топиком TutorialTopic:

```
echo "Hello, world" | /usr/local/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic TutorialTopic > /dev/null
```

Посмотрим опубликованное сообщение:
```
/usr/local/kafka/bin/kafka-console-consumer.sh --topic TutorialTopic --from-beginning --bootstrap-server localhost:9092
```

Вывод:
```
Hello, world
```

Kafka работает успешно.

## Установка KafkaT

Устанавливаем Ruby:
```
sudo apt-get install ruby ruby-dev build-essential -y
```

Устанавливаем KafkaT:
```
gem install kafkat --source https://rubygems.org --no-ri --no-rdoc
```

Создаем конфигурационный файл:
```
sudo nano ~/.kafkatcfg
```

Пропишем в файл следующее:
```
{
"kafka_path": "/usr/local/kafka",
"log_path": "/tmp/kafka-logs",
"zk_path": "localhost:2181"
}
```

Посмотрим разделы Kafka с помощью команды:
```
kafkat partitions
```

Видим следующий результат:
```
Topic           Partition       Leader          Replicas        ISRs
TutorialTopic   0               0               [0]             [0]
```

На это установка Kafka и ее пререквизитов завершена.