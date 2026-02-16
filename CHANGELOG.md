# 📝 Historial de Cambios (Changelog)
Todas las modificaciones importantes de "Memory: Estados de Venezuela" serán documentadas en este archivo.
El formato está basado en [Keep a Changelog](https://keepachangelog.com/es/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [1.0.0] - 2026-02-16
### 🎉 Primera versión estable
- Lanzamiento inicial del proyecto
- Scripts completamente funcionales para generar naipes educativos
### ✨ Características principales
- **CSV completo**: 25 registros (24 estados + Guayana Esequiba)
- **Generación SVG**: Script `generar_naipes_fontawesome_local.sh` que crea naipes con:
  - Colores personalizados por estado
  - **Fuente Roboto** incorporada para excelente legibilidad
  - Íconos de Font Awesome Solid
  - Textos con sombras para mejor legibilidad
  - División automática de textos largos
  - **Compatibilidad total con Inkscape** para edición posterior
- **Edición con Inkscape**: Los SVG generados son 100% editables:
  - Textos editables directamente
  - Objetos vectoriales modificables
  - Exportación a PDF manteniendo fuentes
  - Personalización avanzada sin perder calidad
- **Generación de PDFs**: Múltiples métodos:
  - **Método Inkscape** (recomendado): Exportación directa SVG → PDF preservando fuentes
  - **Método LaTeX**: Script `generar_pdf_por_pareja.sh` con:
    - Soporte para parámetros (directorio PNG y archivo de dorso)
    - Creación de dorsos por defecto si no existen
    - Formato profesional para impresión doble cara
    - Instrucciones detalladas de impresión
### 🔤 Fuentes utilizadas
- **Roboto** (Regular y Bold)
  - Instalación automática en Linux: `sudo apt install fonts-roboto`
  - Disponible en Google Fonts para todos los sistemas
  - Excelente legibilidad en tamaños pequeños
  - Soporte completo para caracteres latinos (acentos, ñ, ü)
### 🎨 Herramientas de edición
- **Inkscape** (v1.0+ recomendado)
  - Edición directa de archivos SVG
  - Exportación a PDF manteniendo calidad vectorial
  - Conversión a PNG a cualquier resolución
  - Soporte nativo para fuentes del sistema
### 🐛 Correcciones incluidas
- Procesamiento correcto de todas las líneas del CSV (incluyendo última línea sin salto de línea)
- Manejo de acentos en nombres de archivo (á→a, é→e, í→i, ó→o, ú→u, ñ→n, ü→u)
- Centrado correcto de íconos en los naipes
- Sistema de contador preciso usando archivos temporales
- Verificación de existencia de archivos antes de procesar
### 📁 Archivos incluidos
- `estados_venezuela.csv` - Base de datos completa
- `generar_naipes_fontawesome_local.sh` - Generador SVG con soporte Inkscape
- `generar_pdf_por_pareja.sh` - Generador PDF (método LaTeX)
- `generar_pdfs_con_inkscape.sh` - Script para exportar con Inkscape
- `README.md` - Documentación completa con instrucciones de Inkscape y Roboto
- `CHANGELOG.md` - Este archivo
### 🖼️ Íconos soportados
- feather, oil-well, cow, horse, wheat-awn, gem, industry, cat, fish
- landmark, umbrella-beach, seedling, guitar, mountain, building
- fire, anchor, corn, ship, flag, monument, water, lemon, gas-pump, tree
### ⚙️ Requisitos detallados
| Herramienta | Versión | Propósito |
|-------------|---------|-----------|
| Bash | 4.0+ | Ejecución de scripts |
| **Inkscape** | 1.0+ | **Edición SVG y exportación a PDF/PNG** |
| **Roboto** | Cualquiera | Tipografía principal de los naipes |
| Font Awesome | 7.2.0 | Íconos vectoriales |
| ImageMagick | Opcional | Conversiones alternativas |
| pdflatex | Opcional | Generación PDF por lotes |
### 📌 Notas de instalación
**Instalar dependencias en Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install fonts-roboto inkscape
```
**Instalar en macOS:**
```bash
brew install font-roboto
brew install --cask inkscape
```
### 📌 Flujo de trabajo recomendado
```bash
# 1. Generar SVG
./generar_naipes_fontawesome_local.sh
# 2. (Opcional) Editar con Inkscape
inkscape svgs/estado_amazonas.svg
# 3. Exportar a PDF con Inkscape (manteniendo fuentes)
./generar_pdfs_con_inkscape.sh
# 4. ¡A imprimir!
```
## [0.9.0] - 2026-02-15
### 🚧 Versión de desarrollo (pre-lanzamiento)
- Pruebas iniciales del concepto
- Prototipos de naipes con diseño básico
- Experimentación con formatos y colores
### 🧪 Características probadas
- Primeros SVG generados manualmente
- Pruebas de maquetación de textos
- Experimentos con sombras y efectos
- Pruebas de diferentes tipografías (seleccionada Roboto como ganadora)
### 🔄 Cambios respecto a versión anterior
- No aplica (primera versión documentada)
---
## 📈 Próximas mejoras (Roadmap)
### [1.1.0] - Planeado
- [ ] Script unificado que ejecute todo el proceso en un solo comando
- [ ] Soporte para más idiomas (inglés, portugués)
- [ ] Opción de generar naipes en otros tamaños (póker, bridge)
- [ ] Plantillas de Inkscape pre-diseñadas
### [1.2.0] - Futuro
- [ ] Interfaz web simple para previsualizar los naipes
- [ ] Generación de versiones para niños (con dibujos)
- [ ] Soporte para incluir datos adicionales (población, superficie)
- [ ] Exportación directa a PDF desde los scripts usando Inkscape CLI
---
## 🐛 Reportar problemas
Si encuentras algún error, por favor reportalo en:
https://github.com/caneyshulemena-boss/memory-estados-de-venezuela/issues
Incluye:
- Descripción del problema
- Pasos para reproducirlo
- Versión del script y sistema operativo
- ¿Tienes Inkscape instalado? ¿Qué versión?
- ¿Tienes la fuente Roboto instalada?
---
🇻🇪 **Memoria y orgullo venezolano** 🇻🇪
