#!/bin/bash
# Script para generar PDFs individuales por cada pareja estado-capital
# Versión CORREGIDA - Con parámetros para directorio PNG y archivo de dorso
# Uso: ./generar_pdf_por_pareja.sh [directorio_png] [archivo_dorso.png]
# Mostrar ayuda si se solicita
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo ""
    echo "📄 SCRIPT PARA GENERAR PDF DE NAIPES"
    echo "======================================"
    echo "Uso: ./generar_pdf_por_pareja.sh [directorio_png] [archivo_dorso.png]"
    echo ""
    echo "Parámetros:"
    echo "  directorio_png    (Opcional) Directorio con los archivos PNG"
    echo "                    Por defecto: naipes_pngs"
    echo ""
    echo "  archivo_dorso.png (Opcional) Ruta al archivo de dorso"
    echo "                    Por defecto: Búsqueda automática"
    echo ""
    echo "Ejemplos:"
    echo "  ./generar_pdf_por_pareja.sh                              # Valores por defecto"
    echo "  ./generar_pdf_por_pareja.sh mis_pngs                     # Directorio personalizado"
    echo "  ./generar_pdf_por_pareja.sh . mi_dorso.png               # Directorio actual + dorso"
    echo "  ./generar_pdf_por_pareja.sh ../pngs ../dorso/dorso.png   # Rutas relativas"
    echo "  ./generar_pdf_por_pareja.sh /ruta/absoluta/pngs /ruta/absoluta/dorso.png"
    echo "======================================"
    exit 0
fi
# Configurar parámetros
PNG_DIR="${1:-naipes_pngs}"           # Primer parámetro o "naipes_pngs" por defecto
DORSO_ESPECIFICADO="$2"                # Segundo parámetro o vacío por defecto
PDF_DIR="pdf_naipes_final"             # Directorio de salida fijo
# Verificar que el directorio PNG existe
if [ ! -d "$PNG_DIR" ]; then
    echo "❌ Error: No existe el directorio $PNG_DIR"
    echo "   Uso: ./generar_pdf_por_pareja.sh [directorio_png] [archivo_dorso.png]"
    exit 1
fi
mkdir -p "$PDF_DIR"
echo "=========================================="
echo "📄 Generando PDFs por pareja estado-capital"
echo "=========================================="
echo "📁 Directorio PNG de entrada: $PNG_DIR"
if [ -n "$DORSO_ESPECIFICADO" ]; then
    echo "🎴 Archivo de dorso especificado: $DORSO_ESPECIFICADO"
