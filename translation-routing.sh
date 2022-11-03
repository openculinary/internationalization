#!/bin/bash

function correct {
    CATEGORY=$1
    DST_DIR=$2

    INPUT_FILE="locales/translations/${DST_DIR}/${CATEGORY}.po"
    CORRECTIONS_FILE="locales/corrections/${DST_DIR}/${CATEGORY}.po"
    OUTPUT_FILE="locales/translations/${DST_DIR}/${CATEGORY}.po"

    if [ ! -f ${CORRECTIONS_FILE} ]; then
        return
    fi

    pomerge -t ${INPUT_FILE} -i ${CORRECTIONS_FILE} -o ${OUTPUT_FILE}
}

function validate {
    CATEGORY=$1
    DST_DIR=$2

    TEMPLATE_FILE="locales/templates/${CATEGORY}.pot"
    DST_FILE="locales/translations/${DST_DIR}/${CATEGORY}.po"

    pomerge -t ${TEMPLATE_FILE} -i ${DST_FILE} -o /dev/null
}

function translate {
    CATEGORY=$1
    SRC_DIR=$2
    LANG_PAIR=$3
    DST_DIR=$4

    SRC_FILE="locales/translations/${SRC_DIR}/${CATEGORY}.po"
    DST_FILE="locales/translations/${DST_DIR}/${CATEGORY}.po"

    mkdir -p "locales/translations/${DST_DIR}"
    if [ -n "${LANG_PAIR}" ]; then
        pomerge -t ${SRC_FILE} -i ${DST_FILE} -o ${DST_FILE}
        pomtrans ${LANG_PAIR} -p ${DST_FILE}:${SRC_FILE} --no-fuzzy-flag apertium ${DST_FILE}
    fi

    correct ${CATEGORY} ${DST_DIR}
    validate ${CATEGORY} ${DST_DIR}
}

TEMPLATE_DIR="locales/templates"
for TEMPLATE_FILE in ${TEMPLATE_DIR}/*.pot
do
    CATEGORY=`basename -s .pot ${TEMPLATE_FILE}`
    echo "Translating ${CATEGORY}"

    translate ${CATEGORY} "en" "" "en"
    translate ${CATEGORY} "en" "-s eng -t spa" "es"
    translate ${CATEGORY} "es" "-s es -t fr" "fr"
    translate ${CATEGORY} "es" "-s spa -t ita" "it"

done
