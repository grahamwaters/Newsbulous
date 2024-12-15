# Deactivate any active virtual environment
source deactivate

# Remove the existing virtual environment
rm -rf venv

# Ensure setup.sh is executable
chmod +x setup.sh

# Run the updated setup script
./setup.sh
