from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator, BranchPythonOperator
from airflow.operators.dummy import DummyOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2026, 5, 20),
    'retries': 3,  
    'retry_delay': timedelta(seconds=30),
}

dag = DAG(
    'airflow_retry_dag',
    default_args=default_args,
    description='ветвление',
    schedule_interval='0 * * * *',
    catchup=False,
)


def fail_conn():
    raise ConnectionError(f"Ошибка соединения")


def check_day(**context):
    exec_date = context['execution_date']
    day_num = exec_date.weekday()  
    if day_num >= 5:  
        return 'skip_day'
    else:
        return 'process_data'



task_conn = PythonOperator(
    task_id='connection',
    python_callable=fail_conn,
    retries=3,
    retry_delay=timedelta(seconds=10),
    dag=dag,
)


branch_task = BranchPythonOperator(
    task_id='check_day',
    python_callable=check_day,
    provide_context=True,
    dag=dag,
)

skip_day = DummyOperator(
    task_id='skip',
    dag=dag,
)

process_data = PythonOperator(
    task_id='process_data',
    python_callable=fail_conn,
    dag=dag,
)

end_task = DummyOperator(
    task_id='end',
    dag=dag,
)


branch_task >> [skip_day, process_data]
skip_day >> end_task
process_data >> task_conn >> end_task
