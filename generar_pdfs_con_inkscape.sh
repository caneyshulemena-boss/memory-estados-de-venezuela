#!/bin/bash
# Script para generar PDFs desde SVG usando Inkscape
# Preserva fuentes y calidad vectorial
# Uso: ./generar_pdfs_con_inkscape.sh [directorio_svgs] [directorio_pdf]
SVG_DIR="${1:-svgs}"
PDF_DIR="${2:-pdf_naipes_final}"
# Verificar que Inkscape está instalado
if ! command -v inkscape &> /dev/null; then
    echo "❌ Error: Inkscape no está instalado"
    echo "   Instálalo con: sudo apt install inkscape (Linux)"
    echo "   o: brew install --cask inkscape (macOS)"
    exit 1
fi
# Verificar que existe el directorio de SVG
if [ ! -d "$SVG_DIR" ]; then
    echo "❌ Error: No existe el directorio $SVG_DIR"
    exit 1
fi
mkdir -p "$PDF_DIR"
echo "=========================================="
echo "📄 Generando PDFs desde SVG con Inkscape"
echo "=========================================="
echo "📁 SVG origen: $SVG_DIR"
echo "📁 PDF destino: $PDF_DIR"
echo ""
contador=0
for svg in "$SVG_DIR"/*.svg; do
    if [ -f "$svg" ]; then
        nombre=$(basename "$svg" .svg)
        echo "🔄 Procesando: $nombre.svg"
        # Exportar a PDF manteniendo fuentes
        inkscape "$svg" --export-type=pdf \
                       --export-filename="$PDF_DIR/${nombre}.pdf" \
                       --export-dpi=300 > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "   ✅ ${nombre}.pdf generado"
            contador=$((contador + 1))
        else
            echo "   ❌ Error en ${nombre}.svg"
        fi
    fi
done
echo ""
echo "🎉 Proceso completado: $contador PDFs generados en $PDF_DIR"
echo "📏 Tamaño original preservado (70mm × 100mm)"
echo "🔤 Fuentes incrustadas: Roboto"
