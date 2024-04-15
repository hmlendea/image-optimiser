#!/bin/bash
IMAGE_PATH="${1}"
IMAGES_COUNT=0

TOTAL_SIZE_ORIGINAL=0
TOTAL_SIZE_FINAL=0

for INPUT_PATH in "${@}"; do
    if [[ ! -e "${INPUT_PATH}" ]]; then
        echo "The '${INPUT_PATH}' path does not exist."
        continue
    fi

    while IFS= read -r -d '' IMAGE_PATH; do
        [ ! -f "${IMAGE_PATH}" ] && continue

        IMAGES_COUNT=$((IMAGES_COUNT+1))
        echo "File #${IMAGES_COUNT}: '${IMAGE_PATH}'"
    
        IMAGE_EXTENSION="${IMAGE_PATH##*.}"
        IMAGE_EXTENSION="${IMAGE_EXTENSION,,}"
    
        IMAGE_SIZE_ORIGINAL=$(du -b "${IMAGE_PATH}" | awk '{print $1}')
        TOTAL_SIZE_ORIGINAL=$((TOTAL_SIZE_ORIGINAL+IMAGE_SIZE_ORIGINAL))

        if [[ "${IMAGE_EXTENSION}" == "png" ]]; then
            oxipng -o max --preserve --alpha "${IMAGE_PATH}"
        elif [[ "${IMAGE_EXTENSION}" == "jpg" ]] \
          || [[ "${IMAGE_EXTENSION}" == "jpeg" ]]; then
            jpegoptim --preserve --preserve-perms --all-progressive -o --strip-all "${IMAGE_PATH}"
        else
            echo "The '${IMAGE_EXTENSION}' file format is not supported."
            continue
        fi
    
        IMAGE_SIZE_FINAL=$(du -b "${IMAGE_PATH}" | awk '{print $1}')
        TOTAL_SIZE_FINAL=$((TOTAL_SIZE_FINAL+IMAGE_SIZE_FINAL))

        echo "Size: $(numfmt --to=iec <<< ${IMAGE_SIZE_ORIGINAL}) -> $(numfmt --to=iec <<< ${IMAGE_SIZE_FINAL})"
        echo ""
    done < <(find "${INPUT_PATH}" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -print0)
done

echo "Finished processing ${IMAGES_COUNT} images"
echo "Size: $(numfmt --to=iec <<< ${TOTAL_SIZE_ORIGINAL}) -> $(numfmt --to=iec <<< ${TOTAL_SIZE_FINAL})"
