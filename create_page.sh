if [ ! -n "$1" ]; then
  echo "Missing output file parameter."
  exit 1
fi

OUTPUT_FILE="$1"

mkdir -p docs

# Start with a fresh output file each run
echo "" > $OUTPUT_FILE

function add_c4_mermaid() {
  FILES="./export/*"$1"*.mmd"
  for MERMAID_FILE in $FILES;
  do
    [ -e "$MERMAID_FILE" ] || continue
    echo "# $1" >> $OUTPUT_FILE
    echo -e "\n\`\`\`mermaid" >> $OUTPUT_FILE
    cat $MERMAID_FILE >> $OUTPUT_FILE
    echo -e "\n\`\`\`\n" >> $OUTPUT_FILE
  done  
}

add_c4_mermaid "Context"
add_c4_mermaid "Container"
add_c4_mermaid "Component"
