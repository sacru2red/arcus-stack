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

**`arcus-stack`** es un paquete universal de habilidades y flujos de trabajo compatible de forma nativa con **`Antigravity` (`agy`), `Claude Code`, `Codex`, `Cursor` y `OpenCode`**.

---

## 💡 ¿Por qué se creó `arcus-stack`?

Al trabajar en entornos multiagente como **T3 Code** u **Orca**, es habitual alternar o delegar tareas entre distintos agentes de programación (`agy`, `Claude Code`, `Codex`, `Cursor`, `OpenCode`). Sin embargo, cada herramienta exige rutas de carpetas y formatos de configuración distintos, lo que hacía muy frustrante **no poder usar las mismas habilidades al invocar a diferentes agentes**.

**`arcus-stack` nació para eliminar esta fragmentación.** Sin depender de servidores MCP pesados y utilizando únicamente los estándares universales `SKILL.md` y `AGENTS.md`, te permite invocar exactamente las mismas habilidades y reglas sin importar qué agente estés ejecutando.

Reúne e integra las mejores ideas de seis proyectos de código abierto:
- **[`pstack`](https://github.com/cursor/plugins/tree/main/pstack)**: *"Si quieres ir rápido, profundiza primero."* (Análisis de causa raíz, radio de impacto mínimo y código verificable)
- **[`oh-my-openagent`](https://github.com/code-yeongyu/oh-my-openagent)**: Bucles de ejecución autónoma (`ultrawork`) y separación entre estrategia y ejecución
- **[`oh-my-claudecode`](https://github.com/yeachan-heo/oh-my-claudecode)**: Delegación por roles especializados (planificación, implementación, revisión) y flujos autopilot
- **[`oh-my-antigravity`](https://github.com/Joonghyun-Lee-Frieren/oh-my-antigravity)**: Barreras de calidad por etapas y exigencia de evidencia real de verificación
- **[`GoogleChrome/modern-web-guidance`](https://github.com/GoogleChrome/modern-web-guidance)**: Consulta en tiempo real de estándares y buenas prácticas de la plataforma web moderna (`npx -y modern-web-guidance@latest`) para HTML, CSS y JS del lado del cliente (Apache-2.0)
- **[`tt-a1i/archify`](https://github.com/tt-a1i/archify)**: Diagramas interactivos HTML/SVG en 10 tipos de diagramas, explicadores visuales de 1 página y diagnóstico de arquitectura de código priorizados automáticamente ante solicitudes de visualización (Apache-2.0)

Más allá de la compatibilidad multiagente, `arcus-stack` resuelve dos limitaciones estructurales de la programación con IA en una sola sesión:

### 1. Revisión con Contexto Aislado y Registro de Hallazgos (`arcus-review`)

Cuando la misma sesión que diseñó un plan o escribió el código revisa su propio trabajo, hereda exactamente los mismos sesgos y alternativas descartadas: **un revisor que comparte el contexto también comparte los puntos ciegos.** `arcus-review` rompe este ciclo mediante **Aislamiento de Contexto** y un **Registro de Hallazgos (Review Ledger)**:

- **Sandbox de Revisión Aislado**: Fija el commit o snapshot a revisar y lanza un nuevo subagente sin el historial del autor para evaluar el documento de diseño y el código desde cero. Consulta referencias externas más allá del repositorio y aplica una **Prueba de Lector en Frío (Cold-Reader Test)** para comprobar si el diseño se entiende solo con leer el documento.
- **Registro de Hallazgos (`F-01`, `F-02`, ...)**: Cada revisión mantiene una tabla estructurada de hallazgos separada físicamente de las respuestas del autor.
- **Veredicto a Ciegas Basado en Código (Ronda 2+)**: En rondas posteriores, antes de revisar código nuevo o **antes de abrir las respuestas/explicaciones del autor, el revisor inspecciona únicamente el snapshot de código** para decidir el estado de cada punto pendiente (`RESOLVED` resuelto, `UNRESOLVED` no resuelto, `VALID_PUSHBACK` contraargumento válido, o `DISPUTED` en disputa):

| ID | Ronda | Snapshot Fijo | Severidad | Destino | Escenario de Fallo y Solución | Estado |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `F-01` | R1 | `4e058ee` | `CRITICAL` | `worker.md:7` | Preguntar a mitad de un bucle autónomo bloquea al subagente. Diferir al turno principal. | `RESOLVED` |
| `F-02` | R1 | `4e058ee` | `HIGH` | `SKILL.md:44` | Ruta relativa falla en instalación parcial. Incluir reglas de respaldo en línea. | `VALID_PUSHBACK` |

*(Estados: `OPEN` · `RESOLVED` · `UNRESOLVED` · `VALID_PUSHBACK` · `DISPUTED`)*

### 2. Estándares Web Modernos y Compatibilidad de Navegadores Automática (`modern-web-guidance`)

Debido a la fecha de corte de sus datos de entrenamiento, los modelos de IA suelen escribir parches antiguos en JavaScript para problemas que el CSS o las APIs web modernas ya resuelven de forma nativa. Con `arcus-stack`, al trabajar con HTML, CSS o JS del lado del cliente (incluso dentro de React, Vue o Svelte), no necesitas invocar una habilidad adicional ni consultar manualmente `caniuse.com`. `modern-web-guidance` se activa automáticamente en segundo plano durante la planificación (`arcus-plan`), implementación (`arcus-work-loop`) y revisión (`arcus-review`):

1. **Consulta en Vivo de Guías Oficiales**: Antes de escribir código UI, el agente ejecuta `npx -y modern-web-guidance@latest search "<función>"` y `retrieve "<id>"` para consultar las prácticas más recientes del equipo de Google Chrome en lugar de usar patrones obsoletos.
2. **Verificación Integrada de Baseline y Navegadores**: Cada guía incluye el estado actual de **Web Platform Baseline** (`Widely available`, `Newly available`, `Limited availability`) y las versiones exactas soportadas en Chrome, Edge, Firefox y Safari.
3. **Fallbacks Automáticos**: Las funciones ampliamente soportadas se implementan de forma nativa y limpia, mientras que las APIs más recientes reciben automáticamente los bloques `@supports` o estrategias de degradación elegante recomendadas por la guía.

---

## 📦 Habilidades Principales (`arcus-*`)

| Habilidad | Categoría | Beneficio y Descripción |
| :--- | :--- | :--- |
| ⭐ **`arcus-mode`** | **Clave · Modo Maestro** | Eleva la calidad base de cada respuesta y cambio de código sin texto de relleno. Aplica automáticamente 24 principios de ingeniería, 23 playbooks de tareas y delegación disciplinada en subagentes. |
| ⭐ **`arcus-plan`** | **Clave · Planificación y Checklist** | Evita perder tiempo reescribiendo código o pasando por alto requisitos. Investiga primero la causa raíz y el alcance del cambio para generar una lista de verificación (`- [ ]`) de ejecución y pruebas adaptada al objetivo de tu tarea. |
| ⭐ **`arcus-work-loop`** | **Clave · Bucle de Ejecución Autónoma** | Completa tareas complejas de principio a fin sin detenerse a mitad de camino ni dejar código incompleto. Avanza ítem por ítem sobre la lista de verificación, marcando cada paso como completado (`- [x]`) solo tras superar pruebas y compilación reales. |
| ⭐ **`arcus-review`** | **Clave · Revisión Aislada de Planes y Código** | Evita heredar los puntos ciegos del autor ejecutando las revisiones en un subagente con contexto aislado sobre un snapshot fijo. Incluye pruebas de comprensión para lectores sin contexto previo, consulta de referencias externas y un registro de hallazgos (Review Ledger) que evalúa el código antes de leer respuestas. |
| ⭐ **`arcus-explain`** | **Clave · Explicación y Briefing Nivel Graduado CS** | Explica objetivos, planes arquitectónicos, cambios de código completados o conceptos complejos en el **tono claro de explicarle a un graduado veinteañero de Ingeniería de Software / CS** (modelos mentales de CS, mecanismos y trade-offs, sin analogías infantiles ni relleno). Proporciona un briefing automático al finalizar `arcus-plan`, `arcus-work-loop` y ejecuciones no triviales de `arcus-mode`. |
| **`arcus-security`** | Auditoría de Seguridad, Authz y Cadena de Suministro | Detecta fallos realmente explotables en lugar de relleno genérico de seguridad. Ejecuta auditorías con contexto aislado sobre fronteras de confianza, authz/IDOR y sumideros de entrada no confiable, redacta secretos, corre auditorías de dependencias y escáneres sin bloquear, demuestra hallazgos `CRITICAL`/`HIGH` con pruebas negativas locales aisladas y los rastrea en un Registro de Seguridad (`S-01`, `S-02`, ...). |
| **`arcus-ui-propose`** | Propuesta Visual UI de 4 Capturas | Evita que el agente imponga un único diseño de UI sin consultarte. En tareas visuales de UI, captura **1 pantalla base ("Before")** y **3 variantes propuestas distintas (`Option A`, `Option B`, `Option C`)** aplicando, capturando, guardando parches `.patch` y revirtiendo (`git checkout`) secuencialmente en tu rama de trabajo para que elijas qué opción aplicar. |
| **`arcus-create-verification`** | Verificación de App | Te ahorra tener que abrir y probar manualmente la aplicación tras cada cambio. Crea y comprueba una habilidad local del proyecto (`verify-<app>`) que ejecuta y opera tu app como un usuario real. |
| **`arcus-maintain-verification`** | Mantenimiento de Verificación | Evita que las recetas de verificación de tu proyecto queden obsoletas cuando cambia el código. Compara el código fuente con la ejecución en vivo de la app para mantener actualizada la guía de verificación. |
| **`arcus-ketchup`** | Resumen de Avance | Te permite ver de un vistazo qué cambió y qué decisiones están pendientes sin leer historiales largos. Resume todo desde tu último mensaje con lenguaje sencillo, diagramas y opciones listas para decidir. |
| **`arcus-why`** | Historial y Decisiones | Ahorra tiempo adivinando por qué cierto código se escribió de esa manera. Rastrea `DECISIONS.md`, los commits de Git y discusiones en PRs para explicarte las razones de diseño originales con citas y evidencias. |
| **`arcus-correct`** | Prevención de Errores y Limpieza de Reglas | Elimina el desgaste de corregir una y otra vez el mismo error manteniendo limpios tus archivos de reglas. Convierte fallos repetidos en restricciones de arquitectura, tipos, lints o tests, y depura reglas huérfanas, redundantes o afirmaciones sobre APIs que caducan al actualizar versiones. |
| **`arcus-automate-me`** | Estilo Personal | Te libera de explicar tus preferencias de código y formato en cada nueva sesión. Analiza tus conversaciones recientes y realiza una breve entrevista de opción múltiple para crear tu propia habilidad `*-mode`. |
| **`arcus-onboard`** | Mapa de Dominio y Minas Legadas | Evita que el agente adivine reglas de negocio o pise zonas intocables de código legado. Analiza esquemas/rutas y realiza una entrevista breve para construir un `ONBOARDING.md` de 1 a 2 páginas (límites del sistema, mapeo de términos de dominio ↔ identificadores de código/BD, fórmulas e invariantes de negocio, permisos y niveles de plan, minas de código legado, sistemas de referencia y contratos de error) con etiquetas `[as of YYYY-MM-DD \| Source: ...]`. |
| **`arcus-skill-maker`** | Conversor de Habilidades | Permite usar habilidades externas diseñadas para una sola herramienta en los 5 agentes. Analiza cualquier flujo o prompt externo y lo convierte al estándar universal `arcus-*`. |

---

## 🎯 Guía de Uso: `arcus-mode` vs. `arcus-work-loop` y Flujo Recomendado

### 1. ¿Cuál es la diferencia entre `arcus-mode` y `arcus-work-loop`?

| Dimensión | 👑 **`arcus-mode` (Modo Maestro / Sistema Operativo)** | 🔄 **`arcus-work-loop` (Motor de Ejecución de Checklist)** |
| :--- | :--- | :--- |
| **Rol Principal** | Establece el criterio de ingeniería, el estilo de respuesta conciso y la coordinación de subagentes para toda la sesión. | Toma una lista de verificación (`- [ ]`) y ejecuta el bucle **implementar ➔ probar ➔ corregir ➔ marcar (`[x]`)** hasta completar cada ítem. |
| **Alcance** | Amplio: selecciona entre 24 principios de ingeniería y 23 playbooks (investigación, refactorización, comparativas de diseño, optimización, gestión de PRs). | Enfocado: toma la lista generada por `arcus-plan`, aplica cambios mínimos y marca `- [x]` únicamente tras validar con tests y compilación reales. |
| **Cuándo Usarlo** | Al iniciar una sesión para activar estándares de ingeniería senior, o en tareas abiertas de investigación, arquitectura y depuración. | Justo después de `$arcus-plan` (y `$arcus-review`), cuando el plan ya está decidido y quieres que el agente implemente y verifique todo sin detenerse a mitad de camino. |

### 2. Flujo de Trabajo Paso a Paso Recomendado

1. **Planificación y Checklist (`$arcus-plan`)**: Identifica la causa raíz, mapea archivos afectados, genera una lista de verificación (`- [ ]`) con condiciones de prueba y cierra con un briefing automático de **`arcus-explain`** (modelo mental CS y resumen de trade-offs).
2. **Crítica Aislada del Plan (`$arcus-review`)**: Lanza un subagente con contexto aislado para auditar los supuestos del plan antes de modificar código.
3. **Bucle de Ejecución Autónoma (`$arcus-work-loop`)**: Ejecuta y verifica cada punto de la lista hasta que todos estén marcados como `- [x]`, finalizando con un briefing de **`arcus-explain`**.
4. **Revisión Final y Registro de Decisiones (`$arcus-review` / `DECISIONS.md`)**: Audita el código frente al Review Ledger. Si hubo decisiones arquitectónicas importantes o graduación de reglas (`$arcus-correct`), solicita tu autorización explícita para registrarlas en `DECISIONS.md` (o recuerda tu exclusión por proyecto en `.git/config`, `AGENTS.md` o `.agents/settings.json`).

---

## 🏗️ Arquitectura: Encapsulación de Habilidades en Dos Niveles

Colocar docenas de habilidades detalladas directamente en la carpeta `skills/` satura el menú de comandos (`/`) y consume contexto. `arcus-stack` resuelve esto mediante una **estructura encapsulada de dos niveles**:

1. **Habilidades Principales para el Usuario (15 habilidades)**: Ubicadas en `skills/arcus-*/SKILL.md`. Solo estas 15 habilidades principales aparecen en tu menú.
2. **Módulos Internos Encapsulados (más de 60 archivos)**: Ubicados dentro de `skills/arcus-mode/` (`principles/`, `playbooks/`, `internal/`, `references/`). Como los escáneres de habilidades solo registran el primer nivel bajo `skills/`, los 24 principios, 23 playbooks y 20 sub-habilidades internas (`unslop`, `bro`, `architect`, `swarm`, `arena`, `interrogate`, `checklist`, `decisions`, `modern-web-guidance`, `archify-visualization`, `typescript-best-practices`, `backend-reliability`, etc.) no ensucian el menú del usuario y el agente los carga bajo demanda mediante enlaces relativos.

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

> **Nota sobre habilidades renombradas o eliminadas:** `npx skills` no elimina automáticamente las habilidades que cambiaron de nombre o se eliminaron en el repositorio (por ejemplo, `arcus-work` → `arcus-work-loop` o `arcus-in-your-own-words` → `arcus-explain`). Si una habilidad antigua sigue apareciendo tras actualizar, elimínala con:
> ```bash
> npx skills remove arcus-work arcus-in-your-own-words -g -y
> ```

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

---

## 🗂️ Estructura de Directorios

```text
arcus-stack/
├── README.md                    # Documentación principal en inglés (English)
├── README.ko.md                 # Documentación en coreano (Korean)
├── README.ja.md                 # Documentación en japonés (Japanese)
├── README.zh-CN.md              # Documentación en chino simplificado (Simplified Chinese)
├── README.es.md                 # Documentación en español (Spanish)
├── DECISIONS.md                 # Registro de decisiones arquitectónicas (D-001..D-013)
├── plugin.json                  # Manifiesto de plugin para Antigravity (agy)
├── .claude-plugin/
│   └── plugin.json              # Manifiesto de plugin para Claude Code
├── .agents/
│   └── skills.json              # Manifiesto de descubrimiento de habilidades del workspace
├── AGENTS.md                    # Puente de reglas raíz
├── CLAUDE.md                    # Puente de reglas para Claude Code
├── rules/
│   └── AGENTS.md                # Reglas centrales de ingeniería compartidas en los 5 agentes
├── scripts/
│   ├── install-global.ps1       # Instalador global de enlaces simbólicos en Windows (5 agentes + T3 Code)
│   └── install-global.sh        # Instalador global de enlaces simbólicos en macOS/Linux (5 agentes + T3 Code)
└── skills/                      # ⭐ 15 Habilidades Principales para el Usuario
    ├── arcus-mode/              # Modo maestro + módulos internos encapsulados
    │   ├── SKILL.md
    │   ├── worker.md
    │   ├── playbooks/           # [Interno] 23 playbooks de tareas
    │   ├── principles/          # [Interno] 24 principios de ingeniería
    │   ├── internal/            # [Interno] 20 sub-habilidades auxiliares (unslop, bro, modern-web-guidance, archify-visualization, typescript-best-practices, backend-reliability, etc.)
    │   └── references/          # [Interno] bugbot-triage.md
    ├── arcus-plan/
    ├── arcus-work-loop/
    ├── arcus-review/
    ├── arcus-explain/
    ├── arcus-security/
    ├── arcus-ui-propose/
    ├── arcus-create-verification/
    ├── arcus-maintain-verification/
    ├── arcus-ketchup/
    ├── arcus-why/
    ├── arcus-correct/
    ├── arcus-automate-me/
    ├── arcus-onboard/
    └── arcus-skill-maker/
```
