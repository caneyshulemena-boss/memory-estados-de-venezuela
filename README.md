# 🎴 Memory: Estados de Venezuela
![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Bash](https://img.shields.io/badge/language-bash-4EAA25.svg)
![Font Awesome](https://img.shields.io/badge/Font%20Awesome-7.2.0-528DD7.svg)
![Inkscape](https://img.shields.io/badge/Inkscape-1.0+-000000.svg)
![Roboto](https://img.shields.io/badge/font-Roboto-4285F4.svg)
## 📋 Descripción
**Memory: Estados de Venezuela** es un proyecto didáctico y open-source que genera un juego de naipes (cartas) para aprender los estados y capitales de Venezuela. El proyecto consta de scripts bash que transforman un archivo CSV con información de los 25 registros (24 estados + Guayana Esequiba) en naipes SVG, que pueden editarse con Inkscape, y luego generar archivos PDF listos para imprimir.
Cada naipe incluye:
- 🏷️ Prefijo del estado
- 📍 Nombre del estado o capital
- 🎨 Color distintivo por estado
- 🖼️ Ícono representativo (Font Awesome Solid)
- 🔤 Tipografía **Roboto** para una excelente legibilidad
## ✨ Características
- ✅ **25 registros totales** (24 estados + Guayana Esequiba)
- ✅ **Naipes de 70mm × 100mm** (tamaño estándar para imprimir)
- ✅ **Código de colores único** para cada estado
- ✅ **Íconos representativos** para cada entidad (petróleo, montaña, río, etc.)
- ✅ **Dos caras**: Estado por un lado, Capital por el otro
- ✅ **Formato PDF listo para impresión doble cara**
- ✅ **Soporte para dorsos personalizados**
- ✅ **Archivos SVG editables** con Inkscape para personalización avanzada
- ✅ **Fuente Roboto** incluida en los SVG para máxima compatibilidad
- ✅ **Totalmente open-source y personalizable**
## 🛠️ Requisitos
### Dependencias principales
- **Sistema operativo**: Linux / macOS / WSL
- **Bash 4.0+**
- **[Inkscape](https://inkscape.org/)** (recomendado v1.0+) - Para editar SVG y convertir a PDF/PNG manteniendo fuentes
- **[ImageMagick](https://imagemagick.org/)** (opcional, para conversiones alternativas)
- **[pdflatex](https://www.latex-project.org/)** (solo si usas el script de generación de PDF por lotes)
### Fuentes necesarias
- **Roboto** - La tipografía principal de los naipes
  - En Linux: `sudo apt install fonts-roboto`
  - En macOS: `brew install font-roboto` o descargar de Google Fonts
  - En Windows: Descargar e instalar desde [Google Fonts](https://fonts.google.com/specimen/Roboto)
### Íconos
- **[Font Awesome 7.2.0 Solid](https://fontawesome.com/v7/download)** - Íconos vectoriales
## 📦 Estructura del proyecto
```
memory-estados-de-venezuela/
├── estados_venezuela.csv           # Datos de estados y capitales
├── generar_naipes_fontawesome_local.sh  # Genera SVG con colores e íconos
├── svgs/                           # Naipes en formato SVG (editables con Inkscape)
├── naipes_pngs/                     # Naipes en formato PNG (generado opcional)
├── pdf_naipes_final/                # PDFs listos para imprimir
├── generar_pdf_por_pareja.sh        # Convierte PNG a PDF (método LaTeX)
├── generar_pdfs_con_inkscape.sh     # Script alternativo usando Inkscape (recomendado)
├── README.md                         # Este archivo
└── CHANGELOG.md                      # Historial de cambios
```
## 🚀 Cómo usar
### 1️⃣ Clonar el repositorio
```bash
git clone https://github.com/caneyshulemena-boss/memory-estados-de-venezuela.git
cd memory-estados-de-venezuela
```
### 2️⃣ Instalar fuentes necesarias
**Linux (Debian/Ubuntu):**
```bash
sudo apt update
sudo apt install fonts-roboto inkscape
```
**Linux (Fedora):**
```bash
sudo dnf install google-roboto-fonts inkscape
```
**macOS:**
```bash
brew install font-roboto
brew install --cask inkscape
```
### 3️⃣ Preparar los íconos de Font Awesome
Descarga [Font Awesome 7.2.0 Desktop](https://fontawesome.com/v7/download) y extrae los SVG en una ubicación conocida.
Por defecto, los scripts buscan en:
```
/home/soporte/Descargas/fontawesome-free-7.2.0-desktop/svgs-full/solid/
```
*Puedes modificar la variable `FONTAWESOME_DIR` en los scripts si es necesario.*
### 4️⃣ Generar los naipes en formato SVG
```bash
./generar_naipes_fontawesome_local.sh
```
Esto creará los archivos SVG en `svgs/` con:
- Colores personalizados por estado
- Fuente Roboto incorporada
- Íconos vectoriales de Font Awesome
- Sombras para mejor legibilidad
### 5️⃣ Editar con Inkscape (opcional)
Los archivos SVG generados son totalmente editables con Inkscape:
```bash
inkscape svgs/estado_amazonas.svg
```
Puedes ajustar colores, posiciones, textos, o añadir elementos adicionales.
### 6️⃣ Generar PDFs para imprimir
#### 🔹 **Método A: Usando Inkscape (Recomendado)** 🔹
Este método preserva perfectamente las fuentes y la calidad vectorial:
```bash
./generar_pdfs_con_inkscape.sh
```
O especificando directorios personalizados:
```bash
./generar_pdfs_con_inkscape.sh mis_svgs mis_pdfs
```
#### 🔹 **Método B: Usando el script con LaTeX** 🔹
Si prefieres generar PDFs por parejas para impresión doble cara:
```bash
# Primero convierte SVG a PNG (si no tienes los PNGs)
mkdir -p naipes_pngs
for svg in svgs/*.svg; do
    nombre=$(basename "$svg" .svg)
    inkscape "$svg" --export-type=png --export-filename="naipes_pngs/${nombre}.png" --export-dpi=300
done
# Luego genera los PDFs para impresión
./generar_pdf_por_pareja.sh naipes_pngs [opcional_dorso.png]
```
### 7️⃣ Imprimir
Los PDFs generados están listos para impresión doble cara:
- `naipes_venezuela_frentes.pdf` - Caras de los naipes
- `naipes_venezuela_dorsos.pdf` - Dorsos (para imprimir al reverso)
## 🎨 Personalización avanzada con Inkscape
Inkscape permite personalizar los naipes más allá de lo que los scripts pueden hacer:
| Acción | Comando Inkscape |
|--------|------------------|
| Editar texto | Doble clic sobre el texto |
| Cambiar color | Seleccionar objeto → Menú Objeto → Relleno y borde |
| Mover elementos | Seleccionar y arrastrar con la herramienta de selección |
| Añadir elementos | Dibujar con herramientas vectoriales |
| Exportar a PDF | Archivo → Guardar copia → PDF |
## 🔤 Sobre la fuente Roboto
Hemos elegido **Roboto** por:
- **Excelente legibilidad** en tamaños pequeños
- **Diseño moderno y neutral**
- **Disponibilidad gratuita** en todos los sistemas
- **Soporte completo para caracteres latinos** (incluyendo acentos del español)
- **Familia completa** con múltiples pesos (bold, regular, etc.)
Si no tienes Roboto instalada, Inkscape te lo indicará al abrir los SVG. Puedes:
1. Instalarla como se indica arriba, o
2. Inkscape te permitirá sustituirla temporalmente
## 📝 CSV de ejemplo
```csv
prefijo,nombre_estado,nombre_capital,color_fondo_hexadecimal,color_texto_hexadecimal,icono_awesome
Estado,Amazonas,Puerto Ayacucho,#F8C8D8,#2C3E50,feather
Estado,Anzoátegui,Barcelona,#D8E8F8,#4A2C2C,oil-well
...
Estado,Guayana Esequiba,Tumeremo,#E8D8F0,#2A6A4A,tree
```
## 🖨️ Instrucciones de impresión
Para obtener los mejores resultados:
1. **Imprime al 100%** (sin escalar)
2. **Usa papel opaco** (120-150g recomendado)
3. **Configura la impresora para "ajustar al área imprimible"** si es necesario
4. **Prueba con una página** antes de imprimir todo el lote
### Dimensiones exactas:
| Elemento | Medida |
|----------|--------|
| Ancho naipe | 70mm |
| Alto naipe | 100mm |
| Página | 200mm × 150mm |
| Margen superior/inferior | 25mm |
| Margen izquierdo/derecho | 30mm |
| Espacio entre naipes | 20mm |
## 🤝 Contribuir
Las contribuciones son bienvenidas. Áreas donde puedes ayudar:
- Mejorar los scripts bash
- Añadir más estados o regiones
- Crear variantes en otros idiomas
- Diseñar dorsos adicionales
- Mejorar la documentación
## 📄 Licencia
Este proyecto está bajo la licencia MIT. Ver el archivo `LICENSE` para más detalles.
## ✉️ Contacto
**Autor**: caneyshulemena-boss  
**Email**: caneyshulemena@gmail.com  
**GitHub**: [@caneyshulemena-boss](https://github.com/caneyshulemena-boss)
## 🙏 Agradecimientos
- **Font Awesome** por los increíbles íconos vectoriales
- **Inkscape** por la herramienta de edición vectorial gratuita
- **Google Fonts** por la tipografía Roboto
- La comunidad open-source por las herramientas (ImageMagick, LaTeX)
- Venezuela, por su diversidad geográfica y cultural
---
🇻🇪 **Hecho con ❤️ para aprender y enseñar sobre Venezuela** 🇻🇪
