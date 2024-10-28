# Utiliser l'image Python 3.12 comme base pour le conteneur
FROM python:3.12

# Définir les variables d'environnement pour configurer Python
ENV PYTHONUNBUFFERED 1  
ENV PYTHONDONTWRITEBYTECODE 1 
ENV APP_HOME /testdeploy  
ENV XDG_RUNTIME_DIR /tmp/runtime-root  

# Créer le répertoire de l'application et de runtime, et installer les dépendances système en une seule commande
RUN mkdir -p $APP_HOME /tmp/runtime-root && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Définir le répertoire de travail
WORKDIR $APP_HOME

# Installer les dépendances Python à partir du fichier requirements.txt
COPY requirements.txt .
RUN python -m pip install --upgrade pip && \
    pip install -r requirements.txt

# Copier le code de l'application dans le répertoire de travail
COPY . .

# Assurez-vous que le dossier de runtime a les permissions appropriées
RUN chmod -R 0700 /tmp/runtime-root

# Exposer le port utilisé par l'application
EXPOSE 8000

# Commande par défaut pour démarrer Gunicorn
CMD ["gunicorn", "mon_projet.wsgi:application", "--bind", "0.0.0.0:8000"]
