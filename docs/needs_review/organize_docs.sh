#!/bin/bash

# Create subdirectories
mkdir -p architecture ai planning

# Move existing files
mv data-flow.mermaid architecture/
mv AI-components.md ai/
mv project-structure-and-roadmap.md planning/

# If system-architecture.md exists, move i
if [ -f system-architecture.md ]; then
	mv system-architecture.md architecture/
fi

echo "Documentation reorganized successfully."
