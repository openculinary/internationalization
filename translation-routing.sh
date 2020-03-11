#!/bin/bash

function correct {
    FILENAME=$1
    DST_DIR=$2

    TEMPLATE_FILE="locales/${DST_DIR}/${FILENAME}"
    CORRECTIONS_FILE="locales/corrections/${DST_DIR}/${FILENAME}"

    if [ ! -f "locales/corrections/${DST_DIR}/${FILENAME}" ]; then
        return
    fi

    pomerge -t ${TEMPLATE_FILE} -i ${CORRECTIONS_FILE} -o ${TEMPLATE_FILE}
}

function translate {
    SRC_DIR=$1
    FILENAME=$2
    LANG_PAIR=$3
    DST_DIR=$4

    SRC_FILE="locales/${SRC_DIR}/${FILENAME}"
    DST_FILE="locales/${DST_DIR}/${FILENAME}"

    TRANSLATE_CMD="apertium -- ${LANG_PAIR} -f html -u"
    if [ -z "${LANG_PAIR}" ]; then
        TRANSLATE_CMD="cat --"
    fi

    # Workaround for https://github.com/openculinary/internationalization/issues/5
    INSERT_TAG_OPEN='s/^msgstr/<\nmsgstr/g'
    REMOVE_TAG_OPEN='/^<$/d'


    mkdir -p "locales/${DST_DIR}"
    cat ${SRC_FILE} | sed -e ${INSERT_TAG_OPEN} | pospell -n - -f -p ${TRANSLATE_CMD} | sed -e ${REMOVE_TAG_OPEN} > ${DST_FILE}

    correct ${FILENAME} ${DST_DIR}
}

TEMPLATE_DIR="locales/templates"
for TEMPLATE_FILE in ${TEMPLATE_DIR}/*.po
do
    FILENAME=`basename ${TEMPLATE_FILE} ${TEMPLATE_DIR}`

    translate "templates" ${FILENAME} "" "en"
    translate "templates" ${FILENAME} "en-es" "es"
    translate "es" ${FILENAME} "es-fr" "fr"
    translate "es" ${FILENAME} "spa-ita" "it"
done
