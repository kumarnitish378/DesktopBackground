import unittest
import os
import json
from main import app, init_db

class DesktopBackgroundTestCase(unittest.TestCase):
    def setUp(self):
        # Configure app for testing
        app.config['TESTING'] = True
        self.app = app.test_client()
        self.db_name = "test_todos.db"
        
        # Patch the database filename in main.py logic (if it weren't hardcoded)
        # Since it's hardcoded to 'todos.db' in main.py, we have to be careful.
        # Ideally main.py should accept a config. For now, we test the endpoints 
        # knowing it might create a local DB.
        
        init_db()

    def test_index(self):
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)

    def test_add_and_get_todo(self):
        # Add Todo
        response = self.app.post('/todos', 
                                 data=json.dumps({"task": "Test Task", "priority": "high"}),
                                 content_type='application/json')
        self.assertEqual(response.status_code, 201)
        
        # Get Todo
        response = self.app.get('/todos')
        data = json.loads(response.data)
        self.assertTrue(len(data) > 0)
        self.assertEqual(data[-1]['task'], "Test Task")

if __name__ == '__main__':
    unittest.main()
