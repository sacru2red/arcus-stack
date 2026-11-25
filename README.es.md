# 🏹 ARCUS-STACK (`arcus-stack`)

<p align="center">
  <a href="./README.md">English</a> |
  <a href="./README.ko.md">한국어</a> |
  <a href="./README.ja.md">日本語</a> |
  <a href="./README.zh-CN.md">简体中文</a> |
  <strong>Español</strong>
</p>

> **A**gent **R**ules, **C**ommands & **U**niversal **S**kills  
> *(Un anagrama de **SACRU** — Stack universal de habilidades y flujos de trabajo para agentes de IA)*

**`arcus-stack`** es un paquete universal de habilidades y flujos de trabajo compatible de forma nativa con **Antigravity (`agy`), Claude Code, Codex, Cursor y OpenCode**.

---

## 💡 ¿Por qué se creó `arcus-stack`?

Al trabajar en entornos multiagente como **T3 Code** u **Orca**, es habitual alternar o delegar tareas entre distintos agentes de programación (`agy`, Claude Code, Codex, Cursor, OpenCode). Sin embargo, cada herramienta exige rutas de carpetas y formatos de configuración distintos, lo que hacía muy frustrante **no poder usar las mismas habilidades al invocar a diferentes agentes**.

**`arcus-stack` nació para eliminar esta fragmentación.** Sin depender de servidores MCP pesados y utilizando únicamente los estándares universales `SKILL.md` y `AGENTS.md`, te permite invocar exactamente las mismas habilidades y reglas sin importar qué agente estés ejecutando.

