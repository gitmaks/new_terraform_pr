FROM python:3
WORKDIR /usr/scripts/
ADD db_check2.py ./
RUN pip install mysql.connector && python3 -m pip install mysql-connector
CMD python ./db_check2.py
