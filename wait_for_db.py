import os
import sys
import time
import psycopg2
from urllib.parse import urlparse

def wait_for_db(timeout=30):
    """Wait for PostgreSQL to be ready"""
    if not os.environ.get('DATABASE_URL'):
        print("❌ DATABASE_URL not set - cannot wait for DB")
        print(f"   Available env vars: {', '.join(sorted([k for k in os.environ.keys() if 'DATA' in k or 'POST' in k or 'DB' in k]))}")
        return False
    
    db_url = urlparse(os.environ['DATABASE_URL'])
    
    print(f"⏳ Waiting for PostgreSQL at {db_url.hostname}:{db_url.port or 5432}...")
    print(f"   Database: {db_url.path.lstrip('/')}")
    
    start_time = time.time()
    attempts = 0
    while time.time() - start_time < timeout:
        try:
            attempts += 1
            conn = psycopg2.connect(
                host=db_url.hostname,
                port=db_url.port or 5432,
                database=db_url.path.lstrip('/'),
                user=db_url.username,
                password=db_url.password,
            )
            conn.close()
            print(f"✅ PostgreSQL is ready! (after {attempts} attempts)")
            return True
        except psycopg2.OperationalError as e:
            elapsed = int(time.time() - start_time)
            print(f"  Attempt {elapsed}/{timeout}s...", end='\r')
            time.sleep(1)
    
    print(f"❌ PostgreSQL not available after {timeout}s ({attempts} attempts)")
    return False

if __name__ == '__main__':
    success = wait_for_db()
    sys.exit(0 if success else 1)
