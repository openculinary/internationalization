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

    TRANSLATE_CMD="apertium -- ${LANG_PAIR} -f html-noent -u"
    if [ -z "${LANG_PAIR}" ]; then
        TRANSLATE_CMD="cat --"
    fi

    # Workaround for https://github.com/openculinary/internationalization/issues/5
    INSERT_TAG_OPEN='s/^msgstr/<\nmsgstr/g'
    REMOVE_TAG_OPEN='/^<$/d'

    mkdir -p "locales/translations/${DST_DIR}"
    cat ${SRC_FILE} | sed -e ${INSERT_TAG_OPEN} | pospell -n - -f -p ${TRANSLATE_CMD} | sed -e ${REMOVE_TAG_OPEN} > ${DST_FILE}

    correct ${CATEGORY} ${DST_DIR}
}

TEMPLATE_DIR="locales/templates"
for TEMPLATE_FILE in ${TEMPLATE_DIR}/*.pot
do
    CATEGORY=`basename -s .pot ${TEMPLATE_FILE}`
    echo "Translating ${CATEGORY}"

    translate ${CATEGORY} "en" "en-es" "es"
    translate ${CATEGORY} "es" "es-fr" "fr"
    translate ${CATEGORY} "es" "spa-ita" "it"
done
