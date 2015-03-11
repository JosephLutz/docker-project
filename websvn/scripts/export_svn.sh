#!/bin/bash
[[ -d ${SVN_EXPORT_PATH} ]] && \
for i in ddio novatech NCD_Release
do
  rm -f ${SVN_EXPORT_PATH}/${i}.svndump.gz && \
  /usr/bin/svnadmin dump ${SVN_BASE_DIR}/${i} \
    | gzip -9 \
    > ${SVN_EXPORT_PATH}/${i}.svndump.gz
done || \
  echo "Export path dose not exist: "${SVN_EXPORT_PATH}