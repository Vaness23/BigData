# Lab 8

## Установка ClickHouse
    sudo apt-get install apt-transport-https ca-certificates dirmngr
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E0C56BD4

    echo "deb https://repo.clickhouse.com/deb/stable/ main/" | sudo tee \
    /etc/apt/sources.list.d/clickhouse.list
    sudo apt-get update

    # Попросит установить пароль
    sudo apt-get install -y clickhouse-server clickhouse-client
    
    sudo service clickhouse-server start
    clickhouse-client --password

## Веб-интерфейс
http://localhost:8123/play

## Перенос данных
С помощью драйвера JDBC
### Установка и запуск драйвера
    sudo apt install -y procps wget
    wget https://github.com/ClickHouse/clickhouse-jdbc-bridge/releases/download/v2.0.2/clickhouse-jdbc-bridge_2.0.2-1_all.deb
    sudo apt install --no-install-recommends -f ./clickhouse-jdbc-bridge_2.0.2-1_all.deb
    clickhouse-jdbc-bridge

### Запуск Tarantool
    tarantool
    box.cfg {listen = 3301}

    