# Dynamic Todo Wallpaper

A full-stack solution to keep your goals front and center. This project features a Python/Flask server to manage your tasks and a PowerShell client that dynamically renders them onto your desktop wallpaper.

## Overview

There are two main components:
1.  **Server (`main.py`)**: A Flask web application that manages a TODO list in a generic SQLite database and serves the base wallpaper image.
2.  **Client (`webBasedWallPaper.ps1`)**: A PowerShell script that fetches the TODO list from the server, draws the text onto a template image using .NET graphics libraries, and sets it as the active Windows desktop background.

## Features
- **Centralized Task Management**: Add/Remove tasks via a web interface.
- **Dynamic Rendering**: Wallpaper updates automatically with your current tasks.
- **Visual Priorities**: High-priority tasks are highlighted in red.
- **Context Menu Integration**: Optional registry script to refresh the wallpaper on-demand from the desktop context menu.

## Setup

### 1. Server Setup (Python)
If you want to host your own server (or run it locally):

1.  **Install Dependencies**:
    ```bash
    pip install flask flask-cors
    ```
2.  **Run the Server**:
    ```bash
    python main.py
    ```
    The server will start on `http://localhost:5000`.

### 2. Client Setup (Windows)

1.  **Configure the Script**:
    Open `webBasedWallPaper.ps1` and update the `$todoList` URI to point to your server:
    ```powershell
    $todoList = Invoke-RestMethod -Uri "http://localhost:5000/todos" # or your hosted URL
    ```

2.  **Run Manually**:
    Open PowerShell as Administrator and run:
    ```powershell
    .\webBasedWallPaper.ps1
    ```

### 3. Optional: Context Menu Integration
You can add a "Run WebBasedWallpaper" option to your desktop right-click menu.

1.  Open `add_run_wallpaper.reg.txt`.
2.  **CRITICAL**: Edit the path in the file to match the actual location of your `webBasedWallPaper.ps1` script.
    ```text
    "C:\\Users\\YourName\\Path\\To\\webBasedWallPaper.ps1"
    ```
    *Note: Use double backslashes (`\\`) for paths in .reg files.*
3.  Rename the file from `.txt` to `.reg`.
4.  Double-click the `.reg` file to import it into the Windows Registry.

## File Structure
- `main.py`: Flask server entry point.
- `webBasedWallPaper.ps1`: Core client script for image manipulation and wallpaper setting.
- `templates/`: HTML templates for the web UI.
- `todos.db`: SQLite database (auto-generated).
- `add_run_wallpaper.reg.txt`: Template for registry integration.

## License
MIT License - Free to use and modify.
