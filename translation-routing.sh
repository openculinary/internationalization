#!/bin/bash

function correct {
    CATEGORY=$1
    DST_DIR=$2

    TEMPLATE_FILE="locales/translations/${DST_DIR}/${CATEGORY}.po"
    CORRECTIONS_FILE="locales/corrections/${DST_DIR}/${CATEGORY}.po"
    OUTPUT_FILE="locales/${DST_DIR}/${CATEGORY}.po"

    if [ ! -f ${CORRECTIONS_FILE} ]; then
        cp ${TEMPLATE_FILE} ${OUTPUT_FILE}
        return
    fi

    pomerge -t ${TEMPLATE_FILE} -i ${CORRECTIONS_FILE} -o ${OUTPUT_FILE}
}

function translate {
    CATEGORY=$1
    SRC_DIR=$2
    LANG_PAIR=$3
    DST_DIR=$4

    SRC_FILE="locales/${SRC_DIR}/${CATEGORY}.po"
    DST_FILE="locales/translations/${DST_DIR}/${CATEGORY}.po"

    TRANSLATE_CMD="pomtrans ${LANG_PAIR} -p ${DST_FILE}:${SRC_FILE} apertium ${DST_FILE}"
    if [ -z "${LANG_PAIR}" ]; then
        SRC_FILE="locales/templates/${CATEGORY}.pot"
        TRANSLATE_CMD="cat ${SRC_FILE} > ${DST_FILE}"
    fi

    mkdir -p "locales/translations/${DST_DIR}"
    eval ${TRANSLATE_CMD}

    correct ${CATEGORY} ${DST_DIR}
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
