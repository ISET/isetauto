close all;
clear all;
clc;

[ codePath, parentPath ] = nnGenRootPath();

addpath(codePath);

addpath(fullfile(codePath,'KITTIdevkit'));
addpath(fullfile(codePath,'KITTIdevkit','matlab'));

addpath(fullfile(codePath,'Rendering'));
addpath(fullfile(codePath,'Rendering','Utilities'));
addpath(fullfile(codePath,'Rendering','Remodellers'));