Reúne e integra las mejores ideas de cuatro proyectos de código abierto:
- **[`pstack`](https://github.com/cursor/plugins/tree/main/pstack)**: *"Si quieres ir rápido, profundiza primero."* (Análisis de causa raíz, radio de impacto mínimo y código verificable)
- **[`oh-my-openagent`](https://github.com/code-yeongyu/oh-my-openagent)**: Bucles de ejecución autónoma (`ultrawork`) y separación entre estrategia y ejecución
- **[`oh-my-claudecode`](https://github.com/yeachan-heo/oh-my-claudecode)**: Delegación por roles especializados (planificación, implementación, revisión) y flujos autopilot
- **[`oh-my-antigravity`](https://github.com/Joonghyun-Lee-Frieren/oh-my-antigravity)**: Barreras de calidad por etapas y exigencia de evidencia real de verificación

---

## 📦 Habilidades Principales (`arcus-*`)

| Habilidad | Categoría | Beneficio y Descripción |
| :--- | :--- | :--- |
| **`arcus-mode`** | Modo Maestro | Eleva la calidad base de cada respuesta y cambio de código sin texto de relleno. Aplica automáticamente 24 principios de ingeniería, 22 playbooks de tareas y delegación disciplinada en subagentes. |
| **`arcus-plan`** | Planificación y Checklist | Evita perder tiempo reescribiendo código o pasando por alto requisitos. Investiga primero la causa raíz y el alcance del cambio para generar una lista de verificación (`- [ ]`) de ejecución y pruebas adaptada al objetivo de tu tarea. |
| **`arcus-work-loop`** | Bucle de Ejecución Autónoma | Completa tareas complejas de principio a fin sin detenerse a mitad de camino ni dejar código incompleto. Avanza ítem por ítem sobre la lista de verificación, marcando cada paso como completado (`- [x]`) solo tras superar pruebas y compilación reales. |
| **`arcus-review`** | Revisión de Planes y Código | Detecta puntos ciegos en tus planes de diseño y parches superficiales en el código antes de que causen retrabajo o fallos en producción. Sirve tanto para hacer una revisión crítica de un plan (`arcus-plan`) como para auditar código, casos extremos y evidencia de tests. |
| **`arcus-in-your-own-words`** | Alineación de Objetivos | Ahorra tiempo evitando que el agente programe algo distinto a lo que pediste. Hace que el agente resuma con sus propias palabras tu objetivo y el problema principal antes de actuar. |
| **`arcus-create-verification`** | Verificación de App | Te ahorra tener que abrir y probar manualmente la aplicación tras cada cambio. Crea y comprueba una habilidad local del proyecto (`verify-<app>`) que ejecuta y opera tu app como un usuario real. |
| **`arcus-maintain-verification`** | Mantenimiento de Verificación | Evita que las recetas de verificación de tu proyecto queden obsoletas cuando cambia el código. Compara el código fuente con la ejecución en vivo de la app para mantener actualizada la guía de verificación. |
| **`arcus-ketchup`** | Resumen de Avance | Te permite ver de un vistazo qué cambió y qué decisiones están pendientes sin leer historiales largos. Resume todo desde tu último mensaje con lenguaje sencillo, diagramas y opciones listas para decidir. |
| **`arcus-why`** | Historial y Decisiones | Ahorra tiempo adivinando por qué cierto código se escribió de esa manera. Rastrea los commits de Git y discusiones en PRs para explicarte las razones de diseño originales con citas y evidencias. |
| **`arcus-correct`** | Prevención de Errores | Elimina el desgaste de corregir una y otra vez el mismo error del agente. Convierte fallos repetidos en restricciones de arquitectura, tipos, reglas de lint o tests para que no puedan volver a ocurrir. |
| **`arcus-automate-me`** | Estilo Personal | Te libera de explicar tus preferencias de código y formato en cada nueva sesión. Analiza tus conversaciones recientes y realiza una breve entrevista de opción múltiple para crear tu propia habilidad `*-mode`. |
| **`arcus-skill-maker`** | Conversor de Habilidades | Permite usar habilidades externas diseñadas para una sola herramienta en los 5 agentes. Analiza cualquier flujo o prompt externo y lo convierte al estándar universal `arcus-*`. |

---

## 🏗️ Arquitectura: Encapsulación de Habilidades en Dos Niveles

Colocar docenas de habilidades detalladas directamente en la carpeta `skills/` satura el menú de comandos (`/`) y consume contexto. `arcus-stack` resuelve esto mediante una **estructura encapsulada de dos niveles**:

1. **Habilidades Principales para el Usuario (12 habilidades)**: Ubicadas en `skills/arcus-*/SKILL.md`. Solo estas 12 habilidades principales aparecen en tu menú.
2. **Módulos Internos Encapsulados (más de 60 archivos)**: Ubicados dentro de `skills/arcus-mode/` (`principles/`, `playbooks/`, `internal/`, `references/`). Como los escáneres de habilidades solo registran el primer nivel bajo `skills/`, los 24 principios, 22 playbooks y 14 sub-habilidades internas (`unslop`, `bro`, `architect`, `swarm`, `arena`, `interrogate`, etc.) no ensucian el menú del usuario y el agente los carga bajo demanda mediante enlaces relativos.

---

## 🚀 Instalación y Actualización

### Método 1. CLI `npx skills` (Recomendado — Global o por Proyecto)

```bash
# Instalar todas las habilidades globalmente en los 5 agentes de tu equipo
npx skills add sacru2red/arcus-stack -g -y

# Instalar habilidades específicas solo en el proyecto actual
npx skills add sacru2red/arcus-stack --skill arcus-mode --skill arcus-plan --skill arcus-work-loop
```

#### 🔄 Cómo actualizar con `npx skills`
Para obtener las últimas mejoras y nuevas habilidades desde GitHub en cualquier momento, vuelve a ejecutar el comando de instalación global (o usa `npx skills update`):
```bash
npx skills add sacru2red/arcus-stack -g -y
# o
npx skills update
```

### Método 2. Gestores de Plugins Nativos de cada Agente

- **Antigravity (`agy`)**:
  ```bash
  # Instalar y actualizar
  agy plugin install https://github.com/sacru2red/arcus-stack
  ```
- **Claude Code**:
  ```bash
  # Instalar
  /plugin marketplace add https://github.com/sacru2red/arcus-stack
  /plugin install arcus-stack

  # Actualizar
  /plugin update arcus-stack
  ```

### Método 3. Clonación Local + Enlaces Simbólicos Globales (`scripts/install-global.ps1` / `.sh`)

Si clonas este repositorio localmente y ejecutas el script, las habilidades se enlazan directamente a las carpetas globales de los 5 agentes (incluido el entorno aislado de Antigravity dentro de T3 Code).

```powershell
# Windows (PowerShell)
.\scripts\install-global.ps1
```

```bash
# macOS / Linux
./scripts/install-global.sh
```

#### 🔄 Cómo actualizar un clon local
Como los enlaces simbólicos apuntan directamente a tu carpeta local, basta con hacer `git pull` para que todos los agentes se actualicen al instante (ejecuta de nuevo el script solo si se añadieron nuevas carpetas de habilidades):
```bash
git pull && ./scripts/install-global.sh   # (o .\scripts\install-global.ps1 en Windows)
```
