from mysql.connector import connect, Error
import os

try:
    with connect(
        host=os.environ["HOSTNAME_DB"],
        user=os.environ["USER_DB"],
        password=os.environ["PASS_DB"],
    ) as connection:
        print(connection)
except Error as e:
    print(e)
