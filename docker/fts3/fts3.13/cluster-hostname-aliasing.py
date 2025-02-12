import os
import sqlalchemy
from sqlalchemy import create_engine, text

def connect_and_query_mariadb(db_user, db_password, db_host, db_name, output_file="/etc/fts3/host_aliases"):
    """Connects to MariaDB, executes a query, and writes results to a file."""
    db_url = f"mysql+pymysql://{db_user}:{db_password}@{db_host}/{db_name}"
    print("connected")
    engine = create_engine(db_url)
    try:
        with engine.connect() as connection:
            query = text("SELECT DISTINCT transfer_host FROM t_file")
            result = connection.execute(query)
            found_current_host = False

            with open(output_file, "w") as f:  # Open the file *inside* the 'with' block
                for row in result:
                    if row[0] is not None:
                        if row[0] == os.environ['HOSTNAME']:
                            found_current_host = True
                        transfer_host = row[0]  # Access the first element of the tuple
                        f.write(f"{transfer_host} {os.environ['WEB_INTERFACE']}\n")
                 # Add current hostname, if not in result
                if not found_current_host:
                    f.write(f"{os.environ['HOSTNAME']} {os.environ['WEB_INTERFACE']}\n")


            print(f"Transfer hosts written to {output_file}")
            return True  # Indicate success

    except sqlalchemy.exc.OperationalError as e:
        print(f"Database connection error: {e}")
        return False
    except IOError as e:  # Catch potential file writing errors
        print(f"File writing error: {e}")
        return False
    except Exception as e:
        print(f"An error occurred: {e}")
        return False
    finally:
        if engine:
            engine.dispose()


if __name__ == "__main__":
    # Retrieve database credentials from environment variables
    db_user = os.environ.get("MARIADB_USER")
    db_password = os.environ.get("MARIADB_PASSWORD")
    db_host = os.environ.get("MARIADB_CONNECTION_STRING")
    db_name = os.environ.get("FTS3_MARIADB_NAME")

    if not all([db_user, db_password, db_host, db_name]):
        print("Error: Missing required database environment variables.")
    else:
        if connect_and_query_mariadb(db_user, db_password, db_host, db_name):
           exit(0) # Success exit code
        else:
           exit(1) # Failure exit code