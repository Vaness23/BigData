#!/bin/bash
files_dir="../lab7"

echo "Creating database..."
clickhouse-client --query="CREATE DATABASE IF NOT EXISTS lab8"
echo "Creating table..."
clickhouse-client --query="CREATE TABLE IF NOT EXISTS lab8.userlog
    (
        day UInt16,
        ticktime Float32,
        speed Float32
    ) ENGINE=MergeTree()
    ORDER BY (day, ticktime, speed)"

echo "Done. Insetring data ..."

for (( day = 1; day <= 7; day++ ))
do
echo "  Inserting from ${files_dir}/day${day}.csv"
clickhouse-client --query="INSERT INTO lab8.userlog FORMAT CSV" < ${files_dir}/day${day}.csv
done
echo "Done"