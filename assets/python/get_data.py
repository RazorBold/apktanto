import pymysql
import sshtunnel
from sshtunnel import SSHTunnelForwarder
import time
from datetime import datetime
import json

def get_data_from_server():
    # Konfigurasi SSH tunnel
    ssh_config = {
        'ssh_address_or_host': ('36.92.168.180', 12193),
        'ssh_username': 'mqtt',
        'ssh_password': 'telkom123',
        'remote_bind_address': ('127.0.0.1', 3306)
    }
    
    # Konfigurasi MySQL
    mysql_config = {
        'user': 'syaiful',
        'password': 'syaiful9g',
        'database': 'apk_tanto',
        'charset': 'utf8mb4',
        'cursorclass': pymysql.cursors.DictCursor
    }
    
    print(f"[{datetime.now()}] Memulai koneksi ke server...")
    
    try:
        with SSHTunnelForwarder(**ssh_config) as tunnel:
            print(f"[{datetime.now()}] SSH tunnel berhasil dibuat")
            
            mysql_config['host'] = '127.0.0.1'
            mysql_config['port'] = tunnel.local_bind_port
            
            print(f"[{datetime.now()}] Mencoba koneksi ke database...")
            connection = pymysql.connect(**mysql_config)
            print(f"[{datetime.now()}] Koneksi database berhasil")
            
            try:
                with connection.cursor() as cursor:
                    sql = """
                    SELECT 
                        no,
                        `container-id`,
                        deveui,
                        `place-antares`,
                        `place-tanto`,
                        battery,
                        `lastactivity-tanto`,
                        status,
                        Action,
                        `last-update-tanto`,
                        `last-update-antares`,
                        `Activity-antares`,
                        Latitude,
                        Longitude,
                        `container-status`
                    FROM database_batch1
                    LIMIT 5
                    """
                    
                    print(f"\n[{datetime.now()}] Mengeksekusi query...")
                    cursor.execute(sql)
                    result = cursor.fetchall()
                    print(f"[{datetime.now()}] Berhasil mengambil {len(result)} baris data")
                    
                    return json.dumps(result)
                    
            finally:
                connection.close()
                print(f"[{datetime.now()}] Koneksi database ditutup")
                
    except Exception as e:
        print(f"[{datetime.now()}] Error: {str(e)}")
        return json.dumps({"error": str(e)})

if __name__ == "__main__":
    print(f"[{datetime.now()}] Program dimulai")
    data = get_data_from_server()
    print(data)
    print(f"[{datetime.now()}] Program selesai")