fi
echo "📁 Directorio PDF de salida: $PDF_DIR"
echo "=========================================="
echo ""
# Obtener lista de estados ordenados
mapfile -t ESTADOS < <(ls "$PNG_DIR"/estado_*.png 2>/dev/null | sort)
mapfile -t CAPITALES < <(ls "$PNG_DIR"/capital_*.png 2>/dev/null | sort)
# Verificar que tenemos la misma cantidad
TOTAL_PAREJAS=${#ESTADOS[@]}
if [ $TOTAL_PAREJAS -ne ${#CAPITALES[@]} ]; then
    echo "❌ Error: Número desigual de estados (${#ESTADOS[@]}) y capitales (${#CAPITALES[@]})"
    exit 1
fi
echo "   Encontradas: $TOTAL_PAREJAS parejas estado-capital"
echo ""
# Copiar todas las imágenes al directorio de trabajo
echo "📌 Copiando imágenes a $PDF_DIR..."
for I in $(seq 0 $((TOTAL_PAREJAS - 1))); do
    # Copiar estado
    cp "${ESTADOS[$I]}" "$PDF_DIR/estado_${I}.png"
    # Copiar capital
    cp "${CAPITALES[$I]}" "$PDF_DIR/capital_${I}.png"
    echo "   ✅ estado_${I}.png + capital_${I}.png"
done
# Buscar o crear dorso
echo ""
echo "📌 Procesando imagen de dorso..."
# Función para copiar dorso
copiar_dorso() {
    local origen="$1"
    local destino="$PDF_DIR/dorso.png"
    if [ -f "$origen" ]; then
        cp "$origen" "$destino"
        echo "   ✅ dorso.png desde: $origen"
        DORSO_USADO="$origen"
        return 0
    else
        return 1
    fi
}
# Inicializar variable de dorso usado
DORSO_USADO=""
# Prioridad 1: Dorso especificado como parámetro (si se proporcionó)
if [ -n "$DORSO_ESPECIFICADO" ]; then
    if copiar_dorso "$DORSO_ESPECIFICADO"; then
        echo "   📌 Usando dorso especificado por parámetro"
    else
        echo "   ⚠️  No se encontró el archivo de dorso especificado: $DORSO_ESPECIFICADO"
        echo "   🔍 Buscando opciones alternativas..."
    fi
fi
# Si no se copió un dorso, buscar opciones en el directorio PNG
if [ ! -f "$PDF_DIR/dorso.png" ]; then
    # Prioridad 2: dorso_naipe.png en PNG_DIR
    if [ -f "$PNG_DIR/dorso_naipe.png" ]; then
        cp "$PNG_DIR/dorso_naipe.png" "$PDF_DIR/dorso.png"
        echo "   ✅ dorso.png desde: $PNG_DIR/dorso_naipe.png"
        DORSO_USADO="$PNG_DIR/dorso_naipe.png"
    # Prioridad 3: dorso.png en PNG_DIR
    elif [ -f "$PNG_DIR/dorso.png" ]; then
        cp "$PNG_DIR/dorso.png" "$PDF_DIR/dorso.png"
        echo "   ✅ dorso.png desde: $PNG_DIR/dorso.png"
        DORSO_USADO="$PNG_DIR/dorso.png"
    # Prioridad 4: dorso.png en directorio actual
    elif [ -f "dorso.png" ]; then
        cp "dorso.png" "$PDF_DIR/dorso.png"
        echo "   ✅ dorso.png desde directorio actual"
        DORSO_USADO="./dorso.png"
    # Prioridad 5: Crear dorso por defecto
    else
        echo "   ⚠️  No se encuentra archivo de dorso, creando uno por defecto..."
        if command -v convert &> /dev/null; then
            convert -size 700x1000 xc:darkblue -fill gold -gravity center -pointsize 40 -annotate 0 "VENEZUELA" "$PDF_DIR/dorso.png"
            echo "   ✅ dorso.png creado por defecto (con ImageMagick)"
            DORSO_USADO="creado_por_defecto"
        else
            echo "   ❌ Error: ImageMagick no está instalado y no hay archivo de dorso"
            exit 1
        fi
    fi
fi
echo ""
# 1. GENERAR PDF DE FRENTES (TODAS LAS PAREJAS)
echo "📌 Generando PDF de FRENTES..."
cat > "$PDF_DIR/frentes.tex" << EOF
\\documentclass{article}
\\usepackage{graphicx}
\\usepackage{geometry}
\\geometry{
  paperwidth=200mm,
  paperheight=150mm,
  left=0mm,
  right=0mm,
  top=0mm,
  bottom=0mm
}
\\pagestyle{empty}
\\begin{document}
EOF
# Generar una página por cada pareja
for I in $(seq 0 $((TOTAL_PAREJAS - 1))); do
    cat >> "$PDF_DIR/frentes.tex" << EOF
% Página $((I+1)) - Pareja $I
\\begin{center}
  \\includegraphics[width=70mm,height=100mm]{estado_${I}.png}
  \\hspace{20mm}
  \\includegraphics[width=70mm,height=100mm]{capital_${I}.png}
\\end{center}
\\newpage
EOF
done
echo "\\end{document}" >> "$PDF_DIR/frentes.tex"
# Compilar frentes
cd "$PDF_DIR"
pdflatex -interaction=nonstopmode frentes.tex > frentes.log 2>&1
if [ -f "frentes.pdf" ]; then
    echo "   ✅ PDF de frentes generado: frentes.pdf"
    mv frentes.pdf naipes_venezuela_frentes.pdf
    echo "   Tamaño: $(du -h naipes_venezuela_frentes.pdf | cut -f1)"
else
    echo "   ❌ Error compilando frentes"
    cat frentes.log
    exit 1
fi
# 2. GENERAR PDF DE DORSOS
echo ""
echo "📌 Generando PDF de DORSOS..."
cat > "dorsos.tex" << EOF
\\documentclass{article}
\\usepackage{graphicx}
\\usepackage{geometry}
\\geometry{
  paperwidth=200mm,
  paperheight=150mm,
  left=0mm,
  right=0mm,
  top=0mm,
  bottom=0mm
}
\\pagestyle{empty}
\\begin{document}
EOF
# Generar una página por cada pareja
for I in $(seq 0 $((TOTAL_PAREJAS - 1))); do
    cat >> "dorsos.tex" << EOF
% Página $((I+1)) - Dorso pareja $I
\\begin{center}
  \\includegraphics[width=70mm,height=100mm]{dorso.png}
  \\hspace{20mm}
  \\includegraphics[width=70mm,height=100mm]{dorso.png}
\\end{center}
\\newpage
EOF
done
echo "\\end{document}" >> "dorsos.tex"
# Compilar dorsos
pdflatex -interaction=nonstopmode dorsos.tex > dorsos.log 2>&1
if [ -f "dorsos.pdf" ]; then
    echo "   ✅ PDF de dorsos generado: dorsos.pdf"
    mv dorsos.pdf naipes_venezuela_dorsos.pdf
    echo "   Tamaño: $(du -h naipes_venezuela_dorsos.pdf | cut -f1)"
else
    echo "   ❌ Error compilando dorsos"
    cat dorsos.log
    exit 1
fi
cd - > /dev/null
# 3. VERIFICACIÓN
echo ""
echo "📌 Verificando archivos generados:"
cd "$PDF_DIR"
if [ -f "naipes_venezuela_frentes.pdf" ] && [ -f "naipes_venezuela_dorsos.pdf" ]; then
    echo "   ✅ PDFs generados correctamente"
    echo ""
    echo "📊 Estadísticas:"
    echo "   • Directorio PNG origen: $PNG_DIR"
    echo "   • $TOTAL_PAREJAS parejas estado-capital"
    echo "   • $((TOTAL_PAREJAS * 2)) naipes en total"
    echo "   • Formato página: 200mm × 150mm"
    echo "   • Tamaño naipe: 70mm × 100mm"
    echo "   • Dorso utilizado: $DORSO_USADO"
else
    echo "   ❌ Error en la generación"
fi
cd - > /dev/null
# 4. INSTRUCCIONES
cat > "${PDF_DIR}/instrucciones.txt" << EOF
INSTRUCCIONES DE IMPRESIÓN
==========================
Archivos generados:
- naipes_venezuela_frentes.pdf  (${TOTAL_PAREJAS} páginas)
- naipes_venezuela_dorsos.pdf   (${TOTAL_PAREJAS} páginas)
Origen de las imágenes:
- Directorio PNG: ${PNG_DIR}
- Dorso utilizado: ${DORSO_USADO:-"dorso por defecto"}
Cada página contiene:
- Izquierda: Estado
- Derecha: Capital
- Espacio de 20mm entre naipes
Para imprimir doble cara:
1. Imprimir naipes_venezuela_frentes.pdf al 100% (sin ajustar escala)
2. Volver a cargar el papel
3. Imprimir naipes_venezuela_dorsos.pdf en el reverso
Dimensiones:
- Página: 200mm × 150mm
- Naipe: 70mm × 100mm
- Margen superior/inferior: 25mm
- Margen izquierdo/derecho: 30mm
- Espacio entre naipes: 20mm
Recomendaciones:
- Usar papel opaco para evitar transparencias
- Verificar alineación en la primera página antes de imprimir todo
- Ajustar la impresora a "Tamaño real" o "100%"
EOF
echo ""
echo "=========================================="
echo "🎉 PROCESO COMPLETADO CON ÉXITO 🎉"
echo "=========================================="
echo "📁 Directorio de entrada: $PNG_DIR"
echo "📁 Directorio de salida: $PDF_DIR"
echo ""
echo "📄 Archivos generados:"
echo "   • naipes_venezuela_frentes.pdf"
echo "   • naipes_venezuela_dorsos.pdf"
echo "   • instrucciones.txt"
echo ""
echo "🖼️  Dorso utilizado: $DORSO_USADO"
echo ""
echo "🌐 Para ver los PDFs:"
echo "   evince $PDF_DIR/naipes_venezuela_frentes.pdf &"
echo "   evince $PDF_DIR/naipes_venezuela_dorsos.pdf &"
echo "=========================================="
echo ""
echo "📌 EJEMPLOS DE USO:"
echo "   ./generar_pdf_por_pareja.sh                                         # Valores por defecto"
echo "   ./generar_pdf_por_pareja.sh mis_pngs                                # Directorio personalizado"
echo "   ./generar_pdf_por_pareja.sh . mi_dorso.png                          # Directorio actual + dorso"
echo "   ./generar_pdf_por_pareja.sh ../pngs ../dorso/dorso.png              # Rutas relativas"
echo "   ./generar_pdf_por_pareja.sh /ruta/absoluta/pngs /ruta/absoluta/dorso.png"
echo "   ./generar_pdf_por_pareja.sh --help                                  # Mostrar ayuda"
echo "=========================================="
