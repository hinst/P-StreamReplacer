#!/bin/bash
filesCfg=../../../P-MyDevelopment/fpcUnitPathFilesFrom3LF.cfg
containersCfg=../../../P-MyDevelopment/fpcUnitPathContainersFrom3LF.cfg

fpc $1 @$filesCfg @$containersCfg TestStreamReplacerSimpliest.pas
