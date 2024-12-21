from flask import Flask, request, jsonify, send_from_directory, g
from werkzeug.utils import secure_filename
import psycopg2
from psycopg2.extras import DictCursor
from psycopg2.pool import SimpleConnectionPool
import os
from datetime import datetime
import uuid
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialize Flask
app = Flask(__name__)

# Configuration
DB_CONFIG = {
    'host': os.getenv('DB_HOST'),
    'port': os.getenv('DB_PORT'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'dbname': os.getenv('DB_NAME')
}

# Create connection pool
db_pool = SimpleConnectionPool(
    minconn=5,
    maxconn=20,
    **DB_CONFIG
)

# File storage configuration
UPLOAD_FOLDER = 'audio'
ALLOWED_EXTENSIONS = {'mp3', 'wav', 'ogg', 'm4a'}

# Get connection from pool
@app.before_request
def get_db():
    try:
        if 'db' not in g:
            g.db = db_pool.getconn()
            g.cursor = g.db.cursor(cursor_factory=DictCursor)
    except psycopg2.pool.PoolError:
        return jsonify({'error': 'Server overloaded'}), 503

# Return connection to pool
@app.teardown_appcontext
def close_db(error):
    db = g.pop('db', None)
    cursor = g.pop('cursor', None)
    if cursor is not None:
        cursor.close()
    if db is not None:
        db_pool.putconn(db)

# Create upload folder with subdirectories for better organization
def create_directory_structure():
    # One folder for each month (year/month format)
    base_path = UPLOAD_FOLDER
    os.makedirs(base_path, exist_ok=True)

def get_storage_path():
    # Generate storage path based on current date
    now = datetime.now()
    year_month = now.strftime('%Y/%m')

    # Create upload folder
    full_path = os.path.join(UPLOAD_FOLDER, year_month)
    os.makedirs(full_path, exist_ok=True)

    return year_month

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Initialize the database and create necessary tables
def init_db():
    # Connect to database
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    # Table to store data for audio files
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS audio (
            id SERIAL PRIMARY KEY,
            original_filename VARCHAR(255) NOT NULL,
            storage_filename VARCHAR(255) NOT NULL,
            file_path VARCHAR(255) NOT NULL,
            mime_type VARCHAR(100) NOT NULL,
            file_size BIGINT NOT NULL,
            upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    # Table to store user data
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            firebase_id VARCHAR(255) NOT NULL,
            email VARCHAR(255) NOT NULL,
            username VARCHAR(255) NOT NULL,
            creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    # Table to store composition info
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS compositions (
            id SERIAL PRIMARY KEY,
            info VARCHAR(255),
            author_id VARCHAR(255) NOT NULL,
            creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            modified_date TIMESTAMP NULL
        )
    ''')
    
    conn.commit()
    cursor.close()
    conn.close()

def get_unique_filename(base_filename, directory):
    # Get unique filename by appending numbers if file exists
    filename = base_filename
    counter = 1
    
    while os.path.exists(os.path.join(directory, filename)):
        name, ext = os.path.splitext(base_filename)
        filename = f"{name}_{counter}{ext}"
        counter += 1
        
    return filename

# Upload a new audio file
@app.route('/upload/', methods=['POST'])
def upload_audio():
    # Check if a file was provided
    if 'audio' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['audio']

    # TODO - compress audio for more efficient storage?
    
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    if file and allowed_file(file.filename):
        try:
            # Generate unique filename
            original_filename = secure_filename(file.filename)
            if (original_filename == ''):
                return jsonify({'error': 'Bad filename'}), 400

            file_extension = original_filename.rsplit('.', 1)[1].lower()
            base_storage_filename = f"{uuid.uuid4()}.{file_extension}"
            
            # Get storage path and ensure it exists
            relative_path = get_storage_path()
            full_path = os.path.join(UPLOAD_FOLDER, relative_path)
            os.makedirs(full_path, exist_ok=True)

            # Get unique filename
            storage_filename = get_unique_filename(base_storage_filename, full_path)
            
            # Full path for file storage
            file_full_path = os.path.join(full_path, storage_filename)
            
            # Save file to filesystem
            file.save(file_full_path)
            
            # Get file size
            file_size = os.path.getsize(file_full_path)
            
            # Store metadata in database
            query = '''
                INSERT INTO audio (
                    original_filename, 
                    storage_filename, 
                    file_path, 
                    mime_type, 
                    file_size
                ) VALUES (%s, %s, %s, %s, %s)
                RETURNING id
            '''
            
            g.cursor.execute(query, (
                original_filename,
                storage_filename,
                os.path.join(relative_path, storage_filename),
                file.content_type,
                file_size
            ))
            
            file_id = g.cursor.fetchone()[0]
            g.db.commit()
            
            return jsonify({
                'message': 'File uploaded successfully',
                'file_id': file_id,
                'original_filename': original_filename,
                'file_size': file_size
            }), 201
            
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    
    return jsonify({'error': 'Invalid file type'}), 400

# Returns a specific audio file
@app.route('/audio/<int:file_id>/', methods=['GET'])
def get_audio(file_id):
    try:
        g.cursor.execute('SELECT * FROM audio WHERE id = %s', (file_id,))
        result = g.cursor.fetchone()
        
        if result is None:
            return jsonify({'error': 'File not found'}), 404
        
        # Get directory path from file_path
        directory = os.path.dirname(result['file_path'])
        filename = os.path.basename(result['file_path'])
        
        return send_from_directory(
            os.path.join(UPLOAD_FOLDER, directory),
            filename,
            mimetype=result['mime_type'],
            as_attachment=True,
            download_name=result['original_filename']
        )
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Gets metadata for a specific audio file
@app.route('/audio/<int:file_id>/metadata/', methods=['GET'])
def get_audio_metadata(file_id):
    try:
        g.cursor.execute('SELECT * FROM audio WHERE id = %s', (file_id,))
        result = g.cursor.fetchone()
        
        if result is None:
            return jsonify({'error': 'File not found'}), 404
            
        return jsonify(dict(result))
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/users/', methods=['POST'])
def create_user():
    try:
        data = request.get_json()
        
        # Insert new user
        g.cursor.execute('''
            INSERT INTO users (firebase_id, email, username)
            VALUES (%s, %s, %s)
            RETURNING id
        ''', (data['firebase_id'], data['email'], data['username']))
        
        # Get the new user's id
        new_id = g.cursor.fetchone()[0]

        g.db.commit()
        
        return jsonify({'id': new_id}), 201
        
    except KeyError as e:
        return jsonify({'error': 'Missing required fields: ' + str(e)}), 400
    except psycopg2.Error as e:
        return jsonify({'error': str(e)}), 500

@app.route('/users/<int:user_id>/', methods=['GET'])
def get_user(user_id):
    try:
        g.cursor.execute('''
            SELECT *
            FROM users
            WHERE id = %s
        ''', (user_id,))
        
        user = g.cursor.fetchone()
        
        if user is None:
            return jsonify({'error': 'User not found'}), 404
            
        return jsonify(dict(user)), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
@app.route('/compositions/', methods=['POST'])
def create_composition():
    try:
        data = request.get_json()

        g.cursor.execute('''
            INSERT INTO compositions (info, author_id)
            VALUES (%s, %s)
            RETURNING id
        ''', (data['info'], data['author_id']))
        

        new_id = g.cursor.fetchone()[0]

        g.db.commit()
        
        return jsonify({'id': new_id}), 201
        
    except KeyError as e:
        return jsonify({'error': 'Missing required fields: ' + str(e)}), 400
    except psycopg2.Error as e:
        return jsonify({'error': str(e)}), 500

@app.route('/compositions/<int:composition_id>/', methods=['GET'])
def get_composition(composition_id):
    try:
        g.cursor.execute('''
            SELECT *
            FROM compositions
            WHERE id = %s
        ''', (composition_id,))
        
        composition = g.cursor.fetchone()
        
        if composition is None:
            return jsonify({'error': 'Composition not found'}), 404
            
        return jsonify(dict(composition)), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/compositions/user/<author_id>/', methods=['GET'])
def get_compositions_by_user(author_id):
    try:
        g.cursor.execute('''
            SELECT *
            FROM compositions
            WHERE author_id = %s
        ''', (author_id,))
        
        compositions = g.cursor.fetchall()
        result = [{'id': comp[0], 'info': comp[1], 'author_id': comp[2], 'creation_date': comp[3], 'modified_date': comp[4]} for comp in compositions]
        return jsonify(result), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    create_directory_structure()
    init_db()
    app.run(debug=True)