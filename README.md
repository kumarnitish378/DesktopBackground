# Dynamic Todo Wallpaper

A full-stack solution to keep your goals front and center. This project features a Python/Flask server to manage your tasks and a PowerShell client that dynamically renders them onto your desktop wallpaper.

## Overview

- **Server (`main.py`)**: Flask web app managing tasks in `todos.db`.
- **Client (`webBasedWallPaper.ps1`)**: PowerShell script that fetches tasks and updates the desktop background.
- **Configurable**: Customize colors, fonts, and paths via `config.json`.

## Setup

### 1. Server Setup (Python)
1.  **Install Dependencies**:
    ```bash
    pip install -r requirements.txt
    ```
2.  **Run the Server**:
    ```bash
    python main.py
    ```
    The server starts on `http://localhost:5000`.

### 2. Client Setup (Windows)
1.  **Configuration**:
    Check `config.json`. You can adjust the `apiUrl` if your server is hosted elsewhere, or change `layout` settings to fit your screen.
    ```json
    {
      "apiUrl": "http://localhost:5000/todos",
      "layout": { "fontSize": 48 }
    }
    ```

2.  **Run Manually**:
    Open PowerShell as Administrator and run:
    ```powershell
    .\webBasedWallPaper.ps1
    ```

### 3. Context Menu Integration
To add a "Run WebBasedWallpaper" option to your desktop context menu:
1.  Open `add_run_wallpaper.reg.txt`.
2.  Update the path to match your `webBasedWallPaper.ps1` location.
3.  Rename to `.reg` and run it.

## Development
- **Assets**: Template images are in `assets/`.
- **Testing**: Run unit tests with `python -m unittest discover tests`.
- **Contributing**: See [CONTRIBUTING.md](CONTRIBUTING.md).

## License
MIT License
