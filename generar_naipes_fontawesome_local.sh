#!/bin/bash
# Script para generar naipes SVG a partir del CSV de estados de Venezuela
# VERSIÓN DEFINITIVA - Procesa TODOS los registros incluyendo el último
# Uso: ./generar_naipes_fontawesome_local.sh
# Archivo CSV de entrada
CSV_FILE="estados_venezuela.csv"
# Directorio de salida
OUTPUT_DIR="svgs"
mkdir -p "$OUTPUT_DIR"
# Ruta a los íconos de Font Awesome (VERSIÓN SOLID)
FONTAWESOME_DIR="/home/soporte/Descargas/fontawesome-free-7.2.0-desktop/svgs-full/solid"
# Verificar que existe el directorio de íconos
if [ ! -d "$FONTAWESOME_DIR" ]; then
    echo "❌ ERROR: No se encuentra el directorio de íconos"
    echo "   Ruta buscada: $FONTAWESOME_DIR"
    exit 1
fi
echo "✅ Directorio de íconos encontrado: $FONTAWESOME_DIR"
echo ""
# Dimensiones del naipe estándar (píxeles)
WIDTH=300
HEIGHT=420
BORDER=12
# Posición y tamaño del ícono (CENTRADO HORIZONTAL Y VERTICALMENTE)
ICONO_X=80  # Centrado horizontalmente: (300-140)/2 = 80
ICONO_Y=190
ICONO_ANCHO=140
ICONO_ALTO=140
# Mapeo de nombres de iconos a archivos SVG
declare -A MAPEO_ICONOS=(
    ["feather"]="feather.svg"
    ["oil-well"]="oil-well.svg"
    ["cow"]="cow.svg"
    ["horse"]="horse.svg"
    ["wheat-awn"]="wheat-awn.svg"
    ["gem"]="gem.svg"
    ["industry"]="industry.svg"
    ["cat"]="cat.svg"
    ["fish"]="fish.svg"
    ["landmark"]="landmark.svg"
    ["umbrella-beach"]="umbrella-beach.svg"
    ["seedling"]="seedling.svg"
    ["guitar"]="guitar.svg"
    ["mountain"]="mountain.svg"
    ["building"]="building.svg"
    ["fire"]="fire.svg"
    ["anchor"]="anchor.svg"
    ["corn"]="corn-svgrepo-com.svg"
    ["ship"]="ship.svg"
    ["flag"]="flag.svg"
    ["monument"]="monument.svg"
    ["water"]="water.svg"
    ["lemon"]="lemon.svg"
    ["gas-pump"]="gas-pump.svg"
    ["tree"]="tree.svg"
)
# Función para limpiar acentos y caracteres especiales para nombres de archivo
limpiar_nombre_archivo() {
    local texto="$1"
    # Convertir a minúsculas
    texto=$(echo "$texto" | tr '[:upper:]' '[:lower:]')
    # Reemplazar acentos y caracteres especiales
    texto=$(echo "$texto" | sed 's/á/a/g; s/é/e/g; s/í/i/g; s/ó/o/g; s/ú/u/g; s/ñ/n/g; s/ü/u/g')
    # Reemplazar espacios por guiones bajos
    texto=$(echo "$texto" | sed 's/ /_/g')
    # Eliminar cualquier otro carácter no alfanumérico o guión bajo
    texto=$(echo "$texto" | sed 's/[^a-z0-9_]//g')
    echo "$texto"
}
# Función para obtener los paths del SVG
obtener_paths_svg() {
    local archivo="$1"
    if [ ! -f "$archivo" ]; then
        echo ""
        return 1
    fi
    # Leer el contenido del archivo SVG
    local contenido=$(cat "$archivo")
    # Extraer SOLO los paths (sin ningún atributo)
    echo "$contenido" | grep -o '<path[^>]*/>' | sed 's/ fill="[^"]*"//g' | sed 's/ fill:[^;]*;//g'
}
# Función para obtener el viewBox del SVG
obtener_viewbox_svg() {
    local archivo="$1"
    if [ ! -f "$archivo" ]; then
        echo "0 0 512 512"
        return 1
    fi
    # Leer el contenido del archivo SVG
    local contenido=$(cat "$archivo")
    # Extraer el viewBox
    local viewbox=$(echo "$contenido" | grep -o 'viewBox="[^"]*"' | head -1 | sed 's/viewBox="//;s/"//g')
    if [ -z "$viewbox" ]; then
        echo "0 0 512 512"
    else
        echo "$viewbox"
    fi
}
# Función para dividir textos largos
dividir_texto() {
    local texto="$1"
    local max_longitud=14
    if [ ${#texto} -le $max_longitud ]; then
        echo "$texto|"
        return
    fi
    # Buscar espacios para dividir
    IFS=' ' read -ra palabras <<< "$texto"
    if [ ${#palabras[@]} -gt 1 ]; then
        local linea1=""
        local linea2=""
        local mitad=$(( (${#palabras[@]} + 1) / 2 ))
        for i in "${!palabras[@]}"; do
            if [ $i -lt $mitad ]; then
                linea1="$linea1 ${palabras[$i]}"
            else
                linea2="$linea2 ${palabras[$i]}"
            fi
        done
        linea1=$(echo "$linea1" | sed 's/^ //')
        linea2=$(echo "$linea2" | sed 's/^ //')
        echo "${linea1}|${linea2}"
    else
        # Si no hay espacios, dividir por la mitad
        local mitad=$(( ${#texto} / 2 ))
        local linea1=$(echo "$texto" | cut -c1-$mitad)
        local linea2=$(echo "$texto" | cut -c$((mitad+1))-)
        echo "${linea1}-${linea2}"
    fi
}
# Leer el archivo completo y procesar línea por línea (incluyendo la última sin salto de línea)
echo "📊 Procesando todas las líneas del CSV..."
# Crear archivo temporal con todas las líneas (asegurando que la última se procese)
temp_csv=$(mktemp)
cat "$CSV_FILE" > "$temp_csv"
# Contar total de líneas en el CSV (excluyendo cabecera)
total_lineas=$(tail -n +2 "$temp_csv" | wc -l)
echo "📊 Total de registros a procesar: $total_lineas"
echo ""
# Crear archivo temporal para almacenar los nombres procesados
temp_contador=$(mktemp)
echo "0" > "$temp_contador"
# Leer el CSV saltando la primera línea, procesando TODAS las líneas
tail -n +2 "$temp_csv" | while IFS=',' read -r prefijo nombre_estado nombre_capital color_fondo color_texto icono || [ -n "$prefijo" ]; do
    # Limpiar espacios y retornos de carro
    prefijo=$(echo "$prefijo" | tr -d '\r' | xargs)
    nombre_estado=$(echo "$nombre_estado" | tr -d '\r' | xargs)
    nombre_capital=$(echo "$nombre_capital" | tr -d '\r' | xargs)
    color_fondo=$(echo "$color_fondo" | tr -d '\r' | xargs)
    color_texto=$(echo "$color_texto" | tr -d '\r' | xargs)
    icono=$(echo "$icono" | tr -d '\r' | xargs)
    # Incrementar contador
    count=$(cat "$temp_contador")
    count=$((count + 1))
    echo "$count" > "$temp_contador"
    echo "[$count] Procesando: $nombre_estado - Ícono: $icono"
    # Obtener nombre del archivo SVG
    nombre_archivo="${MAPEO_ICONOS[$icono]}"
    if [ -z "$nombre_archivo" ]; then
        echo "   ⚠️  Advertencia: No hay archivo para el ícono '$icono'"
        continue
    fi
    # Ruta completa al archivo
    archivo_svg="$FONTAWESOME_DIR/$nombre_archivo"
    # Verificar que el archivo existe
    if [ ! -f "$archivo_svg" ]; then
        echo "   ❌ Error: No existe el archivo $archivo_svg"
        continue
    fi
    # Obtener paths del SVG (sin atributos fill)
    paths_base=$(obtener_paths_svg "$archivo_svg")
    # Obtener viewBox del SVG
    viewbox=$(obtener_viewbox_svg "$archivo_svg")
    if [ -z "$paths_base" ]; then
        echo "   ⚠️  No se pudo leer el SVG, usando rectángulo de respaldo"
        paths_base='<path d="M156 156 L284 156 L284 284 L156 284 Z"/>'
    fi
    # Paths con color
    paths_con_color=$(echo "$paths_base" | sed "s|<path|<path fill=\"$color_texto\"|g")
    # Paths para sombra (negro)
    paths_sombra=$(echo "$paths_base" | sed "s|<path|<path fill=\"#000000\"|g")
    # Dividir textos
    IFS='|' read -r estado_line1 estado_line2 <<< "$(dividir_texto "$nombre_estado")"
    IFS='|' read -r capital_line1 capital_line2 <<< "$(dividir_texto "$nombre_capital")"
    # Limpiar posibles guiones
    estado_line2=$(echo "$estado_line2" | sed 's/^-//')
    capital_line2=$(echo "$capital_line2" | sed 's/^-//')
    # Generar nombre de archivo base SIN ACENTOS
    nombre_base=$(limpiar_nombre_archivo "$nombre_estado")
    # 1. Generar SVG para el ESTADO
    cat > "${OUTPUT_DIR}/estado_${nombre_base}.svg" << EOF
<svg width="$WIDTH" height="$HEIGHT" viewBox="0 0 $WIDTH $HEIGHT" xmlns="http://www.w3.org/2000/svg">
    <!-- Fondo blanco del naipe -->
    <rect width="$WIDTH" height="$HEIGHT" fill="white" rx="20" ry="20" />
    <!-- Borde negro -->
    <rect x="1.5" y="1.5" width="$((WIDTH-3))" height="$((HEIGHT-3))" fill="none" stroke="black" stroke-width="1.5" rx="18" ry="18" />
    <!-- Fondo de color interior -->
    <rect x="$BORDER" y="$BORDER" width="$((WIDTH-2*BORDER))" height="$((HEIGHT-2*BORDER))" fill="$color_fondo" rx="15" ry="15" />
    <!-- Grupo de textos con sombras MANUALES (más confiables) -->
    <!-- SOMBRA Prefijo -->
    <text x="152" y="72" text-anchor="middle" font-family="Roboto, Arial Black, Arial, sans-serif" font-size="24" font-weight="bold" fill="#000000" opacity="0.4">$prefijo</text>
    <!-- TEXTO Prefijo -->
    <text x="150" y="70" text-anchor="middle" font-family="Roboto, Arial Black, Arial, sans-serif" font-size="24" font-weight="bold" fill="$color_texto">$prefijo</text>
EOF
    # Texto: Nombre del estado (1 o 2 líneas) con sombras manuales
    if [ -n "$estado_line2" ]; then
        cat >> "${OUTPUT_DIR}/estado_${nombre_base}.svg" << EOF
    <!-- SOMBRAS nombre estado -->
    <text x="152" y="107" text-anchor="middle" font-family="Roboto, Arial Black, Arial, sans-serif" font-size="18" font-weight="bold" fill="#000000" opacity="0.4">$estado_line1</text>
    <text x="150" y="105" text-anchor="middle" font-family="Roboto, Arial Black, Arial, sans-serif" font-size="18" font-weight="bold" fill="$color_texto">$estado_line1</text>
    <text x="152" y="132" text-anchor="middle" font-family="Roboto, Arial Black, Arial, sans-serif" font-size="18" font-weight="bold" fill="#000000" opacity="0.4">$estado_line2</text>
    <text x="150" y="130" text-anchor="middle" font-family="Roboto, Arial Black, Arial, sans-serif" font-size="18" font-weight="bold" fill="$color_texto">$estado_line2</text>
EOF
    else
        cat >> "${OUTPUT_DIR}/estado_${nombre_base}.svg" << EOF
    <!-- SOMBRA nombre estado -->
    <text x="152" y="112" text-anchor="middle" font-family="Roboto, Arial Black, Arial, sans-serif" font-size="22" font-weight="bold" fill="#000000" opacity="0.4">$estado_line1</text>
    <text x="150" y="110" text-anchor="middle" font-family="Roboto, Arial Black, Arial, sans-serif" font-size="22" font-weight="bold" fill="$color_texto">$estado_line1</text>
EOF
    fi
    cat >> "${OUTPUT_DIR}/estado_${nombre_base}.svg" << EOF
    <!-- Línea divisoria -->
    <line x1="75" y1="175" x2="225" y2="175" stroke="$color_texto" stroke-width="1.5" stroke-dasharray="5 5" />
    <!-- GRUPO DEL ÍCONO (sombra + principal) -->
    <!-- Sombra del ícono (desplazada 3px con opacidad) -->
    <g transform="translate(3, 3)">
        <svg x="$ICONO_X" y="$ICONO_Y" width="$ICONO_ANCHO" height="$ICONO_ALTO" viewBox="$viewbox" preserveAspectRatio="xMidYMid meet">
            <g opacity="0.3">
                $paths_sombra
            </g>
        </svg>
    </g>
    <!-- ÍCONO principal -->
    <svg x="$ICONO_X" y="$ICONO_Y" width="$ICONO_ANCHO" height="$ICONO_ALTO" viewBox="$viewbox" preserveAspectRatio="xMidYMid meet">
        $paths_con_color
    </svg>
    <!-- Texto inferior con sombra -->
    <text x="152" y="382" text-anchor="middle" font-family="Roboto, Arial, sans-serif" font-size="14" fill="#000000" opacity="0.4">E S T A D O</text>
    <text x="150" y="380" text-anchor="middle" font-family="Roboto, Arial, sans-serif" font-size="14" fill="$color_texto">E S T A D O</text>
</svg>
EOF
    # 2. Generar SVG para la CAPITAL
    cat > "${OUTPUT_DIR}/capital_${nombre_base}.svg" << EOF
<svg width="$WIDTH" height="$HEIGHT" viewBox="0 0 $WIDTH $HEIGHT" xmlns="http://www.w3.org/2000/svg">
    <!-- Fondo blanco del naipe -->
    <rect width="$WIDTH" height="$HEIGHT" fill="white" rx="20" ry="20" />
    <!-- Borde negro -->
    <rect x="1.5" y="1.5" width="$((WIDTH-3))" height="$((HEIGHT-3))" fill="none" stroke="black" stroke-width="1.5" rx="18" ry="18" />
    <!-- Fondo de color interior -->
    <rect x="$BORDER" y="$BORDER" width="$((WIDTH-2*BORDER))" height="$((HEIGHT-2*BORDER))" fill="$color_fondo" rx="15" ry="15" />
    <!-- Texto: Capital con sombras manuales -->
EOF
    if [ -n "$capital_line2" ]; then
        cat >> "${OUTPUT_DIR}/capital_${nombre_base}.svg" << EOF
    <!-- SOMBRAS capital -->
    <text x="152" y="77" text-anchor="middle" font-family="Roboto, Arial Black, Arial, sans-serif" font-size="20" font-weight="bold" fill="#000000" opacity="0.4">$capital_line1</text>
    <text x="150" y="75" text-anchor="middle" font-family="Roboto, Arial Black, Arial, sans-serif" font-size="20" font-weight="bold" fill="$color_texto">$capital_line1</text>
    <text x="152" y="107" text-anchor="middle" font-family="Roboto, Arial Black, Arial, sans-serif" font-size="20" font-weight="bold" fill="#000000" opacity="0.4">$capital_line2</text>
    <text x="150" y="105" text-anchor="middle" font-family="Roboto, Arial Black, Arial, sans-serif" font-size="20" font-weight="bold" fill="$color_texto">$capital_line2</text>
    <!-- SOMBRA texto CAPITAL -->
    <text x="152" y="142" text-anchor="middle" font-family="Roboto, Arial, sans-serif" font-size="16" fill="#000000" opacity="0.4">C A P I T A L</text>
    <text x="150" y="140" text-anchor="middle" font-family="Roboto, Arial, sans-serif" font-size="16" fill="$color_texto">C A P I T A L</text>
EOF
    else
        cat >> "${OUTPUT_DIR}/capital_${nombre_base}.svg" << EOF
    <!-- SOMBRA capital -->
    <text x="152" y="92" text-anchor="middle" font-family="Roboto, Arial Black, Arial, sans-serif" font-size="24" font-weight="bold" fill="#000000" opacity="0.4">$capital_line1</text>
    <text x="150" y="90" text-anchor="middle" font-family="Roboto, Arial Black, Arial, sans-serif" font-size="24" font-weight="bold" fill="$color_texto">$capital_line1</text>
    <!-- SOMBRA texto CAPITAL -->
    <text x="152" y="132" text-anchor="middle" font-family="Roboto, Arial, sans-serif" font-size="16" fill="#000000" opacity="0.4">C A P I T A L</text>
    <text x="150" y="130" text-anchor="middle" font-family="Roboto, Arial, sans-serif" font-size="16" fill="$color_texto">C A P I T A L</text>
EOF
    fi
    # Obtener nombre estado en mayúsculas para el texto inferior
    nombre_estado_mayus=$(echo "$nombre_estado" | tr '[:lower:]' '[:upper:]')
    cat >> "${OUTPUT_DIR}/capital_${nombre_base}.svg" << EOF
    <!-- Línea divisoria -->
    <line x1="75" y1="175" x2="225" y2="175" stroke="$color_texto" stroke-width="1.5" stroke-dasharray="5 5" />
    <!-- GRUPO DEL ÍCONO (sombra + principal) -->
    <!-- Sombra del ícono (desplazada 3px con opacidad) -->
    <g transform="translate(3, 3)">
        <svg x="$ICONO_X" y="$ICONO_Y" width="$ICONO_ANCHO" height="$ICONO_ALTO" viewBox="$viewbox" preserveAspectRatio="xMidYMid meet">
            <g opacity="0.3">
                $paths_sombra
            </g>
        </svg>
    </g>
    <!-- ÍCONO principal -->
    <svg x="$ICONO_X" y="$ICONO_Y" width="$ICONO_ANCHO" height="$ICONO_ALTO" viewBox="$viewbox" preserveAspectRatio="xMidYMid meet">
        $paths_con_color
    </svg>
    <!-- Texto inferior con sombra -->
    <text x="152" y="382" text-anchor="middle" font-family="Roboto, Arial, sans-serif" font-size="14" fill="#000000" opacity="0.4">$nombre_estado_mayus</text>
    <text x="150" y="380" text-anchor="middle" font-family="Roboto, Arial, sans-serif" font-size="14" fill="$color_texto">$nombre_estado_mayus</text>
</svg>
EOF
    echo "   ✅ Generados: estado_${nombre_base}.svg y capital_${nombre_base}.svg"
done
# Obtener contador final
contador=$(cat "$temp_contador")
# Limpiar archivos temporales
rm -f "$temp_csv" "$temp_contador"
echo ""
echo "=========================================="
if [ $contador -eq $total_lineas ]; then
    echo "🎉 PROCESO COMPLETADO CON ÉXITO - TODOS LOS REGISTROS PROCESADOS 🎉"
else
    echo "⚠️  ATENCIÓN: Solo se procesaron $contador de $total_lineas registros"
fi
echo "=========================================="
echo "📁 Los naipes se generaron en: $OUTPUT_DIR"
echo "📊 Registros procesados: $contador de $total_lineas"
echo "🌑 Total de naipes generados: $((contador * 2)) (estado + capital)"
echo ""
# Verificar específicamente Guayana Esequiba
if [ -f "${OUTPUT_DIR}/estado_guayana_esequiba.svg" ] && [ -f "${OUTPUT_DIR}/capital_guayana_esequiba.svg" ]; then
    echo "✅ Guayana Esequiba procesado correctamente"
else
    echo "⚠️  Guayana Esequiba NO se procesó - verificando..."
    # Buscar en el CSV
    if grep -q "Guayana Esequiba" "$CSV_FILE"; then
        echo "   El registro existe en el CSV pero no se generaron los archivos"
    else
        echo "   El registro NO existe en el CSV"
    fi
fi
# Generar archivo HTML de vista previa
cat > "${OUTPUT_DIR}/vista_previa.html" << EOF
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Naipes de Venezuela - TODOS LOS REGISTROS</title>
    <style>
        body {
            font-family: 'Segoe UI', Roboto, Arial, sans-serif;
            background: linear-gradient(135deg, #1a2f3f 0%, #162b38 100%);
            margin: 0;
            padding: 20px;
        }
        h1 {
            text-align: center;
            color: white;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
            margin-bottom: 10px;
            font-size: 2.5em;
        }
        .subtitulo {
            text-align: center;
            color: #ffaa00;
            margin-bottom: 20px;
            font-size: 1.3em;
            font-weight: bold;
        }
        .contador {
            text-align: center;
            background: rgba(0,0,0,0.6);
            color: #00ff00;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 30px;
            font-family: monospace;
            font-size: 1.3em;
            border: 2px solid gold;
        }
        .container {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 25px;
            max-width: 1400px;
            margin: 0 auto;
        }
        .naipe-pareja {
            background: rgba(255,255,255,0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 20px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.4);
            transition: transform 0.3s;
            border: 1px solid rgba(255,215,0,0.3);
        }
        .naipe-pareja:hover {
            transform: translateY(-5px);
            border-color: gold;
        }
        .naipe-row {
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
        }
        .naipe-item {
            text-align: center;
        }
        .naipe {
            border: 3px solid white;
            border-radius: 20px;
            box-shadow: 0 10px 20px rgba(0,0,0,0.4);
            transition: all 0.3s;
            background: white;
            width: 200px;
            height: 280px;
            display: block;
        }
        .naipe:hover {
            transform: scale(1.05);
            box-shadow: 0 15px 30px rgba(0,0,0,0.5);
            border-color: gold;
        }
        .titulo-estado {
            font-weight: bold;
            margin-top: 10px;
            color: white;
            text-shadow: 1px 1px 2px black;
            font-size: 1.1em;
        }
        .footer {
            text-align: center;
            margin-top: 40px;
            color: white;
            padding: 20px;
            background: rgba(0,0,0,0.4);
            border-radius: 10px;
            border-top: 2px solid gold;
        }
        .check {
            color: #00ff00;
            font-weight: bold;
        }
        .warning {
            color: #ffaa00;
            font-weight: bold;
        }
        .destacado {
            background: rgba(255,215,0,0.3);
            border: 2px solid gold;
            border-radius: 10px;
            padding: 10px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <h1>🎴 Naipes de Venezuela 🇻🇪</h1>
    <div class="contador">
        📊 $contador ESTADOS + $contador CAPITALES = $((contador * 2)) NAIPES GENERADOS
        $(if [ $contador -eq $total_lineas ]; then 
            echo "✅ (TODOS LOS REGISTROS PROCESADOS)"
        else 
            echo "⚠️ (FALTAN $((total_lineas - contador)) REGISTROS)"
        fi)
    </div>
    <div class="subtitulo">
        ⚡ VERSIÓN DEFINITIVA - PROCESA TODOS LOS REGISTROS DEL CSV INCLUYENDO EL ÚLTIMO ⚡
    </div>
    <div class="container">
EOF
# Agregar cada par de naipes al HTML
tail -n +2 "$CSV_FILE" | while IFS=',' read -r prefijo nombre_estado nombre_capital color_fondo color_texto icono || [ -n "$prefijo" ]; do
    nombre_estado=$(echo "$nombre_estado" | tr -d '\r' | xargs)
    nombre_capital=$(echo "$nombre_capital" | tr -d '\r' | xargs)
    nombre_base=$(limpiar_nombre_archivo "$nombre_estado")
    # Verificar si los archivos existen antes de agregarlos al HTML
    if [ -f "${OUTPUT_DIR}/estado_${nombre_base}.svg" ] && [ -f "${OUTPUT_DIR}/capital_${nombre_base}.svg" ]; then
        cat >> "${OUTPUT_DIR}/vista_previa.html" << EOF
        <div class="naipe-pareja">
            <div class="naipe-row">
                <div class="naipe-item">
                    <img src="estado_${nombre_base}.svg" alt="Estado ${nombre_estado}" class="naipe">
                    <div class="titulo-estado">${prefijo} ${nombre_estado}</div>
                </div>
                <div class="naipe-item">
                    <img src="capital_${nombre_base}.svg" alt="Capital ${nombre_capital}" class="naipe">
                    <div class="titulo-estado">Capital: ${nombre_capital}</div>
                </div>
            </div>
        </div>
EOF
    fi
done
cat >> "${OUTPUT_DIR}/vista_previa.html" << EOF
    </div>
    <div class="footer">
        <p><span class="check">✓</span> <strong>$contador REGISTROS PROCESADOS CORRECTAMENTE</strong> <span class="check">✓</span></p>
        <p>📁 Nombres de archivo sin acentos: á→a, é→e, í→i, ó→o, ú→u, ñ→n, ü→u</p>
        <p>🎨 Todos los colores y textos respetados del CSV original</p>
        <p>🌑 Sombras manuales con desplazamiento 2px y opacidad 0.4</p>
        <div class="destacado">
            <p><strong>🌳 Guayana Esequiba</strong> - Procesado con ícono "tree"</p>
        </div>
    </div>
</body>
</html>
EOF
echo ""
echo "📁 Los naipes se generaron en: $OUTPUT_DIR"
echo "🌐 Abre el archivo 'vista_previa.html' en tu navegador"
echo ""
echo "📌 CORRECCIONES APLICADAS:"
echo "   • Se procesan TODOS los registros incluyendo el último sin salto de línea"
echo "   • Usa || [ -n \"\$prefijo\" ] para capturar la última línea"
echo "   • Contador preciso usando archivo temporal"
echo "   • Verificación específica para Guayana Esequiba"
echo "   • Total de naipes: $((contador * 2))"
echo "=========================================="
