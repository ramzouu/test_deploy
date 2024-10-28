#!/bin/bash
set -e  # Stop the script if any command fails

cat << "EOF"
  _____        __    .__        .__   
_/ __ \___.__./  |_  |__| ____  |  |  
\  ___<   |  |\   __\ |  |/ ___\ |  |  
 \___  >___  | |  |   |  \  \___ |  |__
     \/____  | |__|   |__|\___  >|____/
           \/                \/       
EOF

echo "🚀 Running the project setup"
echo "============================"

# Commentaire : On suppose que les dépendances sont déjà installées dans l'image Docker.
# echo "Installing requirements..."
# pip install -r requirements.txt

echo "🔄 Running migrations..."
python manage.py makemigrations --merge
python manage.py migrate

echo "============================"
echo "🧪 Running Tests and Sonar..."
echo "============================"
python manage.py test

# Vérification de l'étape de test
if [ $? -ne 0 ]; then
  echo " "
  echo "❌ Test step failed, please fix before pushing."
  exit 1
fi

echo "📂 Collecting static files..."
python manage.py collectstatic --noinput
if [ $? -ne 0 ]; then
  echo "❌ Failed to collect static files. Exiting."
  exit 1
fi

echo "============================"
echo "🌐 Starting Gunicorn Server..."
echo "============================"
GUNICORN_WORKERS="${GUNICORN_WORKERS:-3}"  # Valeur par défaut si non définie
VERSION="${VERSION:-1.0}"  # Valeur par défaut si non définie

echo "** Number of workers: ${GUNICORN_WORKERS}"
echo "** Version: ${VERSION}"
echo "** Starting Gunicorn on port 8000 with ${GUNICORN_WORKERS} workers..."

# Lancer Gunicorn
gunicorn testdeploy.wsgi:application -b 0.0.0.0:8000 -w "${GUNICORN_WORKERS}" --log-level DEBUG --threads=10 --timeout=3600

# Wait for all background jobs to finish
wait
