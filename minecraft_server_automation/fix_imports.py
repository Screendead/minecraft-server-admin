#!/usr/bin/env python3
"""
Script to fix incorrect import paths after package conversion
"""
import os
import re
import glob

def fix_imports_in_file(file_path):
    """Fix imports in a single file"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Fix common incorrect paths
    replacements = [
        # Fix interfaces paths
        (r"import 'package:minecraft_server_automation/interfaces/", "import 'package:minecraft_server_automation/common/interfaces/"),
        # Fix adapters paths
        (r"import 'package:minecraft_server_automation/adapters/", "import 'package:minecraft_server_automation/common/adapters/"),
        # Fix mocks paths
        (r"import 'package:minecraft_server_automation/mocks/", "import 'package:minecraft_server_automation/common/mocks/"),
        # Fix testing paths
        (r"import 'package:minecraft_server_automation/testing/", "import 'package:minecraft_server_automation/common/testing/"),
        # Fix logic paths
        (r"import 'package:minecraft_server_automation/logic/", "import 'package:minecraft_server_automation/common/logic/"),
        # Fix di paths
        (r"import 'package:minecraft_server_automation/di/", "import 'package:minecraft_server_automation/common/di/"),
    ]
    
    for pattern, replacement in replacements:
        content = re.sub(pattern, replacement, content)
    
    # Only write if content changed
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed: {file_path}")
        return True
    
    return False

def main():
    """Main function to fix all Dart files"""
    # Find all Dart files in lib directory
    dart_files = glob.glob('lib/**/*.dart', recursive=True)
    
    updated_count = 0
    for file_path in dart_files:
        if fix_imports_in_file(file_path):
            updated_count += 1
    
    print(f"\nFixed {updated_count} files")

if __name__ == "__main__":
    main()
