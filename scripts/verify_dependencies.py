#!/usr/bin/env python3
# ----------------------------------------------------------------------------
# File: verify_dependencies.py
# Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/scripts/
#
# Purpose: Verify Python dependencies and fix import issues
# Security Level: Confidential
# Owner: Infrastructure Team
# Version: 1.0
# Last Modified: 2025-02-08
# ----------------------------------------------------------------------------

import sys
import subprocess
from pathlib import Path
from typing import List, Dict, Any, Optional

def check_dependency(name: str) -> bool:
    """Check if a Python package is installed."""
    try:
        __import__(name)
        return True
    except ImportError:
        return False

def install_dependency(name: str) -> bool:
    """Install a Python package using pip."""
    try:
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', name])
        return True
    except subprocess.CalledProcessError:
        return False

def verify_dependencies() -> Dict[str, bool]:
    """Verify all required dependencies are installed."""
    dependencies = {
        'loguru': 'loguru',
        'pydantic': 'pydantic>=2.0.0',
        'pydantic-settings': 'pydantic-settings>=2.0.0',
        'aioredis': 'aioredis>=2.0.0',
        'pinecone-client': 'pinecone-client>=2.2.0',
        'cassandra-driver': 'cassandra-driver>=3.28.0',
        'asyncpg': 'asyncpg>=0.28.0',
        'numpy': 'numpy>=1.24.0',
        'scikit-learn': 'scikit-learn>=1.3.0',
        'faiss-cpu': 'faiss-cpu>=1.7.0',
        'torch': 'torch>=2.0.0',
        'transformers': 'transformers>=4.30.0',
        'sentence-transformers': 'sentence-transformers>=2.2.0'
    }

    results: Dict[str, bool] = {}
    for name, spec in dependencies.items():
        if not check_dependency(name):
            print(f"Installing {name}...")
            success = install_dependency(spec)
            results[name] = success
        else:
            results[name] = True

    return results

def fix_import_statements() -> None:
    """Fix import statements in Python files."""
    project_root = Path('/Volumes/mattstack/VSCode/AeonNovaFutureLabs')
    
    # Add __init__.py files where needed
    for path in project_root.rglob('**/'):
        if path.is_dir() and not path.name.startswith('.'):
            init_file = path / '__init__.py'
            if not init_file.exists():
                init_file.touch()

    # Update import statements in files
    for py_file in project_root.rglob('*.py'):
        if py_file.name == '__init__.py':
            continue

        content = py_file.read_text()
        
        # Add typing imports if needed
        if 'List' in content and 'from typing import List' not in content:
            content = 'from typing import List\n' + content
        
        # Add logger import if needed
        if 'logger' in content and 'from loguru import logger' not in content:
            content = 'from loguru import logger\n' + content

        # Add time import if needed
        if 'time.' in content and 'import time' not in content:
            content = 'import time\n' + content

        py_file.write_text(content)

def main() -> None:
    """Main entry point."""
    print("Verifying Python dependencies...")
    results = verify_dependencies()
    
    failed = [name for name, success in results.items() if not success]
    if failed:
        print(f"\nFailed to install: {', '.join(failed)}")
        sys.exit(1)
    
    print("\nAll dependencies installed successfully")
    
    print("\nFixing import statements...")
    fix_import_statements()
    print("Import statements fixed")

if __name__ == '__main__':
    main()