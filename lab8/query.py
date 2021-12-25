import time
import os

query = "select ticktime from lab8.userlog \
        where day=1 and speed > 5017134.7473822 \
        or day=2 and speed > 4970450.3094199 \
        or day=3 and speed > 4924722.1762133 \
        or day=4 and speed > 4936335.1814967 \
        or day=5 and speed > 4958179.4026799 \
        or day=6 and speed > 5006338.9443195 \
        or day=7 and speed > 5123739.461791"

start = time.time()

file = open('select_result.txt', 'w')
process = os.popen(f'clickhouse-client --query=\"{query}\"')

file.write(process.read())

print(f'Query finished in {(time.time() - start)*1000} ms')