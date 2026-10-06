# AI Engineer Challenge
## Notebook de extraccion SQL, clasificacion local con Ollama y persistencia SQLite.

La lógica Python está separada en scripts/; el notebook muestra las consultas, los mensajes de progreso y las tablas de resultados.
## Instalar Dependencias

Requisitos: Python 3.14 y Git. Clonar o descargar el repositorio y abrir una terminal en su raíz, donde deben encontrarse challenge.ipynb, requirements.txt, scripts/, sql/ y data/. Colocar una copia de la base suministrada en data/airline_reviews.db.

El pipeline realiza una clasificación con LLM que corre localmente (ver apartado de LLM), este debe instalarse antes de correr el notebook.

Crear el entorno e instalar dependencias desde la raiz (PowerShell):
```powershell
py -3.14 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe -m pip check
```
Configurar Ollama según el apartado siguiente antes de ejecutar el notebook. Iniciar JupyterLab desde la raiz:

```powershell
.\.venv\Scripts\python.exe -m jupyter lab
```
Seleccionar el kernel del entorno creado, reiniciarlo y ejecutar todas las celdas de inicio a fin. Como alternativa, en VS Code seleccionar .venv\Scripts\python.exe en Select Kernel.

## Levantamiento de LLM

El modelo utilizado es Qwen2.5:3B mediante Ollama. Instalar la aplicación Ollama para Windows (Link)[https://ollama.com/download/windows], abrirla y descargar el modelo local:

```powershell
ollama pull qwen2.5:3b
ollama list
```

## Decisiones relevantes, mejoras en otras instancias.

Separé la lógica Python en módulos y las consultas en archivos SQL para facilitar la lectura. Elegí Ollama por su configuración sencilla para ejecutar un modelo local y solicitar respuestas con un esquema JSON, y Pydantic para validar los campos y las etiquetas permitidas basándome en otros proyectos publicados en GitHub que implementan modelos locales con Python y SQL.

Definí cinco categorías temáticas tomando las áreas del ejercicio como referencia y revisando una pequeña muestra de reseñas extraídas. El tema identifica la queja principal y el área de mejora identifica la función que debería actuar, con ambos clasificados de forma independiente. Las definiciones textuales están en scripts/classification.py.

Sobre las categorias y areas, estas están definidas exactamente  en `scripts/classification.py`. Para el desafío, elegí estas categorías basándome en las áreas definidas del ejercicio como punto de referencia sumado con revisar algunas review para asegurar un acople con una muestra reducida. 

La validación estructural no garantiza una interpretación correcta de la reseña. Actualmente, un error detiene la clasificación, sin reintentos automáticos. Con más tiempo, ampliaría la muestra para revisar sistemáticamente las categorías, compararía las clasificaciones con anotaciones humanas e incorporaría reintentos limitados para fallos temporales de conexión.

