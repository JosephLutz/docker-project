#!/bin/bash
mkdir -p ${SVN_BASE_DIR} && \
for repo_name in ddio novatech NCD_Release
do
  svnadmin create ${SVN_BASE_DIR}/${repo_name}
done