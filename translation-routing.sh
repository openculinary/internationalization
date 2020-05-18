#!/bin/bash

function correct {
    DST_FILENAME=$1
    DST_DIR=$2

    TEMPLATE_FILE="locales/translations/${DST_DIR}/${DST_FILENAME}"
    CORRECTIONS_FILE="locales/corrections/${DST_DIR}/${DST_FILENAME}"
    OUTPUT_FILE="locales/${DST_DIR}/${DST_FILENAME}"

    if [ ! -f ${CORRECTIONS_FILE} ]; then
        cp ${TEMPLATE_FILE} ${OUTPUT_FILE}
        return
    fi

    pomerge -t ${TEMPLATE_FILE} -i ${CORRECTIONS_FILE} -o ${OUTPUT_FILE}
}

function translate {
    SRC_DIR=$1
    SRC_FILENAME=$2
    LANG_PAIR=$3
    DST_DIR=$4

    SRC_FILE="locales/${SRC_DIR}/${SRC_FILENAME}"
    DST_FILENAME=`basename -s .pot ${SRC_FILENAME} | xargs basename -s .po`.po
    DST_FILE="locales/translations/${DST_DIR}/${DST_FILENAME}"

    TRANSLATE_CMD="apertium -- ${LANG_PAIR} -f html-noent -u"
    if [ -z "${LANG_PAIR}" ]; then
        TRANSLATE_CMD="cat --"
    fi

    # Workaround for https://github.com/openculinary/internationalization/issues/5
    INSERT_TAG_OPEN='s/^msgstr/<\nmsgstr/g'
    REMOVE_TAG_OPEN='/^<$/d'

    mkdir -p "locales/translations/${DST_DIR}"
    cat ${SRC_FILE} | sed -e ${INSERT_TAG_OPEN} | pospell -n - -f -p ${TRANSLATE_CMD} | sed -e ${REMOVE_TAG_OPEN} > ${DST_FILE}

    correct ${DST_FILENAME} ${DST_DIR}
}

TEMPLATE_DIR="locales/templates"
for TEMPLATE_FILE in ${TEMPLATE_DIR}/*.pot
do
    CATEGORY=`basename -s .pot ${TEMPLATE_FILE}`
    echo "Translating ${CATEGORY}"

    translate "templates" ${CATEGORY}.pot "" "en"
    translate "templates" ${CATEGORY}.pot "en-es" "es"
    translate "es" ${CATEGORY}.po "es-fr" "fr"
    translate "es" ${CATEGORY}.po "spa-ita" "it"
done
